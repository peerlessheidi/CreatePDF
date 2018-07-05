//
//  UIView+Category.m
//
//
//  Created by Long on 2017/3/3.
//  Copyright © 2017年 Long. All rights reserved.
//

#import "UIView+Category.h"
//#import <Masonry.h>

@implementation UIView (Category)

#pragma mark - setter

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (void)setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

#pragma mark - getter

- (CGFloat)centerX {
    return self.center.x;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (CGFloat)top {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)left {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)right {
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGSize)size {
    return self.frame.size;
}

#pragma mark - masonry


#pragma mark - method
/**
 用途：根据子视图的高度来计算确定父视图的高度
 原理：遍历父视图中的所用子视图进行比较，获取最底部子视图Frame的最大值
 @param view 父视图
 @return bottom
 */
+ (CGFloat)bottomViewGetMaxY:(UIView *)view {
    NSArray *views= [view.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *view1 , UIView * view2){
        NSString * top1 = [NSString stringWithFormat:@"%f",view1.frame.origin.y];
        NSString * top2 = [NSString stringWithFormat:@"%f",view2.frame.origin.y];
        NSComparisonResult result = [top1 compare:top2 options:NSNumericSearch];
        // 降序从小到大
        return result == NSOrderedDescending;
    }];
    UIView * bottomView = views.lastObject;
    return bottomView.frame.origin.y+bottomView.frame.size.height;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentViewController {
    return [self getConfigViewController];
}

/**
 *  返回当前视图的控制器
 */
- (UIViewController *)getConfigViewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

#pragma mark - 添加一组子view：
- (void)addSubviewsWithArray:(NSArray *)subViews {
    
    for (UIView *view in subViews) {
        
        [self addSubview:view];
    }
}

- (void)drawLayerRadius:(CGFloat)radius shadowColor:(UIColor *)color {

    [self drawLayerRadius:radius shadowColor:color shadowOffset:CGSizeMake(0, 0)];
}

- (void)drawLayerRadius:(CGFloat)radius shadowColor:(UIColor *)color
           shadowOffset:(CGSize)offset {
    [self drawLayerRadius:radius shadowColor:color shadowOffset:offset shadowRadius:10];
}

- (void)drawLayerRadius:(CGFloat)radius shadowColor:(UIColor *)color
           shadowOffset:(CGSize)offset
           shadowRadius:(CGFloat)shadowRadius {
    
    //    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    //    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    //    maskLayer.frame = self.bounds;
    //    maskLayer.path = maskPath.CGPath;
    //    self.layer.mask = maskLayer;
    
    self.layer.cornerRadius = radius;
    /**< 创建UIBezierPath的对象 指定path对象
     * 参考的坐标系是要设置阴影的视图
     */
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;;
        // 不透明度
    self.layer.shadowOpacity = 0.6;
        // 阴影圆角半径
    self.layer.shadowRadius = shadowRadius;
        // 阴影颜色
    self.layer.shadowColor = [color CGColor];
        // 阴影offset
    self.layer.shadowOffset = offset;
    
}

- (void)drawGradientLayerColors:(NSArray <UIColor *>*)colors loctions:(NSArray <NSNumber *>*)loctions dirction:(DQGradientLayerDirection)direction {
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
         [colorArray addObject:(id)[color CGColor]];
    };
    NSArray *colorLocArray = loctions;
    
    // 渐变条
    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    // 设置渐变的颜色组
    [gradientLayer setColors:colorArray];
    // 设置渐变颜色的分割点
    [gradientLayer setLocations:colorLocArray];
    // 颜色渐变的方向，范围在(0,0)与(1.0,1.0)之间，如(0,0)(1.0,0)代表水平方向渐变,(0,0)(0,1.0)代表竖直方向渐变
    CGPoint start = CGPointZero;
    CGPoint end   = CGPointZero;
    
    if (direction == DQDirectionLeftToRight) {
        start = CGPointMake(0.0, 0.0);
        end   = CGPointMake(1.0, 0.0);
    }
    else if (direction == DQDirectionTopToBottom) {
        start = CGPointMake(0.0, 0.0);
        end   = CGPointMake(0.0, 1.0);
    }
    else if (direction == DQDirectionLeftTopToRightBottom) {
        start = CGPointMake(0.0, 0.0);
        end   = CGPointMake(1.0,1.0);
    }
    else if (direction == DQDirectionLeftBottomToRightTop) {
        start = CGPointMake(0.0, 1.0);
        end   = CGPointMake(1.0,0.0);
    }
    else { // 默认水平方向
        start = CGPointMake(0, 0);
        end   = CGPointMake(1, 0);
    }
    
    [gradientLayer setStartPoint:start];
    [gradientLayer setEndPoint:end];
    // 通过mask控制显示位置
    [self.layer addSublayer:gradientLayer];
}

/** 将View生成一张截图 */
- (UIImage *)dq_snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
