//
//  UpdateLoadPhotoTool.m
//  SmallPig
//
//  Created by clei on 15/3/4.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//

#import "UpLoadPhotoTool.h"
#import "RequestDataTool.h"
#import "AFNetworking.h"

#define FILE_NAME   @"attach"

@interface UpLoadPhotoTool()
{
    AFHTTPRequestOperation *requestOperation;
}

@property (nonatomic, strong) NSDictionary *requestDic;
@property (nonatomic, strong) NSString *upLoadUrl;
@property (nonatomic, strong) NSArray *photoArray;
@property (nonatomic, strong) NSArray *videoArray;
@end

@implementation UpLoadPhotoTool

- (instancetype) initWithPhotoArray:(NSArray *)array upLoadUrl:(NSString *)url requestData:(NSDictionary *)dataDic
{
    self = [super init];
    
    if (self)
    {
        self.requestDic = dataDic;
        self.photoArray = array;
        url = (url) ? url : @"";
        self.upLoadUrl = url;
        [self startUpLoadPhotos];
    }
    return self;
}


- (void)startUpLoadPhotos
{
    __weak typeof(self) weakSelf = self;
    //if (!self.photoArray || [self.photoArray count] == 0)
    //    return;
    //else
    {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
        //^{
            [weakSelf upLoadPhotos];
        //});
    }
}


- (void)upLoadPhotos
{
    //上传图片
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]init];
    manager.requestSerializer = [AFHTTPRequestSerializer  serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //manager.requestSerializer.timeoutInterval = TIMEOUT;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json",@"application/json",@"text/plain",nil];
    requestOperation =  [manager POST:weakSelf.upLoadUrl parameters:self.requestDic
    constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        if (self.photoArray && [self.photoArray count] > 0)
        {
            for (int i = 0; i < [self.photoArray count]; i++)
            {
                UIImage *image = self.photoArray[i];
                NSData *data = UIImageJPEGRepresentation(image, .4);
                //NSData *data = UIImagePNGRepresentation(image);
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                NSString *nameStr = [NSString stringWithFormat:@"%@%d.jpg",FILE_NAME,i + 1];
                nameStr = FILE_NAME;
                nameStr = ([self.photoArray count] == 1) ? FILE_NAME : nameStr;
                NSString *picName = [NSString stringWithFormat:@"%.0f%d.png",time,i];
                [formData appendPartWithFileData:data name:nameStr fileName:picName mimeType:@"image/jpg"];
            }

        }
    }
    success:^(AFHTTPRequestOperation *operation, id responseDic)
    {
        NSLog(@"------%@",operation.responseString);
        weakSelf.responseDic = responseDic;
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(uploadPhotoSucessed:)])
        {
            [weakSelf.delegate uploadPhotoSucessed:weakSelf];
        }
        NSLog(@"operationresponseObject===%@",weakSelf.responseDic);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(uploadPhotoFailed:)])
        {
            [weakSelf.delegate uploadPhotoFailed:weakSelf];
        }
         NSLog(@"error===%@",error);
    }];
    //添加进度
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         NSLog(@"totalBytesWritten===%lld====totalBytesExpectedToWrite====%lld",totalBytesWritten,totalBytesExpectedToWrite);
         if (totalBytesWritten <= totalBytesExpectedToWrite)
         {
             if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(uploadPhoto:isUploadedPhotoProcess:)])
             {
                 [weakSelf.delegate uploadPhoto:weakSelf isUploadedPhotoProcess:totalBytesWritten * 1.0/totalBytesExpectedToWrite];
             }
         }
     }];
    //[requestOperation waitUntilFinished];
    
}

@end
