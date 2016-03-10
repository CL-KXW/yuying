//
//  YCScreenshotView.h
//  OspreyIAD
//
//  Created by cellcom on 15/4/9.
//  Copyright (c) 2015年 Suycity. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SycRetain(xx) (xx)
#define SycRelease(xx)  xx = nil
#define SycAutoRelease(xx)  (xx)
#define SycSuperDealloc [super dealloc]

@interface ScreenshotView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIButton *backgroundView;
@property (nonatomic, copy) void(^didClildBlock)(UIImage *);

- (void)config:(UIImage *)image top:(NSString *)topStr bottom:(NSString *)bottomStr clickBlock:(void(^)(UIImage *))block;
@end
