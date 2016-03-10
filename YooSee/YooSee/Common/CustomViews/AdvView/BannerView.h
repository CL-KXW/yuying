//
//  GDScrollBanner.h
//  GDScrollBanner
//
//  Created by xiaoyu on 16/1/29.
//  Copyright © 2016年 Guoda. All rights reserved.
//
//I Will Become A Winner
#import <UIKit/UIKit.h>


@interface BannerView : UIView


@property (nonatomic, strong) UIImage *placeImage;             //placeholder

@property (nonatomic, assign) NSTimeInterval AutoScrollDelay;   //滚动延时

@property (nonatomic, copy) void(^smartImgdidSelectAtIndex)(NSInteger index);//选中的图片
/**
 *  本地图片
 *
 *  @param frame      位置
 *  @param imageNames 加载本地图片
 *
 *  @return
 */
- (instancetype) initWithFrame:(CGRect)frame WithLocalImages:(NSArray *)imageNames;

/**
 *  加载网络图片
 *
 *  @param frame      位置大小
 *  @param imageNames 名字
 *
 *  @return
 */
- (instancetype) initWithFrame:(CGRect)frame WithNetImages:(NSArray *)imageNames;

@end
