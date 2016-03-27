//
//  VerticalButton.m
//  YooSee
//
//  Created by 周后云 on 16/3/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "VerticalButton.h"

@implementation VerticalButton

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.imageRadius == 0.0) {
        self.imageRadius = 30.0;
    }
    
    // Center image
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2-10;
    float labelHight = 20;
    self.imageView.frame = CGRectMake((self.width-self.imageRadius)/2, (self.height-self.imageRadius-labelHight)/2, self.imageRadius, self.imageRadius);
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height+self.imageView.frame.origin.y + 5;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = CGRectMake(0, (self.height-self.imageRadius-labelHight)/2+self.imageRadius, self.width, labelHight);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}


@end
