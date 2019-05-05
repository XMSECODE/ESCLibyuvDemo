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

+ (void)getImageRGBADataWithImage:(UIImage *)image rgbaData:(uint8_t *)rgbaData length:(int *)length;

+ (UIImage *)getImageFromRGBAData:(uint8_t *)rgbaData width:(int)width height:(int)height;

@end

NS_ASSUME_NONNULL_END
