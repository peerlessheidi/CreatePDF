//
//  DQClipImageController.h
//  WebThings
//  剪切图片
//  Created by Heidi on 2017/10/16.
//  Copyright © 2017年 machinsight. All rights reserved.
//

#ifndef DQClipImageController_h
#define DQClipImageController_h

#import "Define.h"
#import "CXCliper.h"

@interface DQClipImageController : UIViewController
{
    UIView *_cropView;
    UIImageView *_imageView;
    CXCliper *_cliper;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect clipRect;
@property (nonatomic, copy) ClipBlock clipFinished;

@end

#endif /* DQClipImageController_h */
