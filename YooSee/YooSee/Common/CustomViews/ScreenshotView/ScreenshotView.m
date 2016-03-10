//
//  YCScreenshotView.m
//  OspreyIAD
//
//  Created by cellcom on 15/4/9.
//  Copyright (c) 2015年 Suycity. All rights reserved.
//

#import "ScreenshotView.h"

@implementation ScreenshotView
- (void)dealloc
{
    SycRelease(_backgroundView);
    SycRelease(_bottomLabel);
    SycRelease(_topLabel);
    Block_release(_didClildBlock);
    SycSuperDealloc;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)config:(UIImage *)image top:(NSString *)topStr bottom:(NSString *)bottomStr clickBlock:(void(^)(UIImage *))block{
    _didClildBlock = Block_copy(block);
    
    CGFloat edgeInset = 10;
    CGFloat screenWidth = CGRectGetWidth([self frame]);
    CGFloat screenHeight = CGRectGetHeight([self frame]);
    CGFloat width,height;
    width = screenWidth - edgeInset * 2;
    height = width * 3 / 4;
    
    if (!self.backgroundView) {
        self.backgroundView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backgroundView setFrame:(CGRect){CGPointZero,screenWidth,screenHeight}];
        [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [self.backgroundView.layer setShadowColor:[[UIColor grayColor] CGColor]];
        [self.backgroundView.layer setShadowOffset:(CGSize){-1,1}];
        [self.backgroundView.layer setShadowRadius:3];
        [self.backgroundView.layer setShadowOpacity:.4];
        [self.backgroundView addTarget:self
                                action:@selector(backgroundViewEvent:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backgroundView];
    }
    
    if (!self.imageView)
    {
        self.imageView = [[[UIImageView alloc] initWithFrame:(CGRect){
            (screenWidth - width)/2,
            (screenHeight - height)/2,
            width,height
        }] autorelease];
        [self addSubview:self.imageView];
    }
    if([image isKindOfClass:[UIImage class]]){
        [self.imageView setImage:image];
    }else [self.imageView setImage:nil];
    
    if (!self.topLabel) {
        self.topLabel = [[[UILabel alloc] init] autorelease];
        [self.topLabel setBackgroundColor:[UIColor blackColor]];
        [self.topLabel setTextColor:[UIColor whiteColor]];
        [self.topLabel setFont:FONT(14)];
        [self.topLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:self.topLabel];
    }
    [self.topLabel setText:topStr];
    [self.topLabel sizeToFit];
    [self.topLabel setFrame:(CGRect){
        CGRectGetMaxX([self.imageView frame]) - CGRectGetWidth([self.topLabel frame]),
        CGRectGetMinY([self.imageView frame]),
        [self.topLabel frame].size
    }];
    
    if (!self.bottomLabel) {
        self.bottomLabel = [[[UILabel alloc] init] autorelease];
        [self.bottomLabel setBackgroundColor:[UIColor blackColor]];
        [self.bottomLabel setTextColor:[UIColor whiteColor]];
        [self.bottomLabel setFont:FONT(12)];
        [self.bottomLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.bottomLabel];
    }
    [self.bottomLabel setText:bottomStr];
    [self.bottomLabel sizeToFit];
    [self.bottomLabel setFrame:(CGRect){
        CGRectGetMinX([self.imageView frame]),
        CGRectGetMaxY([self.imageView frame]) - CGRectGetHeight([self.bottomLabel frame]),
        CGRectGetWidth([[self imageView] frame]),
        CGRectGetHeight([self.bottomLabel frame])
    }];
    
}

#pragma mark - Event
- (void)backgroundViewEvent:(id)sender{
    if (self.didClildBlock) {
        self.didClildBlock([self.imageView image]);
    }
}
@end
