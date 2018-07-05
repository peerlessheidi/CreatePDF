//
//  ViewController.h
//  CreatePDF
//
//  Created by Heidi on 2018/7/5.
//  Copyright © 2018年 Heidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

@interface ScanDocController : UIViewController

/** 传入PDF文件的名称 */
@property (nonatomic, copy) NSString *pdfName;

/** 扫描生成之后返回本地路径 */
@property (nonatomic, copy) ResultBlock finished;

@end

