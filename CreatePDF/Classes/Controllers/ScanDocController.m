//
//  ViewController.m
//  CreatePDF
//
//  Created by Heidi on 2018/7/5.
//  Copyright © 2018年 Heidi. All rights reserved.
//

#import "ScanDocController.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>
#import <CoreMotion/CoreMotion.h>

#import "UIView+Category.h"
#import "CVPixelBufferUtils.h"

#import "AVCamPreviewView.h"
#import "DQClipImageController.h"

@interface ScanDocController ()
<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    UIView *_topActionBtnView;      // 关闭和闪光灯按钮
    UIButton *_btnTakePhoto;        // 拍照按钮
    UIButton *_btnCancel;
    UIButton *_btnAlbum;            // 相册
    
    UIImageView *_highlightView;    // 展示摄像头视频
    
    AVCaptureSession *_captureSession;
    NSUInteger _counter;
    
    UIButton *_btnChoosed;     // 右下角已选好的
    UILabel *_lblBadge;             // 角标，已选几张图
    NSMutableArray *_arrayImages;   // 已选择的图片
    CGRect _rectRecognized;         // 已识别的区域
    
    BOOL _isLightON;    // 闪光灯开启
    
    double _motionX;
    double _motionY;
    double _motionZ;
    
    UILabel *_lblTips;      // 相机使用权限关闭时的提示
}

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) AVCamPreviewView *preView;
@property (nonatomic, strong) UIImage *capturedImage;

/// 传感器
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation ScanDocController

#pragma mark - Init
- (void)initSubViews {
    CGFloat width = SCREEN_WIDTH;
    
    self.preView = [[AVCamPreviewView alloc] initWithFrame:
                    CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.preView];
    
    _highlightView = [[UIImageView alloc] initWithFrame:_preView.frame];
    _highlightView.contentMode = UIViewContentModeScaleAspectFit;
    _highlightView.backgroundColor = [UIColor clearColor];
    _highlightView.userInteractionEnabled = YES;
    [self.view addSubview:_highlightView];
    
    // 操作过程中的按钮层
    _topActionBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, width, 40)];
    [self.view addSubview:_topActionBtnView];
    
    _btnCancel = [self
                  buttonWithTitle:nil
                  icon:@"icon_close_white"
                  sel:@selector(onCancelClick)
                  frame:CGRectMake(0, _topActionBtnView.bottom - 44 , 58, 44)];
    [_topActionBtnView addSubview:_btnCancel];
    
    UIButton *btnFlash = [self
                          buttonWithTitle:nil
                          icon:@"icon_flash"
                          sel:@selector(onFlashLightClick)
                          frame:CGRectMake(width - 58, _btnCancel.top, 58, _btnCancel.height)];
    [_topActionBtnView addSubview:btnFlash];
    
    // 相册
    _btnAlbum = [self
                 buttonWithTitle:nil
                 icon:@"icon_album_white"
                 sel:@selector(onAlbumClick)
                 frame:CGRectMake(20, self.view.frame.size.height - 88,
                                  40, 40)];
    [self.view addSubview:_btnAlbum];
    
    // 拍照按钮
    _btnTakePhoto = [self
                     buttonWithTitle:nil
                     icon:@"icon_takephoto"
                     sel:@selector(onTakePhotoClick)
                     frame:CGRectMake(width/2.0 - 40,
                                      self.view.frame.size.height - (88 + 40),
                                      80, 80)];
    [self.view addSubview:_btnTakePhoto];
    _btnAlbum.centerY = _btnTakePhoto.centerY;
    
    _btnChoosed = [self buttonWithTitle:nil
                                   icon:nil sel:@selector(onPreviewPicClick)
                                  frame:CGRectMake(width - 56, SCREEN_HEIGHT - 56, 40, 40)];
    _btnChoosed.layer.cornerRadius = 5.0;
    _btnChoosed.layer.masksToBounds = YES;
    _btnChoosed.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_btnChoosed];
    _btnChoosed.hidden = YES;
    
    _lblBadge = [[UILabel alloc] initWithFrame:
                 CGRectMake(width - 23, _btnChoosed.frame.origin.y - 7, 14, 14)];
    _lblBadge.backgroundColor = [UIColor redColor];
    _lblBadge.font = [UIFont systemFontOfSize:10];
    _lblBadge.textColor = [UIColor whiteColor];
    _lblBadge.layer.cornerRadius = 7.0;
    _lblBadge.layer.masksToBounds = YES;
    _lblBadge.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lblBadge];
    _lblBadge.hidden = YES;
    
    _lblTips = [[UILabel alloc] initWithFrame:
                CGRectMake(20, 88, SCREEN_WIDTH - 40, SCREEN_HEIGHT - 120)];
    _lblTips.font = [UIFont systemFontOfSize:16];
    _lblTips.textColor = [UIColor grayColor];
    _lblTips.numberOfLines = 0;
    _lblTips.lineBreakMode = NSLineBreakByWordWrapping;
    _lblTips.text = @"没有相机使用权限,请在”设置-隐私-相机“中启用";
    _lblTips.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lblTips];
    _lblTips.hidden = YES;
}

// 创建button
- (UIButton *)buttonWithTitle:(NSString *)title
                         icon:(NSString *)iconName
                          sel:(SEL)sel
                        frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title.length > 0) {
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    if (iconName.length > 0) {
        [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    }
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    button.frame = frame;
    
    return button;
}

// 初始化捕捉视频
- (void)initCapture {
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]  error:nil];
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    //captureOutput.minFrameDuration = CMTimeMake(1, 10);
    
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    self.queue = queue;
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:captureInput];
    [_captureSession addOutput:captureOutput];
    
    self.preView.session = _captureSession;
}

- (void)startClip {
    
    CGRect rect = CGRectMake(20, 70, SCREEN_WIDTH - 40, SCREEN_HEIGHT - 100);
    
    if (@available(iOS 11.0, *)) {  // ios11上根据扫描的文字边框设置剪切框
        CGFloat width = _highlightView.frame.size.width;
        CGFloat height = _highlightView.frame.size.height;
        CGFloat x = _rectRecognized.origin.x * width;
        CGFloat imageWidth = width * _rectRecognized.size.width;
        CGFloat imageHeight = height * _rectRecognized.size.height;
        
        CGFloat y = SCREEN_HEIGHT - height * _rectRecognized.origin.y - imageHeight;
        rect = CGRectMake(x, y, imageWidth, imageHeight);
    }
    
    DQClipImageController *ctl = [[DQClipImageController alloc] init];
    ctl.image = self.capturedImage;
    ctl.clipRect = rect;
    ctl.clipFinished = ^(id result1, id result2) {
        [self doFinishAnimationWithImage:@[result1] isScan:YES];
    };
    [self.navigationController pushViewController:ctl animated:NO];
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return (image);
}

- (void)initMotionManager {
    _motionManager = [[CMMotionManager alloc] init];
    //判断传感器是否可用
    if ([self.motionManager isDeviceMotionAvailable]) {
        ///设备 运动 更新 间隔
        _motionManager.deviceMotionUpdateInterval = 1;
        ///启动设备运动更新队列
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                                                    double gravityX = motion.gravity.x;
                                                    double gravityY = motion.gravity.y;
                                                    double gravityZ = motion.gravity.z;
                                                    // 获取手机的倾斜角度(z是手机与水平面的夹角， xy是手机绕自身旋转的角度)：
                                                    //                                                    double z = atan2(gravityZ,sqrtf(gravityX * gravityX + gravityY * gravityY));
                                                    //                                                    double xy = atan2(gravityX, gravityY);
                                                    // 计算相对于y轴的重力方向
                                                    //                                                    _gravityBehavior.angle = xy-M_PI_2;
                                                    _motionX = gravityX;
                                                    _motionY = gravityY;
                                                    _motionZ = gravityZ;
                                                }];
        
    }
}

#pragma mark -
- (void)startCapture {
    [_captureSession startRunning];
    
    // 此操作用来防止摄像头图片未显示时，点击拍照按钮会闪退的问题
    _btnTakePhoto.enabled = NO;
}

- (void)stopCapture {
    [_captureSession stopRunning];
}

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _counter = 1;
    _arrayImages = [NSMutableArray arrayWithCapacity:0];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initSubViews];
    
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted ||
       authStatus == AVAuthorizationStatusDenied) {
        _lblTips.hidden = NO;
        _btnTakePhoto.hidden = YES;
        [_btnCancel setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        return;
    }
    [_btnCancel setImage:[UIImage imageNamed:@"icon_close_white"] forState:UIControlStateNormal];
    _lblTips.hidden = YES;
    _btnTakePhoto.hidden = NO;
    
    [self initCapture];
    [self initMotionManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self startCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopCapture];
    [super viewWillDisappear:animated];
}

#pragma mark AVCaptureSession6 delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (_counter % 10 != 0) {
        _counter ++;
        return;
    }
    _counter = 1;
    
    CVPixelBufferRef rotateBuffer = [CVPixelBufferUtils rotateBuffer:sampleBuffer withConstant:MOVRotateDirectionCounterclockwise270];
    
    if (@available(iOS 11.0, *)) {  // ios11的文字检测功能
        [self detectTextWithPixelBuffer:rotateBuffer];      // 找文字
    } else {
        _btnTakePhoto.enabled = YES;
    }
    self.capturedImage = [[self imageFromSampleBuffer:sampleBuffer] yy_imageByRotateRight90];
    
    CVBufferRelease(rotateBuffer);
}

#pragma mark -
// 使用pixelBuffer进行文字检测
- (void)detectTextWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    void (^ VNRequestCompletionHandler)(VNRequest *request, NSError * _Nullable error) = ^(VNRequest *request, NSError * _Nullable error)
    {
        if (nil == error) {
            
            size_t width = CVPixelBufferGetWidth(pixelBuffer);
            size_t height = CVPixelBufferGetHeight(pixelBuffer);
            CGSize size = CGSizeMake(width, height);
            void (^UIGraphicsImageDrawingActions)(UIGraphicsImageRendererContext *rendererContext) = ^(UIGraphicsImageRendererContext *rendererContext)
            {
                //vision框架使用的坐标是为 0 -》 1， 原点为屏幕的左下角（跟UIKit不同），向右向上增加，其实就是Opengl的纹理坐标系。
                CGAffineTransform  transform = CGAffineTransformIdentity;
                transform = CGAffineTransformScale(transform, size.width, -size.height);
                transform = CGAffineTransformTranslate(transform, 0, -1);
                
                CGFloat minX = 0.0;
                CGFloat minY = 0.0;
                CGFloat maxX = 0.0;
                CGFloat maxY = 0.0;
                
                for (VNTextObservation *textObservation in request.results)
                {
                    //                    [[UIColor blackColor] setStroke];
                    //                    [[UIBezierPath bezierPathWithRect:CGRectApplyAffineTransform(textObservation.boundingBox, transform)] stroke];
                    
                    for (VNRectangleObservation *obj in textObservation.characterBoxes) {
                        //                        [[UIColor redColor] setStroke];
                        //                        [[UIBezierPath bezierPathWithRect:CGRectApplyAffineTransform(obj.boundingBox, transform)] stroke];
                        
                        CGRect rect = obj.boundingBox;
                        if (minX <= 0.0) {
                            minX = rect.origin.x;
                        }
                        if (minY <= 0.0) {
                            minY = rect.origin.y;
                        }
                        if (rect.origin.x > 0.0 && CGRectGetMinX(rect) < minX) {
                            minX = CGRectGetMinX(rect);
                        }
                        if (maxX < CGRectGetMaxX(rect)) {
                            maxX = CGRectGetMaxX(rect);
                        }
                        if (rect.origin.y > 0.0 && CGRectGetMinY(rect) < minY) {
                            if (minY - CGRectGetMinY(rect) > 0.01) {
                                minY = CGRectGetMinY(rect);
                            }
                        }
                        if (maxY < CGRectGetMaxY(rect)) {
                            if (CGRectGetMaxY(rect) < 1.0) {
                                maxY = CGRectGetMaxY(rect);
                            } else {
                                maxY = 1.0;
                            }
                        }
                    }
                }
                
                //                double z = atan2(_motionX, sqrtf(_motionX * _motionX + _motionY * _motionY));
                double xy = atan2(_motionX, _motionY);
                //                NSLog(@"/n*************%f, %f/n", xy, z);
                //                CGRect drawFrame = CGRectMake(minX - 0.05, minY, maxX, maxY - 0.15);
                CGRect drawFrame = CGRectMake(minX, minY, maxX, xy < 1 ? maxY - 0.25 : maxY - 0.15);
                self->_rectRecognized = drawFrame;
                
                UIBezierPath *path = [UIBezierPath
                                      bezierPathWithRect:drawFrame];
                [path setLineWidth:4.0];
                [[UIColor lightGrayColor] setFill];
                [[UIColor blueColor] setStroke];
                [path applyTransform:transform];
                [path stroke];
            };
            
            UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
            UIImage *overlayImage = [renderer imageWithActions:UIGraphicsImageDrawingActions];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self->_btnTakePhoto.enabled) {
                    self->_btnTakePhoto.enabled = YES;
                }
                self->_highlightView.image = overlayImage;
            });
        }
    };
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer options:@{}];
    VNDetectTextRectanglesRequest *request = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:VNRequestCompletionHandler];
    
    request.reportCharacterBoxes = YES;
    
    [handler performRequests:@[request] error:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    
}

/** 图片选择完毕相应处理 isScan：YES.扫描得来图片 NO.从相册  */
- (void)doFinishAnimationWithImage:(NSArray *)imageArray isScan:(BOOL)isScan {
    if ([imageArray count] > 0) {
        UIImage *image = imageArray[0];
        [_arrayImages addObjectsFromArray:imageArray];
        if (isScan) {       // 如果是扫描的结果，则保存到相册
            // 将图片保存到相册
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        }
        
        // 设置图片数量角标数字
        NSString *str = [NSString stringWithFormat:@"%ld", [_arrayImages count]];
        if ([_arrayImages count] > 9) {
            _lblBadge.frame = CGRectMake(SCREEN_WIDTH - 29,
                                         _btnChoosed.frame.origin.y - 7, 22, 14);
        }
        else if ([_arrayImages count] > 99) {
            str = @"99+";
        }
        _lblBadge.text = str;
        
        if (!isScan) {
            _btnChoosed.hidden = NO;
            _lblBadge.hidden = NO;
            [_btnChoosed setBackgroundImage:image forState:UIControlStateNormal];
            [self startCapture];
            return;
        }
        // 做图片动画
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, image.size.width * SCREEN_HEIGHT/image.size.height);
        [self.view addSubview:imgView];
        
        [self.view bringSubviewToFront:imgView];
        
        [UIView animateWithDuration:0.6 animations:^{
            imgView.frame = _btnChoosed.frame;
        } completion:^(BOOL finished) {
            if (finished) {
                _btnChoosed.hidden = NO;
                _lblBadge.hidden = NO;
                imgView.hidden = YES;
                [imgView removeFromSuperview];
                
                [_btnChoosed setBackgroundImage:image forState:UIControlStateNormal];
                [self startCapture];
            }
        }];
    }
}

#pragma mark - Button clicks
// 取消按钮
- (void)onCancelClick {
    [self.navigationController popViewControllerAnimated:YES];
}

// 拍照
- (void)onTakePhotoClick {
    [self stopCapture];
    [self startClip];
}

// 闪光灯按钮
- (void)onFlashLightClick {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (_isLightON) {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                _isLightON = NO;
            } else {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                _isLightON = YES;
            }
            [device unlockForConfiguration];
        }
    }
}

// 重拍
- (void)onReTakeClick {
    [self startCapture];
}

// 从相册选择
- (void)onAlbumClick {
    [self stopCapture];
    
    DQPhotoActionSheetManager *manager = [[DQPhotoActionSheetManager alloc] init];
    [manager dq_showPhotoActionSheetWithController:self
                                  showPreviewPhoto:NO
                                    maxSelectCount:100
                                 didSelectedImages:^(NSArray<UIImage *> *images) {
                                     [self doFinishAnimationWithImage:images isScan:NO];
                                 }];
}

// 预览文档
- (void)onPreviewPicClick {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [MBProgressHUD showHUDAddedTo:app.window animated:YES];
    
    NSString *date = [[NSDate date] mdStringWithFormat:@"MMdd"];
    NSString *pdfName = [DQRunningUtils dq_displayNameWithLogic:_logicModel pdfName:_pdfName date:date];
    if (_pdfNumber > 0) {
        if ([pdfName containsString:@" ∙ "]) {
            pdfName = [pdfName
                       stringByReplacingOccurrencesOfString:@" ∙ "
                       withString:[NSString stringWithFormat:@"%ld ∙ ", _pdfNumber + 1]];
        } else {
            pdfName = [pdfName stringByAppendingFormat:@"%ld", _pdfNumber + 1];
        }
    }
    //DQFlowType flow = _logicModel.nodeType;
    DQDocPreviewController *ctl = [[DQDocPreviewController alloc] init];
    ctl.images = _arrayImages;
    ctl.displayName = pdfName;
    ctl.logicModel = _logicModel;
    // 启租单/停租单/维修完成单/保养完成单/加高完成单只返回本地路径，回到提交页面上传文件
    BOOL noUpload = YES;//flow == DQFlowTypeRent || flow == DQFlowTypeRemove
    //    || flow == DQFlowTypeMaintain || flow == DQFlowTypeFix || flow == DQFlowTypeHeighten;
    
    ctl.shouldUpload = !noUpload;
    ctl.uploadAction = ^(id result) {
        if (self.uploadAction) {
            self.uploadAction(result, pdfName);
        }
    };
    [self.navigationController pushViewController:ctl animated:NO];
}

@end
