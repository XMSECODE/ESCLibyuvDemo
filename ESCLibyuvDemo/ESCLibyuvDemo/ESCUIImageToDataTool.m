//
//  ESCUIImageToDataTool.m
//  ESCLibyuvDemo
//
//  Created by xiang on 2019/5/5.
//  Copyright © 2019 xiang. All rights reserved.
//

#import "ESCUIImageToDataTool.h"
#import <Accelerate/Accelerate.h>

@implementation ESCUIImageToDataTool

+ (void)getImageRGBADataWithImage:(UIImage *)image rgbaData:(uint8_t *)rgbaData length:(int *)length {
    int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint8_t *rgbaImageBuf = rgbaData;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbaImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
}

+ (UIImage *)getImageFromRGBAData:(uint8_t *)rgbaData width:(int)width height:(int)height {
    int bytes_per_pix = 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef Context = CGBitmapContextCreate(rgbaData,width, height, 8,width * bytes_per_pix,colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGImageRef frame = CGBitmapContextCreateImage(Context);
    UIImage *image = [UIImage imageWithCGImage:frame];
    CGImageRelease(frame);
    CGContextRelease(Context);
    CGColorSpaceRelease(colorSpace);
    return image;
}

+ (BOOL)yuvDataConverteARGBDataWithYdata:(uint8_t *)ydata
                                   udata:(uint8_t *)udata
                                   vdata:(uint8_t *)vdata
                                argbData:(uint8_t **)argbData
                                   width:(int)width
                                  height:(int)height {
    
    vImage_Buffer srcsBuff_y;
    srcsBuff_y.data = ydata;
    srcsBuff_y.height = height;
    srcsBuff_y.width = width;
    srcsBuff_y.rowBytes = width;
    
    vImage_Buffer srcsBuff_u;
    srcsBuff_u.data = udata;
    srcsBuff_u.height = height;
    srcsBuff_u.width = width;
    srcsBuff_u.rowBytes = width / 2;
    
    vImage_Buffer srcsBuff_v;
    srcsBuff_v.data = vdata;
    srcsBuff_v.height = height;
    srcsBuff_v.width = width;
    srcsBuff_v.rowBytes = width / 2;
    
    
    vImage_Buffer argbBuff;
    argbBuff.height = height;
    argbBuff.width = width;
    argbBuff.rowBytes = width * 4;
    
    vImage_YpCbCrToARGB infoyuvoargb;
    
//    argbBuff.width = width;
//    argbBuff.height = height;
//    argbBuff.data = malloc(width * height * 4);
//    argbBuff.rowBytes = width * 4;
    
    vImage_Error init = vImageBuffer_Init(&argbBuff, height, width, 32, kvImageNoFlags);
    
    if (init != 0) {
        NSLog(@"vImageBuffer_Init失败");
        return NO;
    }
    
    vImage_YpCbCrPixelRange range;
    range.Yp_bias = 16;
    range.CbCr_bias = 128;
    range.YpRangeMax = 235;
    range.CbCrRangeMax = 240;
    range.YpMax = 235;
    range.YpMin = 16;
    range.CbCrMax = 240;
    range.CbCrMin = 16;
    
    vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &range, &infoyuvoargb, kvImage420Yp8_Cb8_Cr8, kvImageARGB8888, kvImageNoFlags);
    
    vImage_Error result = vImageConvert_420Yp8_Cb8_Cr8ToARGB8888(&srcsBuff_y, &srcsBuff_v, &srcsBuff_u, &argbBuff, &infoyuvoargb, NULL, 255, kvImagePrintDiagnosticsToConsole);
    if (result != 0) {
        NSLog(@"vImageConvert_420Yp8_Cb8_Cr8ToARGB8888 转换失败");
        return NO;
    }
    
    *argbData = argbBuff.data;
    return YES;
}

+ (BOOL)yuvDataConverteARGBDataFunc2WithYdata:(uint8_t *)ydata
                                        udata:(uint8_t *)udata
                                        vdata:(uint8_t *)vdata
                                     argbData:(uint8_t **)argbData
                                        width:(int)width
                                       height:(int)height {
        
    vImageCVImageFormatRef srcFormat = vImageCVImageFormat_Create(kCVPixelFormatType_420YpCbCr8Planar, kvImage_ARGBToYpCbCrMatrix_ITU_R_601_4, kCVImageBufferChromaLocation_Center,CGColorSpaceCreateDeviceRGB(), 0);
    
    vImage_CGImageFormat destformat;
    destformat.bitsPerComponent = 8;
    destformat.bitsPerPixel = 32;
    destformat.colorSpace = CGColorSpaceCreateDeviceRGB();
   

    int bitmapInfo =  kCGImageByteOrder32Big | kCGImageAlphaNoneSkipFirst;
    destformat.bitmapInfo =  bitmapInfo;
    destformat.version = 0;
    destformat.decode = NULL;
    const CGFloat backgroundColor[] = {1.0,1.0,1.0};
    vImage_Error err;
    
    
    vImageConverterRef converter = vImageConverter_CreateForCVToCGImageFormat(srcFormat, &destformat, backgroundColor, kvImageNoFlags, &err);
    if (err != 0) {
        NSLog(@"创建转换器失败");
        vImageCVImageFormat_Release(srcFormat);
        return NO;
    }
    
    vImage_Buffer srcsBuff_y;
    srcsBuff_y.data = ydata;
    srcsBuff_y.height = height;
    srcsBuff_y.width = width;
    srcsBuff_y.rowBytes = width;
    
    vImage_Buffer srcsBuff_u;
    srcsBuff_u.data = udata;
    srcsBuff_u.height = height;
    srcsBuff_u.width = width;
    srcsBuff_u.rowBytes = width / 2;
    
    vImage_Buffer srcsBuff_v;
    srcsBuff_v.data = vdata;
    srcsBuff_v.height = height;
    srcsBuff_v.width = width;
    srcsBuff_v.rowBytes = width / 2;
    
    vImage_Buffer srcsBuffs[] = {srcsBuff_y,srcsBuff_v,srcsBuff_u};
    vImage_Buffer argb_buffer;
    
    vImage_Error init = vImageBuffer_Init(&argb_buffer, height, width, 32, kvImageNoFlags);
    
    if (init != 0) {
        NSLog(@"失败");
        vImageCVImageFormat_Release(srcFormat);
        vImageConverter_Release(converter);
        return NO;
    }
    vImage_Error result = vImageConvert_AnyToAny(converter, srcsBuffs, &argb_buffer, NULL, kvImageNoFlags);
    
    
    if (result != 0) {
        NSLog(@"转换失败");
        vImageCVImageFormat_Release(srcFormat);
        vImageConverter_Release(converter);
        return NO;
    }
    *argbData = argb_buffer.data;
    vImageCVImageFormat_Release(srcFormat);
    vImageConverter_Release(converter);
    return YES;
}

+ (BOOL)argbDataConverteYUVDataWithARGBData:(uint8_t *)argbData
                                      ydata:(uint8_t *_Nullable*_Nullable)ydata
                                      udata:(uint8_t *_Nullable*_Nullable)udata
                                      vdata:(uint8_t *_Nullable*_Nullable)vdata
                                      width:(int)width
                                     height:(int)height {
    
    vImage_Buffer argbBuff;
    argbBuff.height = height;
    argbBuff.width = width;
    argbBuff.rowBytes = width * 4;
    argbBuff.data = argbData;
    
    vImage_Buffer buff_y;
    vImage_Error init = vImageBuffer_Init(&buff_y, height, width, 8, kvImageNoFlags);
    if (init != 0) {
        NSLog(@"vImageBuffer_Init失败");
        return NO;
    }
    
    vImage_Buffer buff_u;
    init = vImageBuffer_Init(&buff_u, height, width / 2, 8, kvImageNoFlags);
    if (init != 0) {
        NSLog(@"vImageBuffer_Init失败");
        return NO;
    }
    
    vImage_Buffer buff_v;
    init = vImageBuffer_Init(&buff_v, height, width / 2, 8, kvImageNoFlags);
    if (init != 0) {
        NSLog(@"vImageBuffer_Init失败");
        return NO;
    }

    vImage_ARGBToYpCbCr infoargbtoyuv;
    
    vImage_YpCbCrPixelRange range;
    range.Yp_bias = 16;
    range.CbCr_bias = 128;
    range.YpRangeMax = 235;
    range.CbCrRangeMax = 240;
    range.YpMax = 235;
    range.YpMin = 16;
    range.CbCrMax = 240;
    range.CbCrMin = 16;
    
    vImageConvert_ARGBToYpCbCr_GenerateConversion(kvImage_ARGBToYpCbCrMatrix_ITU_R_601_4, &range, &infoargbtoyuv, kvImageARGB8888, kvImage420Yp8_Cb8_Cr8, kvImagePrintDiagnosticsToConsole);
        
     vImage_Error result = vImageConvert_ARGB8888To420Yp8_Cb8_Cr8(&argbBuff, &buff_y, &buff_u, &buff_v, &infoargbtoyuv, NULL, kvImagePrintDiagnosticsToConsole);
    
    if (result != 0) {
        NSLog(@"vImageConvert_ARGB8888To420Yp8_Cb8_Cr8 转换失败");
        return NO;
    }
    
    *ydata = buff_y.data;
    *udata = buff_u.data;
    *vdata = buff_v.data;
    return YES;
}

+ (BOOL)argbDataConverteYUVDataFunc2WithARGBData:(uint8_t *)argbData
                                           ydata:(uint8_t *_Nullable*_Nullable)ydata
                                           udata:(uint8_t *_Nullable*_Nullable)udata
                                           vdata:(uint8_t *_Nullable*_Nullable)vdata
                                           width:(int)width
                                          height:(int)height {
    
    vImageCVImageFormatRef srcFormat = vImageCVImageFormat_Create(kCVPixelFormatType_420YpCbCr8Planar, kvImage_ARGBToYpCbCrMatrix_ITU_R_601_4, kCVImageBufferChromaLocation_Center,CGColorSpaceCreateDeviceRGB(), 0);
    
    vImage_CGImageFormat destformat;
    destformat.bitsPerComponent = 8;
    destformat.bitsPerPixel = 32;
    destformat.colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    int bitmapInfo =  kCGImageByteOrder32Big | kCGImageAlphaNoneSkipFirst;
    destformat.bitmapInfo =  bitmapInfo;
    destformat.version = 0;
    destformat.decode = NULL;
    const CGFloat backgroundColor[] = {1.0,1.0,1.0};
    vImage_Error err;
    
    
    vImageConverterRef converter = vImageConverter_CreateForCGToCVImageFormat(&destformat, srcFormat, backgroundColor, kvImageNoFlags, &err);
    if (err != 0) {
        NSLog(@"创建转换器失败");
        vImageCVImageFormat_Release(srcFormat);
        return NO;
    }
    
    vImage_Buffer argbBuff;
    argbBuff.height = height;
    argbBuff.width = width;
    argbBuff.rowBytes = width * 4;
    argbBuff.data = argbData;
    
    vImage_Buffer buff_y;
    vImage_Error init = vImageBuffer_Init(&buff_y, height, width, 8, kvImageNoFlags);
    if (init != 0) {
        NSLog(@"vImageBuffer_Init失败");
        vImageCVImageFormat_Release(srcFormat);
        vImageConverter_Release(converter);
        return NO;
    }
    
    vImage_Buffer buff_u;
    init = vImageBuffer_Init(&buff_u, height, width, 8, kvImageNoFlags);
    if (init != 0) {
        NSLog(@"vImageBuffer_Init失败");
        vImageCVImageFormat_Release(srcFormat);
        vImageConverter_Release(converter);
        return NO;
    }
    
    vImage_Buffer buff_v;
    init = vImageBuffer_Init(&buff_v, height, width, 8, kvImageNoFlags);
    if (init != 0) {
        NSLog(@"vImageBuffer_Init失败");
        vImageCVImageFormat_Release(srcFormat);
        vImageConverter_Release(converter);
        return NO;
    }
    
    vImage_Buffer yuvbuffer[] = {buff_y,buff_v,buff_u};
    

    vImage_Error result = vImageConvert_AnyToAny(converter, &argbBuff, yuvbuffer, NULL, kvImageNoFlags);
    
    
    if (result != 0) {
        NSLog(@"转换失败==%zd",result);
        vImageCVImageFormat_Release(srcFormat);
        vImageConverter_Release(converter);
        return NO;
    }
    
    vImageCVImageFormat_Release(srcFormat);
    vImageConverter_Release(converter);
    *ydata = buff_y.data;
    *udata = buff_u.data;
    *vdata = buff_v.data;
    
    return YES;
}

@end
