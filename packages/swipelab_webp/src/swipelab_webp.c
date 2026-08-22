// swipelab_webp.c - FFI wrapper for libwebp encoding
#include <stdlib.h>
#include <string.h>
#include "webp/encode.h"

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

// Result structure for encoded WebP data
typedef struct {
    uint8_t* data;
    size_t size;
    int error;
} WebPEncodeResult;

// Encode RGBA image to WebP (lossy)
// Returns allocated data that must be freed with swipelab_webp_free
EXPORT WebPEncodeResult swipelab_webp_encode_rgba(
    const uint8_t* rgba,
    int width,
    int height,
    int stride,
    float quality
) {
    WebPEncodeResult result = {0};

    if (rgba == NULL || width <= 0 || height <= 0) {
        result.error = 1;
        return result;
    }

    uint8_t* output = NULL;
    size_t size = WebPEncodeRGBA(rgba, width, height, stride, quality, &output);

    if (size == 0 || output == NULL) {
        result.error = 2;
        return result;
    }

    result.data = output;
    result.size = size;
    result.error = 0;

    return result;
}

// Encode RGBA image to WebP (lossless)
EXPORT WebPEncodeResult swipelab_webp_encode_rgba_lossless(
    const uint8_t* rgba,
    int width,
    int height,
    int stride
) {
    WebPEncodeResult result = {0};

    if (rgba == NULL || width <= 0 || height <= 0) {
        result.error = 1;
        return result;
    }

    uint8_t* output = NULL;
    size_t size = WebPEncodeLosslessRGBA(rgba, width, height, stride, &output);

    if (size == 0 || output == NULL) {
        result.error = 2;
        return result;
    }

    result.data = output;
    result.size = size;
    result.error = 0;

    return result;
}

// Free WebP encoded data
EXPORT void swipelab_webp_free(uint8_t* data) {
    if (data != NULL) {
        WebPFree(data);
    }
}

// Get encoder version
EXPORT int swipelab_webp_version(void) {
    return WebPGetEncoderVersion();
}
