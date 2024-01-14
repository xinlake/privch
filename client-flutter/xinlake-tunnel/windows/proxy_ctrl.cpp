/*
    A simple system proxy control program. Reference document:
    https://docs.microsoft.com/en-us/windows/desktop/wininet/wininet-vs-winhttp

    Use in C#
    [DllImport("proxyctrl.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode)]
    internal static extern int EnableProxy(string server, string bypass);

    [DllImport("proxyctrl.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode)]
    internal static extern int DisableProxy();

    e.g. EnableProxy("127.0.0.1:12345", "127.0.0.*;10.*;192.168.*");

    xinlake@outlook.com
*/

#include <windows.h>
#include <Wininet.h>

#include <string>

#pragma comment(lib, "Wininet.lib")


static WCHAR* _bypass =
L"<local>;\
localhost;\
127.*;\
10.*;\
172.16.*;\
172.17.*;\
172.18.*;\
172.19.*;\
172.20.*;\
172.21.*;\
172.22.*;\
172.23.*;\
172.24.*;\
172.25.*;\
172.26.*;\
172.27.*;\
172.28.*;\
172.29.*;\
172.30.*;\
172.31.*;\
192.168.*";

BOOL EnableProxy(WCHAR* pServer, WCHAR* pBypass);
BOOL DisableProxy();
static int _refreshSetting();


BOOL EnableProxy(int port) {
    std::wstring server = L"127.0.0.1:" + std::to_wstring(port);
    return EnableProxy(server.data(), _bypass);
}

/*
    Turn on system proxy. Reference code:
    https://docs.microsoft.com/en-us/windows/desktop/WinInet/setting-and-retrieving-internet-options

    pServer: Proxy IP address and port. e.g. "127.0.0.1:12345"
    pBypass: Excepts, use semicolons(;) to separate entries. e.g. "127.0.0.*;10.*;192.168.*"
    Returns: TRUE if the operation succeeds, FALSE otherwise
*/
BOOL EnableProxy(WCHAR* pServer, WCHAR* pBypass) {
    INTERNET_PER_CONN_OPTION_LIST list;
    DWORD   dwBufSize = sizeof(list);
    BOOL    bReturn;

    list.dwSize = sizeof(list); // Fill the list structure.	
    list.pszConnection = NULL; // NULL == LAN, otherwise connectoid name.

    // Set three options.
    list.dwOptionCount = 3;
    list.pOptions = new INTERNET_PER_CONN_OPTION[3];
    if (NULL == list.pOptions) {
        // Return FALSE if the memory wasn't allocated.
        return FALSE;
    }

    // Set flags.
    list.pOptions[0].dwOption = INTERNET_PER_CONN_FLAGS;
    list.pOptions[0].Value.dwValue = PROXY_TYPE_DIRECT | PROXY_TYPE_PROXY;

    // Set proxy name.
    list.pOptions[1].dwOption = INTERNET_PER_CONN_PROXY_SERVER;
    list.pOptions[1].Value.pszValue = pServer;

    // Set proxy override.
    list.pOptions[2].dwOption = INTERNET_PER_CONN_PROXY_BYPASS;
    list.pOptions[2].Value.pszValue = pBypass;

    // Set the options on the connection.
    bReturn = InternetSetOption(NULL, INTERNET_OPTION_PER_CONNECTION_OPTION, &list, dwBufSize);
    _refreshSetting();

    // Free the allocated memory.
    delete[] list.pOptions;
    return bReturn;
}


/*
    Turn off system proxy
    Returns: TRUE if the operation succeeds, FALSE otherwise
*/
BOOL DisableProxy() {
    INTERNET_PER_CONN_OPTION_LIST list;
    DWORD   dwBufSize = sizeof(list);
    BOOL    bReturn;

    list.dwSize = sizeof(list);// Fill the list structure.
    list.pszConnection = NULL; // NULL == LAN, otherwise connectoid name.

    // Set options.
    list.dwOptionCount = 1;
    list.pOptions = new INTERNET_PER_CONN_OPTION;
    if (NULL == list.pOptions) {
        // Return FALSE if the memory wasn't allocated.
        return FALSE;
    }

    list.pOptions[0].dwOption = INTERNET_PER_CONN_FLAGS;
    list.pOptions[0].Value.dwValue = PROXY_TYPE_AUTO_DETECT | PROXY_TYPE_DIRECT;

    bReturn = InternetSetOption(NULL, INTERNET_OPTION_PER_CONNECTION_OPTION, &list, dwBufSize);
    _refreshSetting();

    delete list.pOptions;
    return bReturn;
}


/*
    Flags:
    https://docs.microsoft.com/en-us/windows/desktop/WinInet/option-flags
*/
static BOOL _refreshSetting() {
    BOOL result;

    // Alerts the current WinInet instance that proxy settings have changed and that they must update with the new settings
    result = InternetSetOption(NULL, INTERNET_OPTION_PROXY_SETTINGS_CHANGED, NULL, 0);
    if (!result) {
        return FALSE;
    }

    // Causes the proxy data to be reread from the registry
    result = InternetSetOption(NULL, INTERNET_OPTION_REFRESH, NULL, 0);
    if (!result) {
        return FALSE;
    }

    return TRUE;
}

