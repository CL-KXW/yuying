//
//  NativePlugin.m
//  osprey
//
//  Created by  apple on 15/12/22.
//  Copyright © 2015年 杨氏宅淘阁科技公司. All rights reserved.
//

#import "NativePlugin.h"

@implementation NativePlugin

- (void)loadingStatusStart
{

    NSLog(@"loadingStatusStart");

}
- (void)loadingStatusClose
{
    NSLog(@"loadingStatusClose");

}
- (void)setTitle:(NSString*)title
{
    NSLog(@"setTitle:%@",title);
    if([self.delegate respondsToSelector:@selector(changeTitle:)])
    {
        [self.delegate changeTitle:title];
    }
}

- (void)setType:(NSString*)type
{
    NSLog(@"setType:%@",type);
    if([self.delegate respondsToSelector:@selector(changeType:)])
    {
        [self.delegate changeType:type];
    }
}

- (NSString*)getUserInfo
{
    NSDictionary *userInfo = [YooSeeApplication shareApplication].userDic;
    NSDictionary *dic = @{@"uid":userInfo[@"uid"],@"city":userInfo[@"cityname"],@"cityid":userInfo[@"cityid"],@"os":@"ios"};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonStr);
    return jsonStr;
}


@end


