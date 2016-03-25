//
//  RequestTool.m
//  SmallPig
//
//  Created by chenlei on 14/11/25.
//  Copyright (c) 2014年 chenlei. All rights reserved.
//

#import "RequestTool.h"

#define TIMEOUT 15.0

@interface RequestTool()
{
    AFHTTPRequestOperation *requestOperation;
}
@end

@implementation RequestTool


//发起请求
- (void)requestWithUrl:(NSString *)url requestParamas:(NSDictionary *)paramas requestType:(RequestType)type requestSucess:(void (^)(AFHTTPRequestOperation *operation,id responseDic))sucess requestFail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]init];
    manager.requestSerializer = [AFHTTPRequestSerializer  serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"manager.requestSerializer===%@",manager.requestSerializer.HTTPRequestHeaders);
    manager.requestSerializer.timeoutInterval = TIMEOUT;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json",@"application/json",@"text/plain",nil];
    NSLog(@"[NSHTTPCookieStorage sharedHTTPCookieStorage]===%@",[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies);
    requestOperation = [manager POST:url parameters:paramas
          success:^(AFHTTPRequestOperation *operation,id responeDic)
          {
              NSString *response = operation.responseString;
              NSLog(@"allHeaders===%@",operation.response.allHeaderFields);
              if (response)
              {
                  NSDictionary *dataDic = [RequestDataTool decryptMessage:response];
                  responeDic = (dataDic) ? dataDic : [RequestDataTool decryptJSON:response];
                  if (sucess)
                  {
                      sucess(operation, responeDic);
                  }
              }
              else
              {
                  //服务器异常
                  if (fail)
                  {
                      fail(operation,nil);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation,NSError *error)
          {
              if (fail)
              {
                  fail(operation,error);
              }
          }];
    
    if (RequestTypeSynchronous == type)
    {
        [requestOperation waitUntilFinished];
    }
}


//发起请求
- (void)getRequestWithUrl:(NSString *)url requestParamas:(NSDictionary *)paramas requestType:(RequestType)type requestSucess:(void (^)(AFHTTPRequestOperation *operation,id responseDic))sucess requestFail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]init];
    manager.requestSerializer = [AFHTTPRequestSerializer  serializer];
    manager.requestSerializer.timeoutInterval = TIMEOUT;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json",@"application/json",@"text/plain",nil];
    //NSLog(@"[NSHTTPCookieStorage sharedHTTPCookieStorage]===%@",[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies);
    requestOperation = [manager GET:url parameters:paramas
                        success:^(AFHTTPRequestOperation *operation,id responeDic)
                        {
                            //responeDic = [RequestDataTool decryptJSON:operation.responseString];
                            if ([responeDic isKindOfClass:[NSDictionary class]] || [responeDic isKindOfClass:[NSMutableDictionary class]])
                            {
                                if (sucess)
                                {
                                    sucess(operation,responeDic);
                                }
                            }
                            else
                            {
                                //服务器异常
                                if (fail)
                                {
                                    fail(operation,nil);
                                }
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation,NSError *error)
                        {
                            if (fail)
                            {
                                fail(operation,error);
                            }
                        }];
    
    if (RequestTypeSynchronous == type)
    {
        [requestOperation waitUntilFinished];
    }
}

//取消请求
- (void)cancelRequest
{
    if (requestOperation)
    {
        [requestOperation cancel];
        requestOperation = nil;
    }
}


@end
