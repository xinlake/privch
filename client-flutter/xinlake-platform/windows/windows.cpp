#include <windows.h>
#include <shobjidl.h> 

#include <string>
#include <vector>
#include <list>
#include <filesystem>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "_utils.h"

flutter::EncodableList _openFileDialog(bool multiSelection, std::string openPath, std::string defaultPath,
    std::string filterName, std::string filterPattern);


void pickFile(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    bool multiSelection = false;
    std::string openPath, defaultPath;     // optional
    std::string filterName, filterPattern; // filterPattern is required

    // check arguments
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto multiSelectionKey = arguments->find(flutter::EncodableValue("multiSelection"));
        if (multiSelectionKey != arguments->end() && !multiSelectionKey->second.IsNull()) {
            multiSelection = std::get<bool>(multiSelectionKey->second);
        }

        auto openPathKey = arguments->find(flutter::EncodableValue("openPath"));
        if (openPathKey != arguments->end() && !openPathKey->second.IsNull()) {
            openPath = std::get<std::string>(openPathKey->second);
        }

        auto defaultPathKey = arguments->find(flutter::EncodableValue("defaultPath"));
        if (defaultPathKey != arguments->end() && !defaultPathKey->second.IsNull()) {
            defaultPath = std::get<std::string>(defaultPathKey->second);
        }

        auto filterNameKey = arguments->find(flutter::EncodableValue("fileDescription"));
        if (filterNameKey != arguments->end() && !filterNameKey->second.IsNull()) {
            filterName = std::get<std::string>(filterNameKey->second);
        }

        auto filterPatternKey = arguments->find(flutter::EncodableValue("fileTypes"));
        if (filterPatternKey != arguments->end() && !filterPatternKey->second.IsNull()) {
            filterPattern = std::get<std::string>(filterPatternKey->second);
        }
    }

    if (filterPattern.empty()) {
        result->Error("Invalid parameters");
        return;
    }

    // pick files
    flutter::EncodableList resultList =
        _openFileDialog(multiSelection, openPath, defaultPath, filterName, filterPattern);

    // send results
    result->Success(flutter::EncodableValue(resultList));
}

/// <summary>
/// 
/// </summary>
/// <param name="filterName">
/// "filter description"
/// </param>
/// <param name="filterPattern">
/// "*.c; *.cpp"
/// </param>
/// <returns></returns>
flutter::EncodableList _openFileDialog(bool multiSelection, std::string openPath, std::string defaultPath,
    std::string filterName, std::string filterPattern) {

    flutter::EncodableList pathList;
    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (SUCCEEDED(hr)) {

        // Create the FileOpenDialog object.
        IFileOpenDialog* pFileOpen;
        hr = CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
            IID_IFileOpenDialog, reinterpret_cast<void**>(&pFileOpen));
        if (SUCCEEDED(hr)) {

            // set options
            DWORD options;
            hr = pFileOpen->GetOptions(&options);
            if (SUCCEEDED(hr)) {
                options = multiSelection
                    ? (options | FOS_ALLOWMULTISELECT | FOS_FORCEFILESYSTEM)
                    : (options | FOS_FORCEFILESYSTEM);
                hr = pFileOpen->SetOptions(options);
                if (SUCCEEDED(hr)) {

                    // set open folder or default folder, continue 
                    if (!openPath.empty()) {
                        IShellItem* pFolder;
                        std::wstring wOpenPath = WStringFromString(openPath);
                        hr = SHCreateItemFromParsingName(wOpenPath.c_str(), NULL, IID_PPV_ARGS(&pFolder));
                        if (SUCCEEDED(hr)) {
                            hr = pFileOpen->SetFolder(pFolder);
                        }
                    } else if (!defaultPath.empty()) {
                        IShellItem* pFolder;
                        std::wstring wDefaultPath = WStringFromString(defaultPath);
                        hr = SHCreateItemFromParsingName(wDefaultPath.c_str(), NULL, IID_PPV_ARGS(&pFolder));
                        if (SUCCEEDED(hr)) {
                            hr = pFileOpen->SetDefaultFolder(pFolder);
                        }
                    }

                    // set types
                    std::wstring wFilterName = WStringFromString(filterName);
                    std::wstring wFilterPattern = WStringFromString(filterPattern);
                    COMDLG_FILTERSPEC filters[] = {
                        { wFilterName.c_str(), wFilterPattern.c_str() },
                    };
                    hr = pFileOpen->SetFileTypes(ARRAYSIZE(filters), filters);
                    if (SUCCEEDED(hr)) {

                        // Show the Open dialog box.
                        HWND hwnd = GetActiveWindow();
                        hr = pFileOpen->Show(hwnd);
                        if (SUCCEEDED(hr)) {

                            // Get the results
                            //if (multiSelection) {
                            IShellItemArray* pResults;
                            hr = pFileOpen->GetResults(&pResults);
                            if (SUCCEEDED(hr)) {

                                DWORD pathCount;
                                hr = pResults->GetCount(&pathCount);
                                if (SUCCEEDED(hr)) {

                                    // set result list
                                    for (DWORD i = 0; i < pathCount; ++i) {
                                        IShellItem* pResult;
                                        hr = pResults->GetItemAt(i, &pResult);
                                        if (SUCCEEDED(hr)) {

                                            // set result
                                            PWSTR filePath;
                                            hr = pResult->GetDisplayName(SIGDN_FILESYSPATH, &filePath);
                                            if (SUCCEEDED(hr)) {

                                                std::string path = Utf8FromUtf16(filePath);
                                                flutter::EncodableMap map;

                                                map[flutter::EncodableValue("path")] = path.c_str();
                                                map[flutter::EncodableValue("name")] = 
                                                    std::filesystem::path(path).filename().string().c_str();
                                                map[flutter::EncodableValue("length")] =
                                                    (_int64)getFileLength(filePath);
                                                map[flutter::EncodableValue("modified-ms")] =
                                                    (_int64)getFileModified(filePath);

                                                pathList.push_back(flutter::EncodableValue(map));
                                                CoTaskMemFree(filePath);
                                            }

                                            pResult->Release();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            pFileOpen->Release();
        }

        CoUninitialize();
    }

    return pathList;
}
