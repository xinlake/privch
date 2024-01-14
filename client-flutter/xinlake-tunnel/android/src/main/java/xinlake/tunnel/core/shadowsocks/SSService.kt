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

package xinlake.tunnel.core.shadowsocks

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
import android.util.Log
import com.github.shadowsocks.bg.Executable
import com.github.shadowsocks.bg.GuardedProcessPool
import com.github.shadowsocks.net.ConcurrentLocalSocketListener
import com.github.shadowsocks.net.DefaultNetworkListener
import com.github.shadowsocks.net.Subnet
import com.github.shadowsocks.utils.int
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import xinlake.tunnel.core.TunnelCore
import java.io.File
import java.io.FileDescriptor
import java.io.IOException

/* Some of these source code are copied form shadowsocks-android v5.2.6
    com/github/shadowsocks/bg/BaseService.kt,
    com/github/shadowsocks/bg/VpnService.kt,
 */

/**
 * Must bind service with `socksPort`, `localDnsPort`, `remoteDnsAddress` optional settings
 * And updateSettings before startService
 *
 * 2021-11
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
                // ignore
            }
        }
    }

    private inner class ProtectWorker : ConcurrentLocalSocketListener(
        "ShadowsocksVpnThread",
        File(TunnelCore.instance().noBackupFilesDir, "protect_path")
    ) {
        override fun acceptInternal(socket: LocalSocket) {
            if (socket.inputStream.read() == -1) return
            val success = socket.ancillaryFileDescriptors!!.single()!!.use { fd ->
                underlyingNetwork.let { network ->
                    if (network != null) try {
                        network.bindSocket(fd)
                        return@let true
                    } catch (exception: IOException) {
                        when ((exception.cause as? ErrnoException)?.errno) {
                            OsConstants.EPERM, OsConstants.EACCES, OsConstants.ENONET -> Log.d(
                                "Xinlake",
                                exception.toString()
                            )

                            else -> Log.w("Xinlake", exception)
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

    private var status: Int = TunnelCore.STATE_STOPPED
    private var processes: GuardedProcessPool? = null
    private var connectingJob: Job? = null
    private var conn: ParcelFileDescriptor? = null
    private var worker: ProtectWorker? = null

    private var active = false
    private var metered = false
    private var server: RemoteServer? = null

    @Volatile
    private var underlyingNetwork: Network? = null
        set(value) {
            field = value
            if (active) setUnderlyingNetworks(underlyingNetworks)
        }

    // clearing underlyingNetworks makes Android 9 consider the network to be metered
    private val underlyingNetworks
        get() = if (Build.VERSION.SDK_INT == 28 && metered) null else underlyingNetwork?.let {
            arrayOf(it)
        }

    private suspend fun preInit() = DefaultNetworkListener.start(this) { underlyingNetwork = it }

    private fun broadcastMessage(message: String) {
        Intent(TunnelCore.ACTION_EVENT_BROADCAST).also { intent ->
            intent.putExtra("message", message)
            sendBroadcast(intent)
        }
    }

    private fun broadcastStatus(status: Int) {
        this.status = status

        Intent(TunnelCore.ACTION_EVENT_BROADCAST).also { intent ->
            intent.putExtra("status", status)
            sendBroadcast(intent)
        }
    }

    fun getState(): Int {
        return status
    }

    fun toggleService(): Boolean {
        if (server == null) {
            return false
        }

        when (status) {
            TunnelCore.STATE_CONNECTED -> {
                stopRunner()
            }

            TunnelCore.STATE_STOPPED -> {
                startService()
            }
        }

        return true
    }

    fun startService(
        port: Int,
        address: String,
        password: String,
        encrypt: String
    ): Boolean {
        // check the new server
        val remoteServer = RemoteServer(port, address, password, encrypt)
        if (!remoteServer.isValid) {
            broadcastMessage("Invalid server")
            return false
        }
        if (remoteServer == server && active) {
            broadcastMessage("Server already in use")
            return false
        }

        if (active) {
            stopRunner()
        }

        // switch to the new server
        server = remoteServer

        startService()
        return true
    }

    private fun startService() {
        broadcastStatus(TunnelCore.STATE_CONNECTING)
        connectingJob = GlobalScope.launch(Dispatchers.Main) {
            try {
                Executable.killAll()    // clean up old processes
                preInit()

                // not necessary
                Thread.sleep(100)

                startProcesses()
                broadcastStatus(TunnelCore.STATE_CONNECTED)
            } catch (exception: CancellationException) {
                // if the job was cancelled, it is canceller's responsibility to call stopRunner
            } catch (exception: Throwable) {
                Log.w("Xinlake", exception)
                stopRunner()
            } finally {
                connectingJob = null
            }
        }
    }

    fun stopRunner() {
        if (status == TunnelCore.STATE_STOPPING) return

        // change state
        broadcastStatus(TunnelCore.STATE_STOPPING)

        GlobalScope.launch(Dispatchers.Main.immediate) {
            connectingJob?.cancelAndJoin() // ensure stop connecting first
            // this@Interface as Service
            // we use a coroutineScope here to allow clean-up in parallel
            coroutineScope {
                killProcesses(this)
            }

            // stop the service if nothing has bound to it
            // stopSelf()
            broadcastStatus(TunnelCore.STATE_STOPPED)
        }
    }

    private suspend fun startProcesses() {
        worker = ProtectWorker().apply { start() }
        processes = GuardedProcessPool {
            Log.w("Xinlake", it)
            stopRunner()
        }

        startShadowsocks()
        sendFd(startVpn())
    }

    private fun killProcesses(scope: CoroutineScope) {
        processes?.run {
            close(scope)
            processes = null
        }

        active = false
        scope.launch { DefaultNetworkListener.stop(this) }

        worker?.shutdown(scope)
        worker = null

        conn?.close()
        conn = null
    }

    /* shadowsocks-rust v1.15.2
     * shadowsocks-android. com/github/shadowsocks/bg/ProxyInstance.kt
     *
     * top, command line, libsslocal.so
     */
    private fun startShadowsocks() {
        val cmd = arrayListOf(
            File(TunnelCore.instance().nativeLibraryDir, Executable.SS_LOCAL).absolutePath,
            "--local-addr", "127.0.0.1:${TunnelCore.instance().socksPort}",
            "--server-addr", "${server!!.address}:${server!!.port}",
            "--encrypt-method", server!!.encrypt,
            "--password", server!!.password,
            "--dns-addr", "127.0.0.1:${TunnelCore.instance().dnsLocalPort}",
            "--local-dns-addr", "${TunnelCore.instance().dnsRemoteAddress}:53",
            "--remote-dns-addr", "${TunnelCore.instance().dnsRemoteAddress}:53",
            "--vpn", "-U",
        )

        // android.util.Log.i("Xinlake", cmd.toString())
        processes!!.start(cmd)
    }

    private suspend fun startVpn(ipv6: Boolean = false): FileDescriptor {
        val builder = Builder()
            .setSession("PrivCh")
            .setConfigureIntent(TunnelCore.instance().configureIntent)
            .setMtu(VPN_MTU)
            .addAddress(PRIVATE_VLAN4_CLIENT, 30)
            .addDnsServer(PRIVATE_VLAN4_ROUTER)

        if (ipv6) builder.addAddress(PRIVATE_VLAN6_CLIENT, 126)

        // acl bypass_private_route
        TunnelCore.BYPASS_PRIVATE_ROUTE.forEach {
            val subnet = Subnet.fromString(it)!!
            builder.addRoute(subnet.address.hostAddress!!, subnet.prefixSize)
        }
        builder.addRoute(PRIVATE_VLAN4_ROUTER, 32)
        // https://issuetracker.google.com/issues/149636790
        if (ipv6) builder.addRoute("2000::", 3)

        active = true   // possible race condition here?
        builder.setUnderlyingNetworks(underlyingNetworks)
        if (Build.VERSION.SDK_INT >= 29) builder.setMetered(metered)

        val conn = builder.establish() ?: throw Exception("Null Connection")
        this.conn = conn

        // shadowsocks-android v5.3.3. top libtun2socks.so
        val cmd = arrayListOf(
            File(applicationInfo.nativeLibraryDir, Executable.TUN2SOCKS).absolutePath,
            "--netif-ipaddr", PRIVATE_VLAN4_ROUTER,
            "--socks-server-addr", "127.0.0.1:${TunnelCore.instance().socksPort}",
            "--tunmtu", VPN_MTU.toString(),
            "--sock-path", "sock_path",
            "--dnsgw", "127.0.0.1:${TunnelCore.instance().dnsLocalPort}",
            "--loglevel", "warning"
        )
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
        val path = File(TunnelCore.instance().noBackupFilesDir, "sock_path").absolutePath
        while (true) try {
            delay(50L shl tries)
            LocalSocket().use { localSocket ->
                localSocket.connect(
                    LocalSocketAddress(
                        path,
                        LocalSocketAddress.Namespace.FILESYSTEM
                    )
                )
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

    // must use bindService
    override fun onBind(intent: Intent): IBinder? {
        /* android.net.VpnService
        This method returns null on Intents other than SERVICE_INTERFACE action.
        Applications overriding this method must identify the intent
        and return the corresponding interface accordingly.
        */
        if (intent.action == SERVICE_INTERFACE) {
            return super.onBind(intent)
        }

        TunnelCore.init(applicationContext)
        return ServiceBinder(this)
    }

    override fun onRevoke() {
        stopRunner()
    }

    override fun onDestroy() {
        stopRunner()
        super.onDestroy()
    }
}
