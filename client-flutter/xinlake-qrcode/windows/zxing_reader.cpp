#define ZX_USE_UTF8 1 // see Result.h

#include "ReadBarcode.h"
#include "TextUtfEncoding.h"
#include "GTIN.h"

#include <windows.h>
#include <shobjidl.h> 

#include <cctype>
#include <chrono>
#include <clocale>
#include <cstring>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

#define __STDC_LIB_EXT1__
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image.h>
#include <stb_image_write.h>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

using namespace ZXing;

static void zxing_read_image(ImageView& image, flutter::EncodableList& codeList);

void readImage(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    flutter::EncodableList imageList;

    // check arguments
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto imageListIt = arguments->find(flutter::EncodableValue("imageList"));
        if (imageListIt != arguments->end()) {
            imageList = std::get<flutter::EncodableList>(imageListIt->second);
        }
    }

    if (imageList.empty()) {
        result->Error("Invalid parameters");
        return;
    }

    flutter::EncodableList codeList;
    for (const auto& imageItem : imageList) {
        const std::string imagePath = std::get<std::string>(imageItem);

        int width, height, channels;
        std::unique_ptr<stbi_uc, void(*)(void*)> buffer(
            stbi_load(imagePath.c_str(), &width, &height, &channels, 4),
            stbi_image_free);
        if (buffer == nullptr) {
            continue;
        }

        ImageView image{ buffer.get(), width, height, ImageFormat::RGBX };
        zxing_read_image(image, codeList);
    }

    result->Success(codeList);
}

void readScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    flutter::EncodableList codeList;

    // copy screen to bitmap
    HDC screenDC = GetDC(NULL);
    const int screenWidth = GetDeviceCaps(screenDC, HORZRES);
    const int screenHeight = GetDeviceCaps(screenDC, VERTRES);

    HDC compatibleDC = CreateCompatibleDC(screenDC);
    HBITMAP compatibleBitmap = CreateCompatibleBitmap(screenDC, screenWidth, screenHeight);
    HGDIOBJ compatibleObject = SelectObject(compatibleDC, compatibleBitmap);

    if (BitBlt(compatibleDC, 0, 0, screenWidth, screenHeight, screenDC, 0, 0, SRCCOPY)) {
        // get image info then get image data
        BITMAP screenBitmap{ 0 };
        if (GetObject(compatibleBitmap, sizeof(screenBitmap), &screenBitmap)) {

            const int bitmapLength = screenBitmap.bmHeight * screenBitmap.bmWidthBytes;
            void* bitmapData = new unsigned char[bitmapLength];
            if (GetBitmapBits(compatibleBitmap, bitmapLength, bitmapData) > 0) {

                // read codes
                ImageView image{ (unsigned char*)bitmapData,
                    screenBitmap.bmWidth, screenBitmap.bmHeight,
                    ImageFormat::RGBX };
                zxing_read_image(image, codeList);
            }

            delete[] bitmapData;
        }
    }

    // clean up
    SelectObject(compatibleDC, compatibleObject);
    ReleaseDC(NULL, screenDC);
    DeleteDC(compatibleDC);
    DeleteObject(compatibleBitmap);

    // send result
    result->Success(codeList);
}


static void zxing_read_image(ImageView& image, flutter::EncodableList& codeList) {
    DecodeHints hints;
    hints.setEanAddOnSymbol(EanAddOnSymbol::Read);

    auto results = ReadBarcodes(image, hints);
    if (results.empty()) {
        results.emplace_back(); // DecodeStatus::NotFound
        return;
    }

    for (auto&& result : results) {
        if (result.isValid()) {
            std::string code = result.text(); // TextUtfEncoding::ToUtf8
            codeList.push_back(flutter::EncodableValue(code.c_str()));
        }
    }
}
