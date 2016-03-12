//
//  YCMoneyAnimation.h
//  OspreyIAD
//
//  Created by cellcom on 15/3/6.
//  Copyright (c) 2015年 Suycity. All rights reserved.
//

#import <UIKit/UIKit.h>

__block typedef void(^willAnimationBlock)();
__block typedef void(^didAnimationBlock)();
@interface YCMoneyAnimation : UIView
@property (nonatomic, copy) willAnimationBlock willAnimation;
@property (nonatomic, copy) didAnimationBlock didAnimation;
@property (nonatomic, retain) UIImageView *bagView;

- (instancetype)initWithAnimation:(void(^)())willAni :(void(^)())didAni;
- (void)getCoinAction;
@end
