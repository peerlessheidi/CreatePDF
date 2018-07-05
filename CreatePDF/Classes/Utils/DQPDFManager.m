//
//  DQPDFManager.m
//  WebThings
//
//  Created by Heidi on 2017/10/20.
//  Copyright © 2017年 machinsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DQPDFManager.h"
#import <CoreText/CoreText.h>

#import "DQFileManager.h"

@implementation DQPDFManager

+ (DQPDFManager *)sharedInstance
{
    static DQPDFManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DQPDFManager alloc] init];
    });
    return sharedInstance;
}

/** 获取PDF目录 */
- (NSString *)dq_getFileDirector {
    DQFileManager *fileManager = [DQFileManager sharedInstance];
    NSString *path = [[fileManager dq_cachePath]
                      stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@/file", kFOLDERNAME]];
    return path;
}

/** 获取文件地址 */
- (NSString *)dq_getFilePathWithName:(NSString *)name {
    if (![name hasSuffix:@".pdf"]) {
        name = [name stringByAppendingString:@".pdf"];
    }
    DQFileManager *fileManager = [DQFileManager sharedInstance];
    NSString *path = [[fileManager dq_cachePath]
                      stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@/file/%@", kFOLDERNAME, name]];
    return path;
}

/** 获取PDF数据 */
- (NSData *)dq_getFileDataWithName:(NSString *)name {
    NSString *path = [self dq_getFilePathWithName:name];
    DQFileManager *fileManager = [DQFileManager sharedInstance];

    if ([fileManager dq_existAtPath:path]) {
        NSData *pdfData = [NSData dataWithContentsOfFile:path];
        return pdfData;
    }
    return nil;
}

/** 生成PDF */
- (void)dq_createPDFWithName:(NSString *)name
                      images:(NSArray *)images {

    DQFileManager *fileManager = [DQFileManager sharedInstance];
    NSString *pdfFileName = [self dq_getFilePathWithName:name];
    NSMutableData *pdfData = [NSMutableData data];
    
    // PDF上下文，default page size of 612 x 792.
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);

    CGFloat width = SCREEN_WIDTH;
    CGFloat height = 0;
    
    // 压缩图片尺寸和大小
    NSMutableArray *compressImages = [NSMutableArray arrayWithCapacity:0];
    for (UIImage *image in images) {
        [compressImages addObject:image];
        height += image.size.height * SCREEN_WIDTH/image.size.width;
    }
    CGRect mediaBox = CGRectMake(0, 0, width, height);
    
    NSMutableData *pdfFile = [[NSMutableData alloc] init];
    CGDataConsumerRef pdfConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfFile);
    
    CGContextRef pdfContext = CGPDFContextCreate(pdfConsumer, &mediaBox, NULL);
    for (UIImage *image in compressImages) {
        
        double pageWidth = SCREEN_WIDTH;
        double pageHeight = image.size.height * SCREEN_WIDTH/image.size.width;
        CGRect rect = CGRectMake(0, 0, pageWidth, pageHeight);
        
        // pdf单页绘制
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageWidth, pageHeight), nil);
        CGContextBeginPage(pdfContext, &rect);
        [image drawInRect:rect blendMode:kCGBlendModeScreen alpha:1.0];
    }

    UIGraphicsEndPDFContext();
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(pdfConsumer);

    [fileManager dq_createFile:pdfFileName];
    BOOL success = [pdfData writeToFile:pdfFileName atomically:NO];
    if (success) {
//        NSLog(@"pdf写入成功");
    } else {
//        NSLog(@"pdf写入失败");
    }
}

@end
