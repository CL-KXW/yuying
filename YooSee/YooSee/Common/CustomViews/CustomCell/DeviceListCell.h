//
//  DeviceListCell.h
//  YooSee
//
//  Created by chenlei on 15/11/18.
//  Copyright © 2015年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DeviceListCell : UITableViewCell

@property (strong, nonatomic) UILabel *deviceNameLabel;
@property (strong, nonatomic) UILabel *deviceIDLabel;//ID字符串前面加上“ID：”
@property (strong, nonatomic) UIImageView *onlineColorView;//上线下线颜色Label
@property (strong, nonatomic) UILabel *onlineStateLabel;//上下线状态文字显示
@property (strong, nonatomic) UIButton *editDeviceInfoButton;
@property (strong, nonatomic) UILabel *showDefaultLabel;
@property (strong, nonatomic) UIButton *showDefaultButton;
@property (strong, nonatomic) UIButton *alarmButton;
@property (strong, nonatomic) UILabel *alarmMessageCountLabel;
@property (strong, nonatomic) UIButton *defenceButton;
@property (strong, nonatomic) UILabel *defenceLabel;
@property (strong, nonatomic) NSString  *deviceImgUrlStr;//设备图片url
@property (strong, nonatomic) UIButton *playbutton;
@property (strong, nonatomic) UIButton *photosbutton;
@property (strong, nonatomic) UIButton *settingbutton;
@property (strong, nonatomic) UIButton *playbackbutton;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegate;

@end
