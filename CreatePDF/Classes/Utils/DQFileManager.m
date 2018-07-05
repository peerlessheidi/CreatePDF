//
//  DQFileManager.m
//  WebThings
//
//  Created by Heidi on 2017/10/20.
//  Copyright © 2017年 machinsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DQFileManager.h"
#import <CoreText/CoreText.h>
#import "YYImageCache.h"
#import <YYCache/YYCache.h>
#import "YYWebImageManager.h"

#import "DQPDFManager.h"

@implementation DQFileManager

+ (DQFileManager *)sharedInstance
{
    static DQFileManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DQFileManager alloc] init];
    });
    return sharedInstance;
}

/** 获取沙盒根目录 */
- (NSString *)dq_homePth {
    NSString *directoryHome = NSHomeDirectory();
    return directoryHome;
}

/** 获取Documents目录 */
- (NSString *)dq_documentPath {
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

/** 获取Library目录 */
- (NSString *)dq_libraryPath {
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                         NSUserDomainMask, YES);
    
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return libraryDirectory;
}

/** 获取Cache目录 */
- (NSString *)dq_cachePath {
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                           NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    return cachePath;
}

/** 获取tmp目录 */
- (NSString *)dq_tmpPath {
    //[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *tmpDirectory = NSTemporaryDirectory();
    return tmpDirectory;
}

/** 创建文件夹 */
- (void)dq_createFolderWithPath:(NSString *)path {
    NSString *documentsPath = [self dq_cachePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString  *cachePath  =  [documentsPath
                              stringByAppendingPathComponent:
                              [kFOLDERNAME stringByAppendingString:@"/file"]];
    BOOL res = [fileManager
                createDirectoryAtPath:cachePath
                withIntermediateDirectories:YES attributes:nil error:nil];
    
    if (res) {
        // NSLog(@"\n文件夹创建成功\n");
    } else {
        //        NSLog(@"\n文件夹创建失败\n");
    }
}

/** 创建文件夹 */
- (void)dq_createFolder {
    [self dq_createFolderWithPath:@""];
}

/** 创建文件 */
- (void)dq_createFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    [self dq_createFolder]; // 创建大器专属的文件夹
    
    if ([fileManager fileExistsAtPath:path]) {
       [[DQFileManager sharedInstance] dq_deleteFileWithPath:path];
    }
    BOOL res = [fileManager createFileAtPath:path contents:nil attributes:nil];
    
    if (res) {
//        NSLog(@"文件创建成功: %@", path);
    } else {
//        NSLog(@"文件创建失败: %@", path);
    }
}

/** 删除文件 */
- (void)dq_deleteFileWithPath:(NSString *)path {
    
    if (path.length < 1) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self dq_existAtPath:path]) {
        BOOL res = [fileManager removeItemAtPath:path error:nil];
        
        if (res) {
                     NSLog(@"文件删除成功");
        } else {
                    NSLog(@"文件删除失败");
        }
    }
}

/** 删除目录 */
- (void)dq_deleteFoldWithPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *childrenFile = [manager subpathsAtPath:path];
    for (NSString *fileName in childrenFile) {
        NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
        if ([manager fileExistsAtPath:absolutePath]) {
            [manager removeItemAtPath:absolutePath error:nil];
        }
    }
}

/** 判断大器文件夹下的pdf文件是否存在 */
- (BOOL)dq_existAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}

/** 计算该目录下的大小（M） */
- (double)dq_folderSizeAtPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 目录下的文件计算大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        // Image的缓存计算
        YYImageCache *cache = [YYWebImageManager sharedManager].cache;
        size += cache.memoryCache.totalCost/1024.0/1024.0;
        size += cache.diskCache.totalCost/1024.0/1024.0;
        // 将大小转化为M
        return size / 1024.0 / 1024.0;
    }
    return 0;
}

/** 清空图片和PDF缓存 */
- (void)dq_clearCache {
    // 清空图片缓存
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
    [cache.diskCache removeAllObjects];
    
    // 清空PDF缓存
    NSString *dir = [[DQPDFManager sharedInstance] dq_getFileDirector];
    [self dq_deleteFoldWithPath:dir];
}

@end
