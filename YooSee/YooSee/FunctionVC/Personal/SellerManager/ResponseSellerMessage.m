//
//  ResponseSellerMessage.m
//  YooSee
//
//  Created by 周后云 on 16/3/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ResponseSellerMessage.h"

@implementation ResponseSellerMessage

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"resultList" : [SellerMessage class]};
}

@end


@implementation SellerMessage

@end