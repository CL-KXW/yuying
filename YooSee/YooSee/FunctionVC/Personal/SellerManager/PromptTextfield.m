//
//  PromptTextfield.m
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "PromptTextfield.h"

#define TextFont 16

@implementation PromptTextfield

- (instancetype)init
{
    if (self = [super init]) {
        self = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
    }
    return self;
}

-(void)awakeFromNib{
    self.promptLabel.font = [UIFont systemFontOfSize:TextFont];
    self.inputTextField.font = [UIFont systemFontOfSize:TextFont];
}

@end
