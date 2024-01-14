#ifndef XINLAKE_PLATFORM_UTIL
#define XINLAKE_PLATFORM_UTIL

#include <Windows.h>

#include <string>
#include <vector>


// Takes a null-terminated wchar_t* encoded in UTF-16 and returns a std::string
// encoded in UTF-8. Returns an empty std::string on failure.
std::string Utf8FromUtf16(const wchar_t* utf16_string);
std::wstring WStringFromString(const std::string& string);

ULONG64 getFileModified(LPTSTR lpszString);
ULONG64 getFileLength(LPTSTR lpszString);

#endif  // XINLAKE_PLATFORM_UTIL
