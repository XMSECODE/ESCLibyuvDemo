//
//  ViewController.m
//  ESCLibyuvDemo
//
//  Created by xiang on 2019/5/5.
//  Copyright © 2019 xiang. All rights reserved.
//

#import "ViewController.h"
#import "libyuv.h"
#import "ESCUIImageToDataTool.h"
#import <Accelerate/Accelerate.h>

@interface ViewController ()

@property(nonatomic,strong)NSArray* imageViewArray;

@property(nonatomic,strong)NSData* argbData;

@property(nonatomic,strong)NSData* yuvData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *temArray = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [temArray addObject:imageView];
        [self.view addSubview:imageView];
    }
    self.imageViewArray = temArray;
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"yuv_1920_1080" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:file];
    self.yuvData = data;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            
            [self testImageData];
            
            [self testLibyuvYUVToARGB];
            
            [self testAccelerateFrameFunc1];
            
            [self testAccelerateFrameFunc2];
            
            [self testAccelerateFrameFunc3];
            
            [self testAccelerateFrameFunc4];
            
        });
    });
    
}

- (void)testImageData {
    int rgbaDataLength = 0;
    UIImage *image = [UIImage imageNamed:@"IMG_4370"];
    int width = image.size.width;
    int height = image.size.height;
    uint8_t *rgbaData = malloc(width * height * 4);
    
    [ESCUIImageToDataTool getImageRGBADataWithImage:image rgbaData:rgbaData length:&rgbaDataLength];
    
    UIImage *newImage = [ESCUIImageToDataTool getImageFromRGBAData:rgbaData width:width height:height];
    
    free(rgbaData);
    //加载出来
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.imageViewArray objectAtIndex:0];
        imageView.frame = CGRectMake(0,50,180 ,250);
        imageView.image = newImage;
    });
}

- (void)testLibyuvYUVToARGB {
    
    
    int width = 1920;
    int height = 1080;
    uint8_t *yData = malloc(width * height);
    uint8_t *uData = malloc(width * height / 4);
    uint8_t *vData = malloc(width * height / 4);
    [self.yuvData getBytes:yData range:NSMakeRange(0, width * height)];
    [self.yuvData getBytes:uData range:NSMakeRange(width * height, width * height / 4)];
    [self.yuvData getBytes:vData range:NSMakeRange(width * height * 5 / 4, width * height / 4)];
    
    double startTime = CFAbsoluteTimeGetCurrent();
    uint8_t *rgbaData = malloc(width * height * 4);
    
    I420ToRGBA(yData, width, uData, width / 2, vData, width / 2, rgbaData, 4 * width, width, height);
    
    double endTime = CFAbsoluteTimeGetCurrent();
    double time = endTime - startTime;
    NSLog(@"libyuv time ====== %f",time);
    
    free(yData);
    free(uData);
    free(vData);
    
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:rgbaData width:width height:height];
    free(rgbaData);
    //加载出来
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.imageViewArray objectAtIndex:1];
        imageView.frame = CGRectMake(190,50,180 ,250);
        imageView.image = image;
    });
}

- (void)testAccelerateFrameFunc1 {
    
    int width = 1920;
    int height = 1080;
    void *ydata = malloc(width * height);
    void *udata = malloc(width * height / 4);
    void *vdata = malloc(width * height / 4);
    [self.yuvData getBytes:ydata range:NSMakeRange(0, width * height)];
    [self.yuvData getBytes:udata range:NSMakeRange(width * height, width * height / 4)];
    [self.yuvData getBytes:vdata range:NSMakeRange(width * height * 5 / 4, width * height / 4)];
    
    uint8_t *argbData;
    double startTime = CFAbsoluteTimeGetCurrent();
    BOOL result = [ESCUIImageToDataTool yuvDataConverteARGBDataWithYdata:ydata udata:udata vdata:vdata argbData:&argbData width:width height:height];
    double endTime = CFAbsoluteTimeGetCurrent();
    double time = endTime - startTime;
    NSLog(@"accelerate func1 time === %f",time);
    
    
    free(ydata);
    free(udata);
    free(vdata);
    
    if (result == NO) {
        NSLog(@"转换失败");
        return;
    }
    
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:argbData width:width height:height];
    free(argbData);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.imageViewArray objectAtIndex:2];
        imageView.frame = CGRectMake(0,310,180 ,250);
        imageView.image = image;
    });
    
}

- (void)testAccelerateFrameFunc2 {
    
    int width = 1920;
    int height = 1080;
    void *ydata = malloc(width * height);
    void *udata = malloc(width * height / 4);
    void *vdata = malloc(width * height / 4);
    [self.yuvData getBytes:ydata range:NSMakeRange(0, width * height)];
    [self.yuvData getBytes:udata range:NSMakeRange(width * height, width * height / 4)];
    [self.yuvData getBytes:vdata range:NSMakeRange(width * height * 5 / 4, width * height / 4)];
    
    uint8_t *argbData;
    
    double startTime = CFAbsoluteTimeGetCurrent();
    BOOL result = [ESCUIImageToDataTool yuvDataConverteARGBDataFunc2WithYdata:ydata udata:udata vdata:vdata argbData:&argbData width:width height:height];
    double endTime = CFAbsoluteTimeGetCurrent();
    double time = endTime - startTime;
    NSLog(@" accelerate func2 == %f",time);
    
    free(ydata);
    free(udata);
    free(vdata);
    
    if (result == NO) {
        NSLog(@"转换失败");
        return;
    }
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:argbData width:width height:height];
    self.argbData = [NSData dataWithBytes:argbData length:width * height * 4];
    free(argbData);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.imageViewArray objectAtIndex:3];
        imageView.frame = CGRectMake(190,310,180 ,250);
        imageView.image = image;
    });
}

- (void)testAccelerateFrameFunc3 {
    uint8_t *argbData = (uint8_t *)[self.argbData bytes];
    int width = 1920;
    int height = 1080;
    uint8_t *ydata;
    uint8_t *udata;
    uint8_t *vdata;
    double startTime = CFAbsoluteTimeGetCurrent();
    BOOL result = [ESCUIImageToDataTool argbDataConverteYUVDataWithARGBData:argbData ydata:&ydata udata:&udata vdata:&vdata width:width height:height];
    double endTime = CFAbsoluteTimeGetCurrent();
    double time = endTime - startTime;
    NSLog(@"accelerate func3 ==  %f",time);
    if (result == NO) {
        NSLog(@"转换ARGB失败");
        return;
    }
    uint8_t *converteARGBData;
    result = [ESCUIImageToDataTool yuvDataConverteARGBDataWithYdata:ydata udata:udata vdata:vdata argbData:&converteARGBData width:width height:height];
    
    free(ydata);
    free(udata);
    free(vdata);
    
    if (result == NO) {
        NSLog(@"转换YUV失败");
        return;
    }
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:argbData width:width height:height];
    
    free(converteARGBData);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.imageViewArray objectAtIndex:4];
        imageView.frame = CGRectMake(0,570,180 ,250);
        imageView.image = image;
    });
}

- (void)testAccelerateFrameFunc4 {
    uint8_t *argbData = (uint8_t *)[self.argbData bytes];
    int width = 1920;
    int height = 1080;
    uint8_t *ydata;
    uint8_t *udata;
    uint8_t *vdata;
    double startTime = CFAbsoluteTimeGetCurrent();
    BOOL result = [ESCUIImageToDataTool argbDataConverteYUVDataFunc2WithARGBData:argbData ydata:&ydata udata:&udata vdata:&vdata width:width height:height];
    double endTime = CFAbsoluteTimeGetCurrent();
    double time = endTime - startTime;
    NSLog(@"accelerate func3 ==  %f",time);
    if (result == NO) {
        NSLog(@"转换ARGB失败");
        return;
    }
    uint8_t *converteARGBData;
    result = [ESCUIImageToDataTool yuvDataConverteARGBDataWithYdata:ydata udata:udata vdata:vdata argbData:&converteARGBData width:width height:height];
    
    free(ydata);
    free(udata);
    free(vdata);
    
    if (result == NO) {
        NSLog(@"转换YUV失败");
        return;
    }
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:argbData width:width height:height];
    
    free(converteARGBData);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.imageViewArray objectAtIndex:5];
        imageView.frame = CGRectMake(190,570,180 ,250);
        imageView.image = image;
    });
}

@end
