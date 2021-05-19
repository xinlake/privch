/*******************************************************************************
 *                                                                             *
 *  Copyright (C) 2017 by Max Lv <max.c.lv@gmail.com>                          *
 *  Copyright (C) 2017 by Mygod Studio <contact-shadowsocks-android@mygod.be>  *
 *                                                                             *
 *  This program is free software: you can redistribute it and/or modify       *
 *  it under the terms of the GNU General Public License as published by       *
 *  the Free Software Foundation, either version 3 of the License, or          *
 *  (at your option) any later version.                                        *
 *                                                                             *
 *  This program is distributed in the hope that it will be useful,            *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 *  GNU General Public License for more details.                               *
 *                                                                             *
 *  You should have received a copy of the GNU General Public License          *
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.       *
 *                                                                             *
 *******************************************************************************/

package privch.tunnel.shadowsocks

import android.app.Service
import android.content.Intent
import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.net.Network
import android.net.VpnService
import android.os.Build
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import com.github.shadowsocks.bg.Executable
import com.github.shadowsocks.bg.GuardedProcessPool
import com.github.shadowsocks.bg.LocalDnsWorker
import com.github.shadowsocks.net.ConcurrentLocalSocketListener
import com.github.shadowsocks.net.DefaultNetworkListener
import com.github.shadowsocks.net.DnsResolverCompat
import com.github.shadowsocks.utils.int
import kotlinx.coroutines.*
import privch.tunnel.IServiceEvent
import privch.tunnel.PrivChTunnel
import privch.tunnel.aidl.ServiceMethod

import timber.log.Timber
import java.io.File
import java.io.FileDescriptor
import java.io.IOException

/**
 * shadowsocks-android:
 * com/github/shadowsocks/bg/BaseService.kt, com/github/shadowsocks/bg/VpnService.kt
 *
 * Issue-1. Acl mode is All and cannot be Bypass-Lan,
 * parseNumericAddress no longer usable in Android Q
 *
 * 2021-04
 */
class SSService : VpnService() {
    companion object {
        private const val VPN_MTU = 1500
        private const val PRIVATE_VLAN4_CLIENT = "172.19.0.1"
        private const val PRIVATE_VLAN4_ROUTER = "172.19.0.2"
        private const val PRIVATE_VLAN6_CLIENT = "fdfe:dcba:9876::1"
        private const val PRIVATE_VLAN6_ROUTER = "fdfe:dcba:9876::2"

        private fun <T> FileDescriptor.use(block: (FileDescriptor) -> T) = try {
            block(this)
        } finally {
            try {
                Os.close(this)
            } catch (exception: ErrnoException) {
            }
        }
    }

    private inner class ProtectWorker : ConcurrentLocalSocketListener(
        "ShadowsocksVpnThread",
        File(PrivChTunnel.getInstance().noBackupFilesDir, "protect_path")) {
        override fun acceptInternal(socket: LocalSocket) {
            if (socket.inputStream.read() == -1) return
            val success = socket.ancillaryFileDescriptors!!.single()!!.use { fd ->
                underlyingNetwork.let { network ->
                    if (network != null) try {
                        network.bindSocket(fd)
                        return@let true
                    } catch (exception: IOException) {
                        when ((exception.cause as? ErrnoException)?.errno) {
                            // also suppress ENONET (Machine is not on the network)
                            OsConstants.EPERM, OsConstants.EACCES, 64 -> Timber.d(exception)
                            else -> Timber.w(exception)
                        }
                        return@let false
                    }
                    protect(fd.int)
                }
            }

            try {
                socket.outputStream.write(if (success) 0 else 1)
            } catch (exception: IOException) {
                // ignore connection early close
            }
        }
    }

    private var processes: GuardedProcessPool? = null
    private var localDns: LocalDnsWorker? = null
    private var connectingJob: Job? = null
    private var conn: ParcelFileDescriptor? = null
    private var worker: ProtectWorker? = null

    private var active = false
    private var metered = false
    private var server: RemoteServer? = null
    private var listener: IServiceEvent? = null

    private var underlyingNetwork: Network? = null
        set(value) {
            field = value
            if (active) setUnderlyingNetworks(underlyingNetworks)
        }

    // clearing underlyingNetworks makes Android 9 consider the network to be metered
    private val underlyingNetworks
        get() = if (Build.VERSION.SDK_INT == 28 && metered) null else underlyingNetwork?.let { arrayOf(it) }

    private suspend fun preInit() = DefaultNetworkListener.start(this) { underlyingNetwork = it }
    private suspend fun rawResolver(query: ByteArray) = DnsResolverCompat.resolveRawOnActiveNetwork(query)
    /*
    // no need to listen for network here as this is only used for forwarding local DNS queries.
    // retries should be attempted by client.
    override suspend fun rawResolver(query: ByteArray) =
        DnsResolverCompat.resolveRaw(underlyingNetwork ?: throw IOException("no network"), query)
    */

    fun setListener(listener: IServiceEvent?) {
        this.listener = listener
    }

    fun updateServer(serverId: Int, port: Int, address: String, password: String, encrypt: String): Boolean {
        // check the new server
        val remoteServer = RemoteServer(port, address, password, encrypt)
        if (!remoteServer.isValid) {
            listener?.onMessage("Invalid server")
            return false
        }
        if (remoteServer == server && active) {
            listener?.onMessage("Server already in use")
            return false
        }

        if (active) {
            stopRunner(false)
        }

        // switch to the new server
        server = remoteServer
        listener?.onServerChanged(serverId)

        connectingJob = GlobalScope.launch(Dispatchers.Main) {
            try {
                Executable.killAll()    // clean up old processes
                preInit()

                // TODO. not necessary
                Thread.sleep(100)

                startProcesses()
                listener?.onStateChanged(true)
            } catch (exception: CancellationException) {
                // if the job was cancelled, it is canceller's responsibility to call stopRunner
                listener?.onStateChanged(false)
            } catch (exception: Throwable) {
                Timber.w(exception)
                stopRunner()
            } finally {
                connectingJob = null
            }
        }

        return true
    }

    fun stopRunner(notifyListener: Boolean = true) {
        GlobalScope.launch(Dispatchers.Main.immediate) {
            connectingJob?.cancelAndJoin() // ensure stop connecting first
            // this@Interface as Service
            // we use a coroutineScope here to allow clean-up in parallel
            coroutineScope {
                killProcesses(this)
            }

            // stop the service if nothing has bound to it
            // stopSelf()
            if (notifyListener) {
                listener?.onStateChanged(false)
            }
        }
    }

    private suspend fun startProcesses() {
        processes = GuardedProcessPool {
            Timber.w(it)
            stopRunner()
        }

        worker = ProtectWorker().apply { start() }
        localDns = LocalDnsWorker(this::rawResolver).apply { start() }

        startShadowsocks()
        sendFd(startVpn())
    }

    private fun killProcesses(scope: CoroutineScope) {
        processes?.run {
            close(scope)
            processes = null
        }

        localDns?.shutdown(scope)
        localDns = null

        active = false
        scope.launch { DefaultNetworkListener.stop(this) }

        worker?.shutdown(scope)
        worker = null

        conn?.close()
        conn = null
    }

    // shadowsocks-android. com/github/shadowsocks/bg/ProxyInstance.kt
    private fun startShadowsocks() {
        val cmd = arrayListOf(
            File(PrivChTunnel.getInstance().nativeLibraryDir, Executable.SS_LOCAL).absolutePath,
            //"--stat-path", stat.absolutePath,
            "--local-addr", "127.0.0.1:${PrivChTunnel.getInstance().portProxy}",
            "--server-addr", "${server!!.address}:${server!!.port}",
            "-k", server!!.password,
            "-m", server!!.encrypt,
            "--udp-bind-addr", "127.0.0.1:${PrivChTunnel.getInstance().portProxy}",
            "--dns-addr", "127.0.0.1:${PrivChTunnel.getInstance().portLocalDns}",
            "--local-dns-addr", "local_dns_path",
            "--remote-dns-addr", "${PrivChTunnel.getInstance().remoteDnsAddress}:53",
            "--vpn", "-U",
        )

        processes!!.start(cmd)
    }

    private suspend fun startVpn(ipv6: Boolean = false): FileDescriptor {
        val builder = Builder()
            .setSession("PrivCh")
            .setConfigureIntent(PrivChTunnel.getInstance().configureIntent)
            .setMtu(VPN_MTU)
            .addAddress(PRIVATE_VLAN4_CLIENT, 30)
            .addDnsServer(PRIVATE_VLAN4_ROUTER)

        if (ipv6) builder.addAddress(PRIVATE_VLAN6_CLIENT, 126)

        // acl-all
        builder.addRoute("0.0.0.0", 0)
        if (ipv6) builder.addRoute("::", 0)

        active = true   // possible race condition here?
        builder.setUnderlyingNetworks(underlyingNetworks)
        if (Build.VERSION.SDK_INT >= 29) builder.setMetered(metered)

        val conn = builder.establish() ?: throw Exception("Null Connection")
        this.conn = conn

        val cmd = arrayListOf(File(applicationInfo.nativeLibraryDir, Executable.TUN2SOCKS).absolutePath,
            "--netif-ipaddr", PRIVATE_VLAN4_ROUTER,
            "--socks-server-addr", "127.0.0.1:${PrivChTunnel.getInstance().portProxy}",
            "--tunmtu", VPN_MTU.toString(),
            "--sock-path", "sock_path",
            "--dnsgw", "127.0.0.1:${PrivChTunnel.getInstance().portLocalDns}",
            "--loglevel", "warning")
        if (ipv6) {
            cmd += "--netif-ip6addr"
            cmd += PRIVATE_VLAN6_ROUTER
        }
        cmd += "--enable-udprelay"

        processes!!.start(cmd, onRestartCallback = {
            try {
                sendFd(conn.fileDescriptor)
            } catch (exception: ErrnoException) {
                stopRunner()
            }
        })

        return conn.fileDescriptor
    }

    private suspend fun sendFd(fd: FileDescriptor) {
        var tries = 0
        val path = File(PrivChTunnel.getInstance().noBackupFilesDir, "sock_path").absolutePath
        while (true) try {
            delay(50L shl tries)
            LocalSocket().use { localSocket ->
                localSocket.connect(LocalSocketAddress(path, LocalSocketAddress.Namespace.FILESYSTEM))
                localSocket.setFileDescriptorsForSend(arrayOf(fd))
                localSocket.outputStream.write(42)
            }
            return
        } catch (exception: IOException) {
            if (tries > 5) throw exception
            tries += 1
        }
    }

    // service -------------------------------------------------------------------------------------
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (prepare(this) != null) {
            stopRunner()
        }

        return Service.START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder {
        return ServiceMethod(this)
    }

    override fun onRevoke() {
        stopRunner()
    }

    override fun onCreate() {
        super.onCreate()
        PrivChTunnel.create(applicationContext)
    }

    override fun onDestroy() {
        stopRunner()
        super.onDestroy()
    }
}
