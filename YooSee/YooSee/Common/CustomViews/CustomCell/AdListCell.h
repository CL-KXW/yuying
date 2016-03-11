//
//  AdListCell.h
//  YooSee
//
//  Created by Shaun on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  广告列表cell
 */
@interface AdListCell : UITableViewCell
/**
 *  图片
 */
@property (nonatomic, strong) UIImageView *adView;
/**
 *  名称
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 *  时间
 */
@property (nonatomic, strong) UILabel *timeLabel;


/**
 *  cell高度
 *
 *  @return 高度
 */
+ (CGFloat)cellHeight;

/**
 *  处理已经领取或未领取
 *
 *  @param hadGet       是否已经领取
 *  @param descTitle    显示的内容
 */
- (void)dealHadGet:(BOOL)hadGet descTitle:(NSString*)descTitle;
@end
