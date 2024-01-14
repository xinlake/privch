# Private Channel 无服务后端[^1]
**该项目仍在开发之中，不建议直接使用其中的源码。**

## 部署
该项目基于 Azure 云服务开发，需要用到 Azure Function 和 Azure Storage 资源。

### 创建 Azure 资源
1. [准备 Azure 账号，了解 Azure Function。](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-function-app-portal)

2. 进入 [Azure Portal](portal.azure.com)，创建 Function 资源
    - Runtime stack 选择：**Node.js**
    - Version 选择：**20 (Prevew)**
    - Storage account：建议新建一个存储账号，可以使用默认选择

### 通过 VSCode 部署
1. [准备开发环境。](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=node-v3%2Cpython-v2%2Cisolated-process&pivots=programming-language-javascript)

2. 用 VSCode 打开 **server-backend** 文件夹。

3. 部署到 Azure Function 应用
    - 打开 Azure 扩展面板，展开 Function App 资源。
    - 右键点击需要部署到的 Function，选择 **Deploy to Function app ...**，等待部署完成。

4. 设置 Function 的环境变量，在“应用设置”中新建以下四个环境变量：
    - **PRIVCH_STORAGE_ACCOUNT**：<存储账号名称>
    - **PRIVCH_STORAGE_API_KEY**：<存储账号 API KEY>
    - *PRIVCH_STORAGE_CONTAINER*：<存储容器名称>，可选，不设置则会使用默认名称
    - **PRIVCH_ED25519_PUB**：<签名公钥>

[^1]: 因开发人员精力有限，现阶段仅提供中文说明文档。
