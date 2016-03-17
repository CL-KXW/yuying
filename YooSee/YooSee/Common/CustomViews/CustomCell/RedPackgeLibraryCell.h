//
//  RedPackgeLibraryCell.h
//  YooSee
//
//  Created by Shaun on 16/3/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedPackgeLibraryCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *moneyLabel;

+ (CGFloat)cellHeight;
@end
