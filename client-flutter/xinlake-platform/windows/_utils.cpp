#include "_utils.h"

std::string Utf8FromUtf16(const wchar_t* utf16_string) {
    if (utf16_string == nullptr) {
        return std::string();
    }

    int target_length = ::WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
        -1, nullptr, 0, nullptr, nullptr);
    if (target_length == 0) {
        return std::string();
    }

    std::string utf8_string;
    utf8_string.resize(target_length);
    int converted_length = ::WideCharToMultiByte(
        CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
        -1, utf8_string.data(), target_length, nullptr, nullptr);

    if (converted_length == 0) {
        return std::string();
    }

    return utf8_string;
}

std::wstring WStringFromString(const std::string& string) {
    std::vector<wchar_t> buff(
        MultiByteToWideChar(CP_ACP, 0, string.c_str(), (int)(string.size() + 1), 0, 0)
    );

    MultiByteToWideChar(CP_ACP, 0, string.c_str(), (int)(string.size() + 1), &buff[0], (int)(buff.size()));

    return std::wstring(&buff[0]);
}

ULONG64 getFileModified(LPTSTR lpszPath) {
    HANDLE hFile = CreateFile(lpszPath, GENERIC_READ, FILE_SHARE_READ, NULL,
        OPEN_EXISTING, 0, NULL);

    if (hFile == INVALID_HANDLE_VALUE) {
        return 0;
    }

    // Retrieve the file times for the file.
    ULONG64 modified = 0;
    FILETIME ftCreate, ftAccess, ftWrite;
    if (GetFileTime(hFile, &ftCreate, &ftAccess, &ftWrite)) {

        // https://stackoverflow.com/questions/6161776/convert-windows-filetime-to-second-in-unix-linux
        modified = ((static_cast<ULONG64>(ftWrite.dwHighDateTime) << 32) | ftWrite.dwLowDateTime)
            / 10000 - 11644473600000;
    }

    CloseHandle(hFile);
    return modified;
}

ULONG64 getFileLength(LPTSTR lpszPath) {
    HANDLE hFile = CreateFile(lpszPath, GENERIC_READ, FILE_SHARE_READ, NULL,
        OPEN_EXISTING, 0, NULL);

    if (hFile == INVALID_HANDLE_VALUE) {
        return 0;
    }

    // Retrieve the file times for the file.
    ULONG64 length = 0;
    LARGE_INTEGER li;
    if (GetFileSizeEx(hFile, &li)) {

        length = li.QuadPart;
    }

    CloseHandle(hFile);
    return length;
}
