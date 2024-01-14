# Private Channel 加密代理节点[^1]
**该项目仍在开发之中，不建议直接使用其中的源码。**

## Linux 服务器安装
安装脚本基于 Debian 12 开发，理论上支持以下 Linux 发行版：
- Debian 12 及更新的版本
- Ubuntu 22 及更新的版本

### 快速安装
适用于无需后端的场景，安装完成后，服务器将生成二维码，客户端扫描二维码即可使用。
```sh
curl --silent --fail --show-error https://raw.githubusercontent.com/xinlake/privch/dev/server-proxy/linux-install.sh \
| sudo --preserve-env bash
```

### 高级安装
适用于需要集中管理的场景，且后端已经准备好。安装完成后，客户端可通过后端自动同步代理节点信息，无需手动操作。
该方案中，代理节点与后端的通信需要使用密钥进行签名和身份验证，脚本将生成签名私钥并显示公钥，公钥需要在后端上进行配置。
```sh
curl --silent --fail --show-error https://raw.githubusercontent.com/xinlake/privch/dev/server-proxy/linux-install.sh \
| sudo --preserve-env bash -s -- --storage-endpoint <STORAGE-API-URL> [--update-key]
```
- `--storage-endpoint <STORAGE-API-URL>`：参数用于指定后端存储端点 API 地址，如 *`--storage-endpoint https://function-name.azurewebsites.net/api/storage`*。

- `--update-key`：参数表示是否更新密钥。如果不指定该参数，则会优先使用已有的密钥。如果指定该参数，则会忽略已有的密钥，重新生成新密钥。

### 显示二维码
在快速安装完成后，节点二维码会自动显示在屏幕上，您也可以在任何时间执行以下命令来显示节点二维码：
```sh
/usr/local/xinlake-privch/privch.sh qrcode
```

### 显示公钥
在高级安装完成后，节点公钥会自动显示在屏幕上，您也可以在任何时间执行以下命令来显示节点公钥：
```sh
/usr/local/xinlake-privch/privch.sh pubkey
```

### 卸载
执行以下命令卸载：
```sh
sudo /usr/local/xinlake-privch/privch.sh uninstall
```
如果卸载之前存在密钥，则脚本程序会在删除密钥前先获得您的同意。如果您同意删除密钥，则脚本程序会删除密钥，如果您不同意删除密钥，密钥则会被保留。

如果保留密钥，那么再下次安装时，脚本会使用已有的密钥。除非您在安装时指定 `--update-key` 参数，否则脚本不会生成新的密钥。

[^1]: 因开发人员精力有限，现阶段仅提供中文说明文档。
