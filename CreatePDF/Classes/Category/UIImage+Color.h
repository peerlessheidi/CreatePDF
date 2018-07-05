//
//  UIImage+Color.h
//
//  Created by Heidi on 17/12/1.
//  Copyright © 2017年 Macinsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

/** 根据颜色生成纯色图片 */
+ (UIImage *)dq_imageWithColor:(UIColor *)color;

/** 取图片某一像素的颜色 */
- (UIColor *)dq_colorAtPixel:(CGPoint)point;

/** 获得灰度图 */
- (UIImage *)dq_convertToGrayImage;

/** 滤镜处理图片 */
- (UIImage *)dq_sharpImage;

/** 将图片旋转degrees角度 */
- (UIImage *)dq_imageRotatedByDegrees:(CGFloat)degrees;

/** 将图片旋转radians弧度 */
- (UIImage *)dq_imageRotatedByRadians:(CGFloat)radians;

/** 生成指定透明度颜色的图片 */
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;

/** 获取图片的主色调 */
- (UIColor *)dq_mostOfColorWithAlpha:(CGFloat)alpha;

/** 压缩图片至指定大小 */
+ (UIImage *)dq_compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;

@end
