//
//  GDScrollBanner.m
//  GDScrollBanner
//
//  Created by xiaoyu on 16/1/29.
//  Copyright © 2016年 Guoda. All rights reserved.
//

#import "BannerView.h"

#import "UIImageView+WebCache.h"

#define pageSize 16

#define GDWidth self.frame.size.width

#define GDHeight self.frame.size.height

@interface BannerView ()<UIScrollViewDelegate>
{
    
    
}
@property (nonatomic, copy) NSArray *imageData;


@end
@implementation BannerView{

    __weak  UIImageView *_leftImageView,*_centerImageView,*_rightImageView;
    
    __weak  UIScrollView *_scrollView;
    
    __weak  UIPageControl *_PageControl;
    
    NSTimer *_timer;
    
    NSInteger _currentIndex;//当前显示的是第几个
    
    NSInteger _MaxImageCount;//图片个数
    
    BOOL _isNetwork;//是否是网络图片
    
}
#pragma mark - 本地图片
- (instancetype) initWithFrame:(CGRect)frame WithLocalImages:(NSArray *)imageNames{

    if (imageNames.count < 2 ) {
        return nil;
    }
    self = [super initWithFrame:frame];
    if ( self) {
        
        _isNetwork = NO;
        
        [self createScrollView]; //创建滚动view
        
        [self setImageData:imageNames];//加入本地image
        
        [self setMaxImageCount:_imageData.count];//设置数量
    }
    
    return self;
    
}
#pragma mark - 网络图片
- (instancetype)initWithFrame:(CGRect)frame WithNetImages:(NSArray *)imageNames {

    if (imageNames.count < 2) {
        return nil;
    }
    self = [super initWithFrame:frame];
    if (self) {
        
        _isNetwork = YES;
        
        [self createScrollView];
        
        [self setImageData:imageNames];
        
        [self setMaxImageCount:_imageData.count];
        
    }
    return self;
}
#pragma mark - 设置数量
- (void)setMaxImageCount:(NSInteger)MaxImageCount {

    _MaxImageCount = MaxImageCount;
    
    [self initImageView];//复用imageView初始化
    
    [self createPageControl];//pageControl
    
    [self setUpTimer];//定时器
    
    [self changeImageLeft:_MaxImageCount-1 center:0 right:1];//出事位置
    
}
- (void)createScrollView {
    UIScrollView *gdSC = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:gdSC];
    gdSC.backgroundColor = [UIColor clearColor];
    gdSC.pagingEnabled = YES;
    gdSC.showsHorizontalScrollIndicator = NO;
    gdSC.delegate = self;
    gdSC.contentSize = CGSizeMake(GDWidth * 3, 0);//复用，创建三个
    _AutoScrollDelay = 2.0;
    _currentIndex = 0;//开始显示的是第一个   前一个是最后一个   后一个是第二张
    _scrollView = gdSC;
}
- (void)setImageData:(NSArray *)imageNames {
    
    
    if (_isNetwork) {
        _imageData = [imageNames copy];
//        [self getImage];
    }else {
        //本地
        NSMutableArray *local = [NSMutableArray arrayWithCapacity:imageNames.count];
        for (NSString *name in imageNames) {
            [local addObject:[UIImage imageNamed:name]];
        }
        _imageData = [local copy];
    }



}
- (void)initImageView {
    UIImageView *left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,GDWidth, GDHeight)];
    UIImageView *center = [[UIImageView alloc] initWithFrame:CGRectMake(GDWidth, 0,GDWidth, GDHeight)];
    UIImageView *right = [[UIImageView alloc] initWithFrame:CGRectMake(GDWidth * 2, 0,GDWidth, GDHeight)];

    center.userInteractionEnabled = YES;
    [center addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidTap)]];

    [_scrollView addSubview:left];
    [_scrollView addSubview:center];
    [_scrollView addSubview:right];
    
    _leftImageView = left;
    _centerImageView = center;
    _rightImageView = right;

    
}
//点击事件
- (void)imageViewDidTap {
    if (self.smartImgdidSelectAtIndex != nil) {
        self.smartImgdidSelectAtIndex(_currentIndex);
    }
}
- (void)createPageControl {
    UIPageControl *page = [[UIPageControl alloc] initWithFrame:CGRectMake(0,GDHeight - pageSize,GDWidth, 7)];
    
    page.pageIndicatorTintColor = [UIColor lightGrayColor];
    page.currentPageIndicatorTintColor =  [UIColor redColor];
    page.numberOfPages = _MaxImageCount;
    page.currentPage = 0;
    
    [self addSubview:page];
    
    _PageControl = page;
    
}
#pragma mark - 定时器
- (void)setUpTimer {
    if (_AutoScrollDelay < 0.5) return;//太快了
    
    _timer = [NSTimer timerWithTimeInterval:_AutoScrollDelay target:self selector:@selector(scorll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}
- (void)scorll {
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x +GDWidth, 0) animated:YES];
}
#pragma mark - 给复用的图赋值
- (void)changeImageLeft:(NSInteger)LeftIndex center:(NSInteger)centerIndex right:(NSInteger)rightIndex {

    if (_isNetwork) {
        
        [_leftImageView setImageWithURL:[NSURL URLWithString:_imageData[LeftIndex]] placeholderImage:_placeImage];
        [_centerImageView setImageWithURL:[NSURL URLWithString:_imageData[centerIndex]] placeholderImage:_placeImage];
        [_rightImageView setImageWithURL:[NSURL URLWithString:_imageData[rightIndex]] placeholderImage:_placeImage];

        
    }else {
        _leftImageView.image = _imageData[LeftIndex];
        _centerImageView.image = _imageData[centerIndex];
        _rightImageView.image = _imageData[rightIndex];

        
    }

    [_scrollView setContentOffset:CGPointMake(GDWidth, 0)];
}

#pragma mark - 滚动代理
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setUpTimer];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}
- (void)removeTimer {
    if (_timer == nil) return;
    [_timer invalidate];
    _timer = nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {//开始滚动，判断位置，然后替换复用的三张图
    [self changeImageWithOffset:scrollView.contentOffset.x];
}
- (void)changeImageWithOffset:(CGFloat)offsetX {
    
    if (offsetX >= GDWidth * 2) {
        _currentIndex++;
        
        if (_currentIndex == _MaxImageCount-1) {
            
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:0];
            
        }else if (_currentIndex == _MaxImageCount) {
            
            _currentIndex = 0;
            [self changeImageLeft:_MaxImageCount-1 center:0 right:1];
            
        }else {
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:_currentIndex+1];
        }
        _PageControl.currentPage = _currentIndex;
        
    }
    
    if (offsetX <= 0) {
        _currentIndex--;
        
        if (_currentIndex == 0) {
            
            [self changeImageLeft:_MaxImageCount-1 center:0 right:1];
            
        }else if (_currentIndex == -1) {
            
            _currentIndex = _MaxImageCount-1;
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:0];
            
        }else {
            [self changeImageLeft:_currentIndex-1 center:_currentIndex right:_currentIndex+1];
        }
        
        _PageControl.currentPage = _currentIndex;
    }
    
}
-(void)dealloc {
    [self removeTimer];
}
#pragma mark - set方法，设置间隔时间
- (void)setAutoScrollDelay:(NSTimeInterval)AutoScrollDelay {
    _AutoScrollDelay = AutoScrollDelay;
    [self removeTimer];
    [self setUpTimer];
}
@end
