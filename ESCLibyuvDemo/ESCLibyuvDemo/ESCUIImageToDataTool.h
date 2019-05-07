//
//  ESCUIImageToDataTool.h
//  ESCLibyuvDemo
//
//  Created by xiang on 2019/5/5.
//  Copyright © 2019 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESCUIImageToDataTool : NSObject

+ (void)getImageRGBADataWithImage:(UIImage *)image
                         rgbaData:(uint8_t *)rgbaData
                           length:(int *)length;

+ (UIImage *)getImageFromRGBAData:(uint8_t *)rgbaData
                            width:(int)width
                           height:(int)height;

+ (BOOL)yuvDataConverteARGBDataWithYdata:(uint8_t *)ydata
                                   udata:(uint8_t *)udata
                                   vdata:(uint8_t *)vdata
                                argbData:(uint8_t *_Nullable*_Nullable)argbData
                                   width:(int)width
                                  height:(int)height;

+ (BOOL)yuvDataConverteARGBDataFunc2WithYdata:(uint8_t *)ydata
                                        udata:(uint8_t *)udata
                                        vdata:(uint8_t *)vdata
                                     argbData:(uint8_t *_Nullable*_Nullable)argbData
                                        width:(int)width
                                       height:(int)height;

+ (BOOL)argbDataConverteYUVDataWithARGBData:(uint8_t *)argbData
                                      ydata:(uint8_t *_Nullable*_Nullable)ydata
                                      udata:(uint8_t *_Nullable*_Nullable)udata
                                      vdata:(uint8_t *_Nullable*_Nullable)vdata
                                      width:(int)width
                                     height:(int)height;

+ (BOOL)argbDataConverteYUVDataFunc2WithARGBData:(uint8_t *)argbData
                                           ydata:(uint8_t *_Nullable*_Nullable)ydata
                                           udata:(uint8_t *_Nullable*_Nullable)udata
                                           vdata:(uint8_t *_Nullable*_Nullable)vdata
                                           width:(int)width
                                          height:(int)height;
@end

NS_ASSUME_NONNULL_END
