//
//  FileManageTool.h
//  KOShow
//
//  Created by 陈磊 on 16/1/19.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    FilePathTypeDocument,
    FilePathTypeCache,
} FilePathType;

@interface FileManageTool : NSObject

///
/*
 *  查找根目录
 *  @pram filePathType 路径类型
 */
+ (NSString *)findFilePathWithType:(FilePathType)filePathType;

///
/*
 *  查找文件目录
 *  @pram filePathType 路径类型
 *  @pram fileName     文件名
 */
+ (NSString *)findFilePathWithType:(FilePathType)filePathType fileName:(NSString *)fileName;

///
/*
 *  文件是否存在
 *  @pram path         文件路径
 */
+ (BOOL)isFileExistsAtPath:(NSString *)path;
@end
