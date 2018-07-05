//
//  UIView+Category.h
//
//  Created by Long on 2017/3/3.
//  Copyright © 2017年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DQGradientLayerDirection) {// 渐变层渐变方向
    DQDirectionLeftToRight = 0,// 左->右
    DQDirectionTopToBottom,// 上->下
    DQDirectionLeftTopToRightBottom,// 左上->右下
    DQDirectionLeftBottomToRightTop// 左下->右上
};

@interface UIView (Category)

@property(assign, nonatomic) CGFloat centerX;
@property(assign, nonatomic) CGFloat centerY;

@property(assign, nonatomic) CGFloat top;
@property(assign, nonatomic) CGFloat left;
@property(assign, nonatomic) CGFloat bottom;
@property(assign, nonatomic) CGFloat right;

@property(assign, nonatomic) CGFloat width;
@property(assign, nonatomic) CGFloat height;

@property(assign, nonatomic) CGPoint origin;
@property(assign, nonatomic) CGSize  size;

 /**
 用途：根据子视图的高度来计算确定父视图的高度
 原理：遍历父视图中的所用子视图进行比较，获取最底部子视图Frame的最大值
 @param view 父视图
 @return bottom
 */
+ (CGFloat)bottomViewGetMaxY:(UIView *)view;

/** 获取当前view 所在的ViewController */
- (UIViewController *)getCurrentViewController;
- (UIViewController *)getConfigViewController;

/// 移除所有子视图
- (void)removeAllSubviews;

/// 添加一组视图
- (void)addSubviewsWithArray:(NSArray *)subViews;

/** 绘制圆角+阴影
 * 默认shadowOffset 的为CGSizeMake(0,0); 四边都有阴影
 */
- (void)drawLayerRadius:(CGFloat)radius shadowColor:(UIColor *)color;
- (void)drawLayerRadius:(CGFloat)radius shadowColor:(UIColor *)color
           shadowOffset:(CGSize)offset;
- (void)drawLayerRadius:(CGFloat)radius shadowColor:(UIColor *)color
           shadowOffset:(CGSize)offset shadowRadius:(CGFloat)shadowRadius;

/** 绘制渐变层
 * colors 渐变色数组
 * loctions 渐变色位置数组
 * direction 渐变色方向
 */
- (void)drawGradientLayerColors:(NSArray <UIColor *>*)colors
                       loctions:(NSArray <NSNumber *>*)loctions
                       dirction:(DQGradientLayerDirection)direction;

/** 将View生成一张截图 */
- (UIImage *)dq_snapshot;

@end
