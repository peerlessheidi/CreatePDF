//
//  DQDocPreviewController.h
//  WebThings
//  生成文档并预览
//  Created by Heidi on 2017/10/9.
//  Copyright © 2017年 machinsight. All rights reserved.
//

#ifndef DQDocPreviewController_h
#define DQDocPreviewController_h

#import "Define.h"
@class DQLogicServiceBaseModel;

@interface DQDocPreviewController : UIViewController

/** 如果传入图片，则生成PDF保存在本地 */
@property (nonatomic, strong) NSArray *images;
/** 用于显示的pdf名称 */
@property (nonatomic, copy) NSString *displayName;
/** 是否上传给服务器，默认为false */
@property (nonatomic, assign) BOOL shouldUpload;

/** 如果shouldUpload=YES，则上传成功后用此回调，反之返回本地保存的路径 */
@property (nonatomic, copy) ResultBlock uploadAction;

@end

#endif /* DQDocPreviewController_h */
