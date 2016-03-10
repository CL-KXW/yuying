//
//  FileManageTool.m
//  KOShow
//
//  Created by 陈磊 on 16/1/19.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "FileManageTool.h"

@implementation FileManageTool

+ (NSString *)findFilePathWithType:(FilePathType)filePathType
{
    NSString *path = @"";
    NSSearchPathDirectory pathDirectory = (filePathType == FilePathTypeDocument) ? NSDocumentDirectory : NSCachesDirectory;
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(pathDirectory, NSUserDomainMask, YES);
    path = pathArray[0];
    return path;
}

+ (NSString *)findFilePathWithType:(FilePathType)filePathType fileName:(NSString *)fileName
{
    NSString *path = @"";
    path = [FileManageTool findFilePathWithType:filePathType];
    fileName = fileName ? fileName : @"";
    path = [path stringByAppendingPathComponent:fileName];
    return path;
}

+ (BOOL)isFileExistsAtPath:(NSString *)path
{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    return [fileManage fileExistsAtPath:path];
}

@end
