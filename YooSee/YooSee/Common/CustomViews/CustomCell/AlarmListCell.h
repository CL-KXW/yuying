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

- (void)setDeviceName:(NSString *)name;

@end
