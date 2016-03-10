//
//  SycPhotoHandleView.m
//  TrafficStatusCQ
//
//  Created by cellcom on 14-4-30.
//  Copyright (c) 2014年 Suycity. All rights reserved.
//

#define SycRetain(xx) (xx)
#define SycRelease(xx)  xx = nil
#define SycAutoRelease(xx)  (xx)
#define SycSuperDealloc [super dealloc]

#import "PhotoHandleView.h"

@interface PhotoHandleView ()
{
    BOOL _flag;
    UIViewController *_target;
    BOOL _isShare;
}
@property (nonatomic , retain) UIImageView *imageView;
@property (nonatomic , retain) UIScrollView *photoScrollView;
@end

@implementation PhotoHandleView
- (void)dealloc
{
    SycRelease(_photoScrollView);
    SycRelease(_imageView);
    SycRelease(_image);
    [super dealloc];
}
- (id)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self setImage:image];
        [self setFromRect:from];
        [self initView];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from target:(id)target
{
    if ([target isKindOfClass:[UIViewController class]]) {
        _isShare = YES;
        _target = target;
    }
    return [self initWithImage:image transFrom:from];
}
- (void)initView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [tap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tap];
    SycRelease(tap);
    
    _photoScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0,0,self.bounds.size}];
	_photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_photoScrollView.pagingEnabled = NO;
	_photoScrollView.showsHorizontalScrollIndicator = YES;
	_photoScrollView.showsVerticalScrollIndicator = YES;
    [_photoScrollView setDelegate:self];
	_photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.maximumZoomScale = 3;
	_photoScrollView.minimumZoomScale = 1;
    
    [self addSubview:_photoScrollView];
    
    CGSize size = (CGSize){32,32};
    CGRect rect = (CGRect){self.frame.size.width - size.width,self.frame.size.height - size.height,size};
    UIImage *image = [UIImage imageNamed:_isShare ? @"listBtnImg.png" : @"downl.png"];
    UIButton *saveBtn = ({
        UIButton *buttom = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttom setFrame:rect];
        [buttom addTarget:self action:@selector(saveBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        buttom;
    });
    [saveBtn setImage:image forState:UIControlStateNormal];
    [saveBtn setBackgroundColor:[UIColor clearColor]];
    [self addSubview:saveBtn];
    [self bringSubviewToFront:saveBtn];
}

- (void)show
{
    [self setBackgroundColor:[UIColor blackColor]];
    if (!_imageView) {
        _imageView  = [[UIImageView alloc] init];
        [_imageView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *SingleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTapGestureEvent:)];
        SingleTapGesture.numberOfTapsRequired = 1;//tap次数
        [_imageView addGestureRecognizer:SingleTapGesture];
        // 双击
        
        UITapGestureRecognizer *doubleTapGesture;
        doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureEvent:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [_imageView addGestureRecognizer:doubleTapGesture];
        // 关键在这一行，如果双击确定偵測失败才會触发单击
        [SingleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        SycRelease(doubleTapGesture);
        SycRelease(SingleTapGesture);
        
        [_photoScrollView addSubview:_imageView];
    }
    [_imageView setImage:_image];
    [_imageView setFrame:_fromRect];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    CGSize size = [self scaleSize:_image.size];
    [self.photoScrollView setContentSize:size];
    
    [UIView animateWithDuration:.3 animations:^{
        [self.imageView setFrame:(CGRect){
            MAX((self.photoScrollView.frame.size.width - size.width)/2, 0),
            MAX((self.photoScrollView.frame.size.height - size.height)/2, 0),
            size
        }];
    } completion:^(BOOL finished) {
        [self setBackgroundColor:[UIColor blackColor]];
//        [self.photoScrollView setContentSize:self.photoScrollView.frame.size];
    }];
}

- (CGSize)scaleSize:(CGSize)size
{
    CGFloat maxW = MAX(size.width, size.height);
    CGFloat widthB = self.frame.size.width;
    CGFloat heightB = self.frame.size.height;
    CGFloat maxBW = size.width > size.height ? widthB : heightB;
    CGFloat scale = MIN(maxBW / maxW, 1);
    CGFloat width = scale * size.width;
    CGFloat height = scale * size.height;
    
    if (height == width && width > widthB) {
        scale = widthB / width;
        return (CGSize){width * scale,height * scale};
    }
    
    return (CGSize){width,height};
}
#pragma mark - Event
- (void)saveBtnEvent:(id)sender{
    if (_isShare) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片",@"分享图片", nil];
        [sheet showInView:[_target view]];
        SycRelease(sheet);
    }
    else{
        [self saveImageToPhotos];
    }
}
- (void)saveImageToPhotos
{
    UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存失败!请在设置->隐私->照片,将权限设置为允许。" ;
    }else{
        msg = @"保存成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
#pragma mark - share view comtrolelr
- (void)shareViewComtroller{
    NSArray *activityItems = @[_imageView.image];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [_target presentViewController:activity animated:YES completion:nil];
    SycRelease(activity);
}
#pragma mark -  UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet cancelButtonIndex] != buttonIndex) {
        switch (buttonIndex) {
            case 0:
                [self saveImageToPhotos];
                break;
            case 1:
                [self shareViewComtroller];
                break;
            default:
                break;
        }
    }
}
#pragma mark - UIScrollView
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? \
    
    scrollView.contentSize.width/2 : xcenter;
    
    //同上，此处修改y值
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? \
    
    scrollView.contentSize.height/2 : ycenter;
    
    [_imageView setCenter:CGPointMake(xcenter, ycenter)];
}
- (void)tapEvent:(id)sender
{
    [UIView animateWithDuration:.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
        [self.imageView setFrame:_fromRect];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)SingleTapGestureEvent:(UITapGestureRecognizer *)tap
{
    [self tapEvent:tap];
}
- (void)doubleTapGestureEvent:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:self.photoScrollView];
	if (self.photoScrollView.zoomScale == self.photoScrollView.maximumZoomScale) {
		[self.photoScrollView setZoomScale:self.photoScrollView.minimumZoomScale animated:YES];
	} else {
        CGPoint touchCenter = touchPoint;
        CGSize zoomRectSize = CGSizeMake(self.frame.size.width / 3.0, self.frame.size.height / 3.0);
        
        CGRect zoomRect = CGRectMake( touchCenter.x - zoomRectSize.width * .5, touchCenter.y - zoomRectSize.height * .5, zoomRectSize.width, zoomRectSize.height );
        
        // correct too far left
        if( zoomRect.origin.x < 0 )
            zoomRect = CGRectMake(0, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
        
        // correct too far up
        if( zoomRect.origin.y < 0 )
            zoomRect = CGRectMake(zoomRect.origin.x, 0, zoomRect.size.width, zoomRect.size.height );
        
        // correct too far right
        if( zoomRect.origin.x + zoomRect.size.width > self.frame.size.width )
            zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
        
        // correct too far down
        if( zoomRect.origin.y + zoomRect.size.height > self.frame.size.height )
            zoomRect = CGRectMake( zoomRect.origin.x, self.frame.size.height - zoomRect.size.height, zoomRect.size.width, zoomRect.size.height );
        
		[self.photoScrollView zoomToRect:zoomRect animated:YES];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
