//
//  UIView+UIView_Frame.m
//  EyeSight
//
//  Created by Zac on 15/11/4.
//  Copyright © 2015年 lanou. All rights reserved.
//

#import "UIView+UIView_Frame.h"

@implementation UIView (UIView_Frame)
-(void)setX:(CGFloat)x {
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.frame = CGRectMake(x, y, width, height);
}

-(CGFloat)x {
    return self.frame.origin.x;
}

-(void)setY:(CGFloat)y {
    CGFloat x = self.frame.origin.x;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.frame = CGRectMake(x, y, width, height);
}

-(CGFloat)y {
    return self.frame.origin.y;
}

-(void)setWidth:(CGFloat)width {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat height = self.frame.size.height;
    self.frame = CGRectMake(x, y, width, height);
}

-(CGFloat)width {
    return self.frame.size.width;
}

-(void)setHeight:(CGFloat)height{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    self.frame = CGRectMake(x, y, width, height);
}

-(CGFloat)height {
    return self.frame.size.height;
}
@end
