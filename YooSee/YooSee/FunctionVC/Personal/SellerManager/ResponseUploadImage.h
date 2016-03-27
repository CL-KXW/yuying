//
//  ResponseUploadImage.h
//  YooSee
//
//  Created by 周后云 on 16/3/26.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ZHYBaseResponse.h"

@interface ResponseUploadImage : ZHYBaseResponse

@property(nonatomic,strong)NSString *uuid;
@property(nonatomic,strong)NSString *access_url;

@end
