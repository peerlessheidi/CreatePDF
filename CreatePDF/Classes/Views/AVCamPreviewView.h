//
//  AVCamPreviewView.h
//  CreatePDF
//
//  Created by Heidi on 2018/7/5.
//  Copyright © 2018年 Heidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureSession.h>

@interface AVCamPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) AVCaptureSession *session;

@end
