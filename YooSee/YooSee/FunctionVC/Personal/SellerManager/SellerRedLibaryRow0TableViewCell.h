//
//  SellerRedLibaryRow0TableViewCell.h
//  YooSee
//
//  Created by 周后云 on 16/3/15.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellerRedLibaryRow0TableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIImageView *customImageView;
@property(nonatomic,weak)IBOutlet UILabel *statusLabel;
@property(nonatomic,weak)IBOutlet UILabel *totalMoneyLabel;
@property(nonatomic,weak)IBOutlet UILabel *moneyLabel;
@property(nonatomic,weak)IBOutlet UILabel *surplusMoneyLabel;
@property(nonatomic,weak)IBOutlet UILabel *totalNumberLabel;
@property(nonatomic,weak)IBOutlet UILabel *surplusNumberLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UILabel *contentLabel;

@end
