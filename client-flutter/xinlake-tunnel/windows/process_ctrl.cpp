#include <Windows.h>
#include <process.h>
#include <Tlhelp32.h>
#include <strsafe.h>

#include "resource.h"

#include <string>
#include <map>
#include <vector>
#include <fstream>
#include <filesystem>

// proxy control
extern BOOL EnableProxy(int port);
extern BOOL DisableProxy();

// resource files
const std::string ssDir = "binary\\shadowsocks-rust-x64";
const std::string ssLocalExe = "sslocal.exe";
const std::vector<std::pair<int, std::string>> ssFiles{
    std::pair<int, std::string>{EXE_SS_LOCAL,"sslocal.exe"},
};

// shadowsocks-rust have http proxy
int localProxyPort = 7039;

static int _port;
static std::string _address;
static std::string _password;
static std::string _encrypt;
static DWORD _ssProcessId = 0;

std::wstring WStringFromString(const std::string& string) {
    std::vector<wchar_t> buff(
        MultiByteToWideChar(CP_ACP, 0, string.c_str(), (int)(string.size() + 1), 0, 0)
    );

    MultiByteToWideChar(CP_ACP, 0, string.c_str(), (int)(string.size() + 1), &buff[0], (int)(buff.size()));

    return std::wstring(&buff[0]);
}

void startShadowsocks(int port, std::string& address, std::string& password, std::string& encrypt) {
    // running
    if (_ssProcessId != 0) {
        return;
    }

    // start privoxy process. 
    STARTUPINFO startInfo{ sizeof(startInfo), 0 }; // set cb (first element) and others
    PROCESS_INFORMATION processInfo{ 0 };

    _port = port;
    _address = address;
    _password = password;
    _encrypt = encrypt;

    std::filesystem::path exePath = std::filesystem::current_path() / ssDir;
    std::wstring ssLocal = exePath / ssLocalExe;
    std::wstring working = exePath;
    std::string command = " -s " + _address + ":" + std::to_string(port) +
        " -k " + _password + " -m " + _encrypt +
        " -b 127.0.0.1:" + std::to_string(localProxyPort) +
        " --protocol http -U --timeout 5";

    // convert to wstring, the codecvt header are deprecated in C++17
    std::wstring wCommand = WStringFromString(command);

    if (CreateProcess(ssLocal.data(), wCommand.data(),
        NULL, NULL, FALSE, CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP, NULL,
        working.data(), &startInfo, &processInfo)) {

        _ssProcessId = processInfo.dwProcessId;

        // Close process and thread handles. 
        CloseHandle(processInfo.hProcess);
        CloseHandle(processInfo.hThread);
    }
}

BOOL stopShadowsocks() {
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, _ssProcessId);
    if (hProcess != NULL) {
        TerminateProcess(hProcess, 0);

        DWORD waitResult = WaitForSingleObject(hProcess, 3000);
        if (waitResult == WAIT_OBJECT_0) {
            _ssProcessId = 0;
        } else {
            // TODO: (sorry) tell user terminate process manually
        }

        CloseHandle(hProcess);
        return waitResult == WAIT_OBJECT_0;
    }

    // sslocal may stop itself on some internal reason
    _ssProcessId = 0;
    return TRUE;
}

void restartShadowsocks(int proxyPort) {
    if (proxyPort > 0 && localProxyPort != proxyPort) {
        // update config
        localProxyPort = proxyPort;

        if (_ssProcessId != 0) {
            DisableProxy();
            stopShadowsocks();

            // apply config
            startShadowsocks(_port, _address, _password, _encrypt);
            EnableProxy(localProxyPort);
        }
    }
}

void cacheBinaries() {
    HMODULE hDll = GetModuleHandle(TEXT("xinlake_tunnel_plugin.dll"));
    if (hDll == NULL) {
        return;
    }

    // privoxy, shadowsocks
    std::map<std::string, std::vector<std::pair<int, std::string>>> dirs{
        {ssDir, ssFiles},
    };

    // load resource files
    std::filesystem::path appPath = std::filesystem::current_path();
    for (const auto& [dir, files] : dirs) {
        std::filesystem::create_directories(appPath / dir);

        for (std::pair<int, std::string> resItem : files) {
            int resId = resItem.first;
            std::filesystem::path filePath = appPath / dir / resItem.second;

            // skip this file if it's already exist
            if (std::filesystem::exists(filePath)) {
                continue;
            }

            HRSRC hResource = FindResource(hDll, MAKEINTRESOURCE(resId), RT_RCDATA);
            if (hResource == NULL) {
                continue;
            }

            HGLOBAL hMemory = LoadResource(hDll, hResource);
            if (hMemory == NULL) {
                continue;
            }

            LPVOID data = (char*)LockResource(hMemory);
            DWORD size = SizeofResource(hDll, hResource);

            // write data to file
            auto file = std::fstream(filePath, std::ios::out | std::ios::binary);
            file.write((char*)data, size);
            file.close();
        }
    }

    FreeLibrary(hDll);
    return;
}
