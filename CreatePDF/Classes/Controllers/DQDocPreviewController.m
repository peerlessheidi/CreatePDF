//
//  DQDocPreviewController.m
//  WebThings
//  生成文档并预览
//  Created by Heidi on 2017/10/9.
//  Copyright © 2017年 machinsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<WebKit/WebKit.h>
#import <CoreText/CoreText.h>

#import "DQDocPreviewController.h"
#import "DQPDFManager.h"
#import "AppDelegate.h"

@interface DQDocPreviewController ()
<WKNavigationDelegate,
UIDocumentInteractionControllerDelegate,
UIScrollViewDelegate>
{
    WKWebView *_webView;
//    UILabel *_lblPage;
//    NSInteger _totalPage;
}

@end

@implementation DQDocPreviewController

#pragma mark - Init
- (void)initSubViews {
    CGFloat height = SCREEN_HEIGHT;

    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.scrollView.backgroundColor = [UIColor clearColor];
    _webView.scrollView.opaque = 0;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = 0;
    _webView.navigationDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    [self.view addSubview:_webView];
    
    if (_displayName.length < 1) {
        _displayName = kPDFNAME;
    }
    [self createPDFFile];
    
    NSString *path = [[DQPDFManager sharedInstance] dq_getFilePathWithName:_displayName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSURL *pdfURL = [NSURL fileURLWithPath:path];
//        NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
        //设置缩放
        [_webView loadFileURL:pdfURL allowingReadAccessToURL:pdfURL];
    }
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

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _displayName.length > 0 ? _displayName : @"预览";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"继续扫描" style:UIBarButtonItemStylePlain target:self action:@selector(onBackClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onUploadDocClick)];
    
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - PDF
    
- (void)createPDFFile
{
    NSString *name = _displayName;
    [[DQPDFManager sharedInstance] dq_createPDFWithName:name images:_images];
}

#pragma mark - Button clicks
// 完成
- (void)onBackClick {
    [self.navigationController popViewControllerAnimated:YES];
}

// 上传文档
- (void)onUploadDocClick {
    NSString *path = [[DQPDFManager sharedInstance] dq_getFilePathWithName:_displayName];
    if (!_shouldUpload) {
        if (self.uploadAction) {
            self.uploadAction(path);
            
            NSLog(@"本地已有的PDF地址：%@", path);
        }
        return;
    }
}

#pragma mark - UIDocumentInteractionController 代理方法
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}
    
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    return self.view;
}
    
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller{
    return self.view.bounds;
}

#pragma mark -  WKNavigationDelegate来追踪加载过程
/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
/// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}
/// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:[self getAppWindow] animated:YES];
}
/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:[self getAppWindow] animated:YES];
}

- (UIWindow *)getAppWindow {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return app.window;
}

@end
