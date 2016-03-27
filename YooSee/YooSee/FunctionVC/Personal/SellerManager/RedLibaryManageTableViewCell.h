//
//  RedLibaryManageTableViewCell.h
//  YooSee
//
//  Created by 周后云 on 16/3/15.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedLibaryManageTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIImageView *customImageView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *totalMoneyLabel;
@property(nonatomic,weak)IBOutlet UILabel *totalNumberLabel;
@property(nonatomic,weak)IBOutlet UILabel *surplusNumberLabel;
@property(nonatomic,weak)IBOutlet UILabel *surplusMoneyLabel;
@property(nonatomic,weak)IBOutlet UILabel *timeLabel;

@end
