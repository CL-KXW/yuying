//
//  SegmentView.h
//  KOShow
//
//  Created by chenlei on 15/11/28.
//  Copyright © 2015年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentViewDelegate;

@interface SegmentView : UIView

@property (nonatomic, assign) id<SegmentViewDelegate> delegate;
@property (nonatomic, assign) float radius;
@property (nonatomic, strong) UIColor *layerColor;
@property (nonatomic, assign) int selectedIndex;

- (void)setItemTitleWithArray:(NSArray *)titleArray;

@end

@protocol SegmentViewDelegate <NSObject>

@optional

- (void)segmentView:(SegmentView *)segmentView  selectedItemAtIndex:(int)index;

@end
