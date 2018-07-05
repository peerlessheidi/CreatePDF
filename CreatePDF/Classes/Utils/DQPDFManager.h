//
//  DQPDFManager.h
//  WebThings
//
//  Created by Heidi on 2017/10/20.
//  Copyright © 2017年 machinsight. All rights reserved.
//

#ifndef DQPDFManager_h
#define DQPDFManager_h

@interface DQPDFManager : NSObject

+ (DQPDFManager *)sharedInstance;

/** 获取PDF目录 */
- (NSString *)dq_getFileDirector;

/** 生成PDF */
- (void)dq_createPDFWithName:(NSString *)pdfName
                      images:(NSArray *)images;

/** 获取PDF地址 */
- (NSString *)dq_getFilePathWithName:(NSString *)name;

/** 获取PDF数据 */
- (NSData *)dq_getFileDataWithName:(NSString *)name;

@end

#endif /* DQPDFManager_h */
