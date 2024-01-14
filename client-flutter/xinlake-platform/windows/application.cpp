#include <windows.h>
#include <VersionHelpers.h>
#include <dwmapi.h>

#include <tchar.h>
#include <filesystem>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "_utils.h"

#pragma warning(disable : 4293)
#pragma comment(lib, "Version")
#pragma comment(lib, "Dwmapi.lib")

void getAppVersion(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    TCHAR szPath[MAX_PATH];
    if (!GetModuleFileName(NULL, szPath, MAX_PATH)) {
        result->Error("GetModuleFileName");
        return;
    }

    char version[32];
    int buildNumber = 0;

    DWORD verHandle = 0;
    DWORD verSize = GetFileVersionInfoSize(szPath, &verHandle);
    if (verSize != NULL) {

        LPSTR verData = new char[verSize];
        if (GetFileVersionInfo(szPath, verHandle, verSize, verData)) {

            UINT   size = 0;
            LPBYTE lpBuffer = NULL;
            if (VerQueryValue(verData, L"\\", (VOID FAR * FAR*) & lpBuffer, &size)) {
                if (size > 0) {
                    VS_FIXEDFILEINFO* verInfo = (VS_FIXEDFILEINFO*)lpBuffer;

                    int length = sprintf_s(version, "%hu.%hu.%hu",
                        HIWORD(verInfo->dwProductVersionMS),
                        LOWORD(verInfo->dwProductVersionMS),
                        HIWORD(verInfo->dwProductVersionLS)
                    );

                    buildNumber = LOWORD(verInfo->dwProductVersionLS);
                    version[length] = 0;
                }
            }
        }

        delete[] verData;
    }

    LONG64 modified = getFileModified(szPath);

    flutter::EncodableMap map;
    map[flutter::EncodableValue("version")] = version;
    map[flutter::EncodableValue("build-number")] = buildNumber;
    map[flutter::EncodableValue("updated-utc")] = modified;
    result->Success(flutter::EncodableValue(map));
}
