//
//  SelectPictureButton.m
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SelectPictureButton.h"

@implementation SelectPictureButton

- (instancetype)init
{
    if (self = [super init]) {
        self = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
    }
    return self;
}

-(void)awakeFromNib{
    NSLog(@"DDD");
}

@end
