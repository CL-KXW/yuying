//
//  UpdateLoadPhotoTool.h
//  SmallPig
//
//  Created by clei on 15/3/4.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UploadPhotoDelegate;

@interface UpLoadPhotoTool : NSObject

@property (nonatomic, assign) id<UploadPhotoDelegate> delegate;
@property (nonatomic, strong) NSDictionary *responseDic;


/*
 *  上传图片
 *
 *  @param array 图片数组
 *  @param url   服务器地址
 *  @param type  上传图片类型
 */
- (instancetype) initWithPhotoArray:(NSArray *)array upLoadUrl:(NSString *)url requestData:(NSDictionary *)dataDic;
@end

@protocol UploadPhotoDelegate <NSObject>

@optional

- (void)uploadPhotoSucessed:(UpLoadPhotoTool *)upLoadPhotoTool;
- (void)uploadPhotoFailed:(UpLoadPhotoTool *)upLoadPhotoTool;
- (void)uploadPhoto:(UpLoadPhotoTool *)upLoadPhotoTool isUploadedPhotoProcess:(float)process;

@end

