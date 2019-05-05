//
//  ESCUIImageToDataTool.m
//  ESCLibyuvDemo
//
//  Created by xiang on 2019/5/5.
//  Copyright © 2019 xiang. All rights reserved.
//

#import "ESCUIImageToDataTool.h"

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

@end
