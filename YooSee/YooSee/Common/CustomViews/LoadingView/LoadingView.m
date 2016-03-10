//
//  LoadingView.m
//  YooSee
//
//  Created by chenlei on 16/2/20.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()

@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIWindow *overlayWindow;

@end

@implementation LoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)sharedView
{
    static LoadingView *loadingView;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^
    {
        loadingView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    });
    
    return loadingView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = RGBA(0.0, 0.0, 0.0, 0.6);
        UIImage *image = [UIImage imageNamed:@"loading_01"];
        float width = image.size.width/3.0;
        float height = image.size.height/3.0;
        _loadingImageView = [CreateViewTool createImageViewWithFrame:CGRectMake((self.frame.size.width - width)/2, (self.frame.size.height - height)/2, width, height) placeholderImage:image];
        //_loadingImageView.userInteractionEnabled = NO;
        [self addSubview:_loadingImageView];
        
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
        
        for (int i = 1; i < 11; i++)
        {
            if (i == 10)
            {
                [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_%d.png",i]]];
            }
            else
            {
                [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_0%d.png",i]]];
            }
        }
        
        _loadingImageView.animationImages = imageArray;
        _loadingImageView.animationDuration = 1.0;
        _loadingImageView.animationRepeatCount = 100000000;
        [_loadingImageView startAnimating];
        self.alpha = 0.0;
    }
    return self;
}


- (UIWindow *)overlayWindow
{
    if(!_overlayWindow)
    {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.userInteractionEnabled = YES;
    }
    return _overlayWindow;
}


+ (void)showLoadingView
{
    [[LoadingView sharedView] show];
}

- (void)show
{
    __weak typeof(self) weakSelf = self;
    if (!self.superview)
    {
        [self.overlayWindow addSubview:self];
        [self.overlayWindow makeKeyAndVisible];
    }
    [UIView animateWithDuration:0.3 animations:^
    {
        weakSelf.alpha = 1.0;
        [_loadingImageView startAnimating];
    }];
}

+ (void)dismissLoadingView
{
    [[LoadingView sharedView] dismiss];
}

- (void)dismiss
{
    __weak typeof(self) weakSelf = self;
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
    [windows removeObject:_overlayWindow];
    self.overlayWindow = nil;
    [UIView animateWithDuration:0.3 animations:^
     {
         weakSelf.alpha = 0.0;
         [_loadingImageView stopAnimating];
     }];
}

@end
