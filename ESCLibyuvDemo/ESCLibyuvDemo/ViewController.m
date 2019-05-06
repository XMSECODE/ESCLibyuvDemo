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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self testImageData];
        
        [self testYUV420AndRGBA];
        
        [self testAccelerateFrame];
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
    double startTime = CFAbsoluteTimeGetCurrent();
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
    
    for (int i = 0; i < 20; i++) {
        printf(" %d  ",(int)rgbaData[i]);
    }
    
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:rgbaData width:width height:height];
    double endTime = CFAbsoluteTimeGetCurrent();
    
    double time = endTime - startTime;
    NSLog(@"%f",time);
    
    free(rgbaData);
    
    //加载出来
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0,300,180 ,250);
        [self.view addSubview:imageView];
    });
}

- (void)testAccelerateFrame {
    //    kvImage420Yp8_Cb8_Cr8
    //vImageConverter_CreateForCVToCGImageFormat
    
    //    vImageConverter_GetDestinationBufferOrder(<#vImageConverterRef converter#>)
    //    vImageCVImageFormat_Create(<#uint32_t imageFormatType#>, <#const vImage_ARGBToYpCbCrMatrix *matrix#>, <#CFStringRef cvImageBufferChromaLocation#>, <#CGColorSpaceRef baseColorspace#>, <#int alphaIsOneHint#>)
    //    vImageConverter_CreateWithCGImageFormat
    //    VIMAGE_PF vImageConverterRef vImageConverter_CreateWithColorSyncCodeFragment( CFTypeRef codeFragment,
    //
    //    vImageConverter_CreateForCGToCVImageFormat(<#const vImage_CGImageFormat *srcFormat#>, <#vImageCVImageFormatRef destFormat#>, <#const CGFloat *backgroundColor#>, <#vImage_Flags flags#>, <#vImage_Error *error#>)
    //    vImageConverter_CreateForCVToCGImageFormat(<#vImageCVImageFormatRef srcFormat#>, <#const vImage_CGImageFormat *destFormat#>, <#const CGFloat *backgroundColor#>, <#vImage_Flags flags#>, <#vImage_Error *error#>)
    //    vImageConverterRef converter;
    //    vImageConvert_AnyToAny(const vImageConverterRef converter, <#const vImage_Buffer *srcs#>, <#const vImage_Buffer *dests#>, <#void *tempBuffer#>, <#vImage_Flags flags#>)
    
    
    
    {
        
        //        typedef struct vImage_CGImageFormat
        //        {
        //            uint32_t                bitsPerComponent;
        //            uint32_t                bitsPerPixel;
        //            CGColorSpaceRef         colorSpace;
        //            CGBitmapInfo            bitmapInfo;
        //            uint32_t                version;
        //            const CGFloat *         decode;
        //            CGColorRenderingIntent  renderingIntent;
        //        }vImage_CGImageFormat;    CGColorSpaceRef
        
        /*
         *  <pre>@textblock
         *      vImage_CGImageFormat srgb888 = (vImage_CGImageFormat){
         *          .bitsPerComponent = 8,kvImage_YpCbCrToARGBMatrix_ITU_R_709_2
         *          .bitsPerPixel = 24,kvImage_ARGBToYpCbCrMatrix_ITU_R_709_2
         *          .colorSpace = NULL,kvImage_ARGBToYpCbCrMatrix_ITU_R_601_4
         *          .bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault };kvImage_YpCbCrToARGBMatrix_ITU_R_601_4
         *  @/textblock</pre>
         */
    }
    vImageCVImageFormatRef srcFormat = vImageCVImageFormat_Create(kCVPixelFormatType_420YpCbCr8Planar, kvImage_ARGBToYpCbCrMatrix_ITU_R_601_4, kCVImageBufferChromaLocation_Center,
//                                                                  CGColorSpaceCreateWithName(kCGColorSpaceSRGB),
                                                                  CGColorSpaceCreateDeviceRGB(),
                                                                  0);
//    NSLog(@"%@",srcFormat);
    vImage_CGImageFormat destformat;
    destformat.bitsPerComponent = 8;
    destformat.bitsPerPixel = 32;
    destformat.colorSpace = CGColorSpaceCreateDeviceRGB();
    //    destformat.bitmapInfo = kCGBitmapByteOrder32Little;
    destformat.bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast;
    destformat.version = 0;
    destformat.decode = NULL;
    //    destformat.renderingIntent = kCGRenderingIntentDefault;
    const CGFloat backgroundColor[] = {1.0,1.0,1.0};
    vImage_Error err;
    
    /*
     VIMAGE_PF vImageConverterRef vImageConverter_CreateForCVToCGImageFormat( vImageCVImageFormatRef srcFormat,
     const vImage_CGImageFormat *destFormat,
     const CGFloat *backgroundColor,
     vImage_Flags flags,
     vImage_Error *error )
     */
    vImageConverterRef converter = vImageConverter_CreateForCVToCGImageFormat(srcFormat, &destformat, backgroundColor, kvImageNoFlags, &err);
//    NSLog(@"converter === %@",converter);
//    NSLog(@"%d",err);
    if (err != 0) {
        NSLog(@"创建转换器失败");
        return;
    }
    
//    typedef struct vImage_Buffer
//    {
//        void                *data;        /* Pointer to the top left pixel of the buffer.    */
//        vImagePixelCount    height;       /* The height (in pixels) of the buffer        */
//        vImagePixelCount    width;        /* The width (in pixels) of the buffer         */
//        size_t              rowBytes;     /* The number of bytes in a pixel row, including any unused space between one row and the next. */
//    }vImage_Buffer;
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"yuv_1920_1080" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:file];
    int width = 1920;
    int height = 1080;
    void *ydata = malloc(width * height);
    void *udata = malloc(width * height / 4);
    void *vdata = malloc(width * height / 4);
    [data getBytes:ydata range:NSMakeRange(0, width * height)];
    [data getBytes:udata range:NSMakeRange(width * height, width * height / 4)];
    [data getBytes:vdata range:NSMakeRange(width * height * 5 / 4, width * height / 4)];
    uint8_t *ydatat = ydata;
    uint8_t *udatat = udata;
    uint8_t *vdatat = vdata;
    printf("====%d====%d===%d=",ydatat[0],udatat[0],vdatat[0]);
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
    
    vImage_Buffer srcsBuffs[] = {srcsBuff_y,srcsBuff_u,srcsBuff_v};
    
//    void *dest3 = malloc(width * height);
    vImage_Buffer destsBuff3;
//    destsBuff3.data = dest3;
    destsBuff3.height = height;
    destsBuff3.width = width;
    destsBuff3.rowBytes = width * 4;
    
    
    vImage_Error init = vImageBuffer_Init(&destsBuff3, height, width, 32, kvImageNoFlags);
    
    if (init != 0) {
        NSLog(@"失败");
        return;
    }
    NSLog(@"%d===%d===%d",destsBuff3.height,destsBuff3.width,destsBuff3.rowBytes);
    vImage_Error result = vImageConvert_AnyToAny(converter, srcsBuffs, &destsBuff3, NULL, kvImageNoFlags);
//    var infoYpCbCrToARGB = vImage_YpCbCrToARGB()
    vImage_YpCbCrToARGB infoyuvoargb;
    
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
    
    vImageConvert_420Yp8_Cb8_Cr8ToARGB8888(&srcsBuff_y, &srcsBuff_u, &srcsBuff_v, &destsBuff3, &infoyuvoargb, nil, 255, kvImagePrintDiagnosticsToConsole);
//     vImageConvert_420Yp8_CbCr8ToARGB8888(&sourceLumaBuffer,
//                                                 &sourceChromaBuffer,
//                                                 &destinationBuffer,
//                                                 &infoYpCbCrToARGB,
//                                                 nil,
//                                                 255,
//                                                 vImage_Flags(kvImagePrintDiagnosticsToConsole))
    
    
    
    if (result != 0) {
        NSLog(@"转换失败");
        return;
    }
    uint8_t *test = destsBuff3.data;

    double startTime = CFAbsoluteTimeGetCurrent();
    uint8_t tem;
    for (int i = 0; i < width * height * 4; ) {
        tem = test[i + 1];
        test[i + 1] = test[i + 3];
        test[i + 3] = tem;
        i += 4;
    }
    double endTime = CFAbsoluteTimeGetCurrent();
    double time = endTime - startTime;
    NSLog(@"%f    ffff",time);
    for (int i = 0; i < 200; i++) {
        printf(" %d  ",(int)test[i]);
    }
    UIImage *image = [ESCUIImageToDataTool getImageFromRGBAData:test width:width height:height];
    NSLog(@"ffff   %@",image);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(200,300,180 ,250);
        [self.view addSubview:imageView];
    });
    
}

- (UIImage *)mz_convertToSRGBColorSpace
{
    UIImage *newImage = [[UIImage alloc] init];
    do {
        CGImageRef CGImage = newImage.CGImage;
        CGColorSpaceRef srcSpace = CGImageGetColorSpace(CGImage);
        CGColorSpaceRef dstSpace = [UIDevice currentDevice].systemVersion.floatValue >= 9.0 ? CGColorSpaceCreateWithName(kCGColorSpaceSRGB) : CGColorSpaceCreateDeviceRGB();
        
        // 颜色空间一样直接返回 self
        if (CFEqual(srcSpace, CFAutorelease(CGColorSpaceCreateDeviceRGB())) ||
            CFEqual(srcSpace, dstSpace)) {
            CGColorSpaceRelease(dstSpace);
            break;
        }
        
        vImage_Buffer srcBuffer;
        vImage_Buffer dstBuffer;
        
        vImage_CGImageFormat srcFormat = {
            .bitsPerComponent       = (uint32_t)CGImageGetBitsPerComponent(CGImage),
            .bitsPerPixel           = (uint32_t)CGImageGetBitsPerPixel(CGImage),
            .colorSpace             = srcSpace,
            .bitmapInfo             = CGImageGetBitmapInfo(CGImage)
        };
        vImage_CGImageFormat dstFormat = {
            .bitsPerComponent       = (uint32_t)CGImageGetBitsPerComponent(CGImage),
            .bitsPerPixel           = (uint32_t)CGImageGetBitsPerPixel(CGImage),
            .colorSpace             = dstSpace,
            .bitmapInfo             = CGImageGetBitmapInfo(CGImage)
        };
        
        vImage_Error error = kvImageNoError;
        
        error = vImageBuffer_InitWithCGImage(&srcBuffer, &srcFormat, NULL, CGImage, kvImageNoFlags);
        if (error != kvImageNoError) {
            CGColorSpaceRelease(dstSpace);
            break;
        }
        
        vImageConverterRef convertRef = vImageConverter_CreateWithCGImageFormat(&srcFormat, &dstFormat, NULL, kvImageNoFlags, &error);
        if (error != kvImageNoError) {
            free(srcBuffer.data);
            CGColorSpaceRelease(dstSpace);
            break;
        }
        
        error = vImageBuffer_Init(&dstBuffer, srcBuffer.height, srcBuffer.width, dstFormat.bitsPerPixel, kvImageNoFlags);
        if (error != kvImageNoError) {
            free(srcBuffer.data);
            CGColorSpaceRelease(dstSpace);
            vImageConverter_Release(convertRef);
            break;
        }
        
        error = vImageConvert_AnyToAny(convertRef, &srcBuffer, &dstBuffer, NULL, kvImageNoFlags);
        if (error != kvImageNoError) {
            free(srcBuffer.data);
            free(dstBuffer.data);
            CGColorSpaceRelease(dstSpace);
            vImageConverter_Release(convertRef);
            break;
        }
        
        CGImageRef newCGImage = vImageCreateCGImageFromBuffer(&dstBuffer, &dstFormat, NULL, NULL, kvImageNoFlags, &error);
        if (error != kvImageNoError) {
            if (newCGImage) {
                CGImageRelease(newCGImage);
            }
            free(srcBuffer.data);
            free(dstBuffer.data);
            CGColorSpaceRelease(dstSpace);
            vImageConverter_Release(convertRef);
            break;
        }
        newImage = [UIImage imageWithCGImage:newCGImage];
        
        free(srcBuffer.data);
        free(dstBuffer.data);
        CGImageRelease(newCGImage);
        CGColorSpaceRelease(dstSpace);
        vImageConverter_Release(convertRef);
        
    } while(0);
    return newImage;
}

@end
