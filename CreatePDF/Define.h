//
//  Define.h
//  CreatePDF
//
//  Created by Heidi on 2018/7/5.
//  Copyright © 2018年 Heidi. All rights reserved.
//

#ifndef Define_h
#define Define_h

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

typedef NS_ENUM(uint8_t, MOVRotateDirection)
{
    MOVRotateDirectionNone = 0,
    MOVRotateDirectionCounterclockwise90,
    MOVRotateDirectionCounterclockwise180,
    MOVRotateDirectionCounterclockwise270,
    MOVRotateDirectionUnknown
};

typedef void (^ResultBlock) (NSString *localURL);
typedef void (^ClipBlock) (UIImage *image);

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// 由角度转换弧度
#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
// 由弧度转换角度
#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)

#endif /* Define_h */
