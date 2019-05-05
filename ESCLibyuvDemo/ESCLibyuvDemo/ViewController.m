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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self testImageData];
        
        [self testYUV420AndRGBA];
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
        UIImageView *imageView = [[UIImageView alloc] initWithImage:newImage];
        imageView.frame = CGRectMake(50,0,250 ,250);
        [self.view addSubview:imageView];
    });
}

- (void)testYUV420AndRGBA {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"yuv_1920_1080" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:file];
    int width = 1920;
    int height = 1080;
    uint8_t *yData = malloc(width * height);
    uint8_t *uData = malloc(width * height / 4);
    uint8_t *vData = malloc(width * height / 4);
    [data getBytes:yData range:NSMakeRange(0, width * height)];
    [data getBytes:uData range:NSMakeRange(width * height, width * height / 4)];
    [data getBytes:vData range:NSMakeRange(width * height * 5 / 4, width * height / 4)];
    
    uint8_t *rgbaData = malloc(width * height * 4);
    
    I420ToRGBA(yData, width, uData, width / 2, vData, width / 2, rgbaData, 4 * width, width, height);
    
    free(yData);
    free(uData);
    free(vData);
    
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:rgbaData width:width height:height];
    free(rgbaData);
    
    //加载出来
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(50,300,250 ,250);
        [self.view addSubview:imageView];
    });
}


@end
