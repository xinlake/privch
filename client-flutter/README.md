# Private Channel 原生跨平台客户端[^1]

<!--
<p>
<a href='https://play.google.com/store/apps/details?id=xinlake.privch'>
<img alt='Get it on Google Play' height='100px' src='.lfs/google-play-badge-600x200.png'/>
</a>
</p>
-->

<!-- The app is also available on [Google Play](https://play.google.com/store/apps/details?id=xinlake.privch). -->

## 源码目录[^2]

| 目录 | 内容 |
|---------|---------|
| [private-channel](./private-channel/) | 跨平台客户端应用程序 |
| [xinlake-text](./xinlake-text/) | Flutter 软件库，文本处理工具 |
| [xinlake-qrcode](./xinlake-qrcode/) | Flutter 软件库，从图像文件、摄像头（Android）、截屏（Windows）读取二维码信息 |
| [xinlake-platform](./xinlake-platform/) | Flutter 软件库，支持 Flutter 应用与操作系统的交互 |
| [xinlake-window](./xinlake-window/) | Flutter 软件库，控制 Flutter Windows 桌面应用的 Windows 原生窗口 |
| [xinlake-tunnel](./xinlake-tunnel/) | Flutter 软件库，底层加密通讯隧道，支持 Shadowsocks 协议，Android 系统上使用 VPN 接口，Windows 系统上使用 Proxy 接口 |

## 编译
### Android 客户端应用
1. [准备 Flutter 开发环境](https://docs.flutter.dev/get-started/install/windows/mobile?tab=download)。
2. 配置 Android Studio 构建工具链，安装以下组件。[*了解更多*](https://developer.android.com/studio/projects/install-ndk)
    * CMake
    * NDK
3. [安装 Rust](https://www.rust-lang.org/tools/install)，安装完成后执行以下命令添加交叉编译目标平台。[*了解更多*](https://rust-lang.github.io/rustup/cross-compilation.html)
    * `rustup target add armv7-linux-androideabi aarch64-linux-android`
    * [可选] `rustup target add i686-linux-android x86_64-linux-android`
4. [安装 Python](https://www.python.org)。

5. 进入 App 源码目录 `client-flutter/private-channel`，执行以下命令编译
    ```sh
    flutter pub get
    flutter build apk
    ```

<!-- 
### Windows
## 环境
* [**Git**](https://git-scm.com). Make sure `git.exe` can be called by other build systems
* [**Flutter SDK**](https://flutter.dev). Make sure `flutter doctor -v` doesn't prompt issues after [installing the Flutter 
* [**Visual Studio 2022**](https://visualstudio.microsoft.com), only required to build Windows (native) application.
    * "Desktop development with C++" workload
    * C++ CMake tools for Windows
    * [Optional] Windows 10 SDK v10.0.20348.0

### Clean
```powershell
C:\privch\application> flutter clean
```

### Build PrivCh Android APK
* Option 1, using Flutter commands.
```powershell
C:\privch\application> flutter pub get

# This step is only required when doing a fresh build
C:\privch\application\android> .\gradlew.bat generateReleaseSources

C:\privch\application> flutter build apk
```

* Option 2, using Android Studio.

Run the `flutter pub get` command then open `<SOURCE-CODE>/application/android` with Android Studio. For fresh builds you need to execute `Build` -> `Run Generate Sources Gradle Tasks` before building APK

### Build PrivCh Windows Application
* Option 1, using Flutter commands.
```powershell
C:\privch\application> flutter pub get
C:\privch\application> flutter build windows
```

* Option 2, using Visual Studio.

Run the `flutter pub get` command, Open Visual Studio select "Open a local folder" then select `<SOURCE-CODE>/application/windows`. 
-->

<!-- 
## 屏幕
### Android
<p>
<table>
    <tr>
        <td><img src=".lfs/screen/life-2.jpg"/></td>
        <td><img src=".lfs/screen/life-3.jpg"/></td>
    </tr>
    <tr>
        <td colspan=2><img src=".lfs/screen/life-1.jpg"/></td>
    </tr>
</table>
<table>
    <tr>
        <td><img src=".lfs/screen/al-auto3.png"/></td>
        <td><img src=".lfs/screen/al-setting.png"/></td>
        <td><img src=".lfs/screen/al-about.png"/></td>
    </tr>
    <tr>
        <td><img src=".lfs/screen/ad-empty.png"/></td>
        <td><img src=".lfs/screen/ad-list2.png"/></td>
        <td><img src=".lfs/screen/ad-detail.png"/></td>
    </tr>
</table>
</p>

### Windows
<p>
<table>
    <tr>
        <td><img src=".lfs/screen/wl-1600x900-empty.png"/></td>
        <td><img src=".lfs/screen/wl-1600x900-encrypt.png"/></td>
    </tr>
    <tr>
        <td><img src=".lfs/screen/wd-1600x900-list2.png"/></td>
        <td><img src=".lfs/screen/wd-1600x900-about.png"/></td>
    </tr>
</table>
</p>
-->

[^1]: 因开发人员精力有限，现阶段仅提供中文说明文档。
[^2]: 源码中的注释主要供开发人员阅读。
