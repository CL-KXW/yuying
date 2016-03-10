//
//  DatabaseTool.h
//  KOShow
//
//  Created by 陈磊 on 16/1/19.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseTool : NSObject

///
/*
 *  查找数据库
 *  @pram array 数据数组
 */
+ (NSMutableArray *)queryDataForArray:(NSMutableArray *)array;

///
/*
 *  插入数据
 *  @pram value 数据值
 */
+ (void)insterDataWithValue:(NSString *)value;

///
/*
 *  创建表
 */
+ (void)createSearchHistoryTable;

///
/*
 *  删除数据
 */
+ (void)deleteDataFromDatabase;

@end
