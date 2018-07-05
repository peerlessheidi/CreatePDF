//
//  DQFileManager.h
//  WebThings
//
//  Created by Heidi on 2017/10/20.
//  Copyright © 2017年 machinsight. All rights reserved.
//

#ifndef DQFileManager_h
#define DQFileManager_h

@interface DQFileManager : NSObject

/** 沙盒目录说明：
 Application：存放程序源文件，上架前经过数字签名，上架后不可修改
 Documents：常用目录，iCloud备份目录，存放数据,这里不能存缓存文件,否则上架
 不被通过
 Library:
 &Caches：存放体积大又不需要备份的数据,比如下载的音乐,视频,SDWebImage缓存等
 &Preference：设置目录，iCloud会备份设置信息
 tmp：存放临时文件，不会被备份，而且这个文件下的数据有可能随时被清除的可能
 */
+ (DQFileManager *)sharedInstance;

/** 获取沙盒根目录 */
- (NSString *)dq_homePth;

/** 获取Documents目录 */
- (NSString *)dq_documentPath;

/** 获取Library目录 */
- (NSString *)dq_libraryPath;

/** 获取Cache目录 */
- (NSString *)dq_cachePath;

/** 获取tmp目录 */
- (NSString *)dq_tmpPath;

/** 创建大器根目录文件夹 */
- (void)dq_createFolder;

/** 在大器根目录下创建文件夹 */
- (void)dq_createFolderWithPath:(NSString *)path;

/** 创建文件 */
- (void)dq_createFile:(NSString *)path;

/** 删除文件 */
- (void)dq_deleteFileWithPath:(NSString *)path;

/** 删除目录 */
- (void)dq_deleteFoldWithPath:(NSString *)path;

/** 判断大器文件夹下的pdf文件是否存在 */
- (BOOL)dq_existAtPath:(NSString *)filePath;

/** 计算目录该下的大小（M） */
- (double)dq_folderSizeAtPath:(NSString *)path;

/** 清空图片和PDF缓存 */
- (void)dq_clearCache;

@end

#endif /* DQFileManager_h */
