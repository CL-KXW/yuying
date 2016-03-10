//
//  RadarView.m
//  OspreyIAD
//
//  Created by Jan Lion on 16/1/5.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#define SPACE_Y         120.0 * CURRENT_SCALE
#define SPACE_BT_Y      170.0 * CURRENT_SCALE
#define ICON_WH         250.0 * CURRENT_SCALE
#define LABEL_HEIGHT    40.0 * CURRENT_SCALE

#import "RadarView.h"

@interface RadarView()

@property (nonatomic, strong) UIImageView *radarLight;

@end

@implementation RadarView

- (instancetype)init
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    self = [super initWithFrame:rect];
    if (self)
    {
        [self initUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addImageViews];
    [self addLabel];
}

- (void)addImageViews
{
    float x = (self.frame.size.width - ICON_WH)/2;
    float y = SPACE_Y;
    UIImageView *imageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, ICON_WH, ICON_WH) placeholderImage:[UIImage imageNamed:@"camera_search_bg"]];
    [self addSubview:imageView];
    
    _radarLight = [CreateViewTool createImageViewWithFrame:imageView.frame placeholderImage:[UIImage imageNamed:@"camera_search"]];
    [self addSubview:_radarLight];
    
    [self startAnimating];
}


- (void)addLabel
{
    UILabel *tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, self.frame.size.height - SPACE_BT_Y - LABEL_HEIGHT, self.frame.size.width, LABEL_HEIGHT) textString:@"正在加载,请稍后..." textColor:RGB(155.0, 155.0, 155.0) textFont:FONT(20.0)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipLabel];
}


#pragma mark 动画
- (void)startAnimating
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotation.toValue = @(2 * M_PI);
    rotation.duration = 1.5;
    rotation.repeatCount = NSIntegerMax;
    
    [self.radarLight.layer addAnimation:rotation forKey:nil];
}

- (void)endAnimating
{
    [self.radarLight.layer removeAllAnimations];
    [self removeFromSuperview];
}

@end
