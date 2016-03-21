//
//  AlarmListCell.h
//  YooSee
//
//  Created by chenlei on 16/3/5.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"

@interface AlarmListCell : UITableViewCell

@property (nonatomic, strong) Alarm *alarmInfo;

@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIButton *playButton;

- (void)setDeviceName:(NSString *)name;


@end
