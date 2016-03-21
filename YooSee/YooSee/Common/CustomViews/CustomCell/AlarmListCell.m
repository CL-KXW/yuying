//
//  AlarmListCell.m
//  YooSee
//
//  Created by chenlei on 16/3/5.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define MAIN_TEXT_COLOR     RGB(51.0, 51.0, 51.0)
#define DE_TEXT_COLOR       RGB(155.0, 155.0, 155.0)
#define SPACE_X             10.0
#define ROW_HEIGHT          190.0 * CURRENT_SCALE
#define TOP_SPACE_X         15.0 * CURRENT_SCALE
#define TOP_SPACE_Y         20.0 * CURRENT_SCALE
#define LABEL_HEIGHT        25.0 * CURRENT_SCALE
#define LABEL_WIDTH         160.0 * CURRENT_SCALE
#define ITEM_WH             54.0  * CURRENT_SCALE
#define BOTTOM_SPACE_Y      15.0  * CURRENT_SCALE
#define BOTTOM_SPACE_X      15.0  * CURRENT_SCALE

#import "AlarmListCell.h"

@interface AlarmListCell()

@property (strong, nonatomic) UILabel *deviceNameLabel;
@property (strong, nonatomic) UILabel *deviceIDLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation AlarmListCell

- (void)awakeFromNib
{
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initUI];
    }
    return self;
}

#pragma mark 初始化UI
- (void)initUI
{
    UIImageView *bgView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, 0, SCREEN_WIDTH - 2 * SPACE_X, ROW_HEIGHT) placeholderImage:nil];
    bgView.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:bgView withCornerRadius:10.0];
    [self.contentView addSubview:bgView];
    
    float x = TOP_SPACE_X;
    float y = TOP_SPACE_Y;
    _deviceNameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, LABEL_WIDTH, LABEL_HEIGHT) textString:@"摄像头" textColor:MAIN_TEXT_COLOR textFont:FONT(17)];
    [bgView addSubview:_deviceNameLabel];
    
    _timeLabel = [CreateViewTool createLabelWithFrame:CGRectMake(bgView.frame.size.width - TOP_SPACE_X - LABEL_WIDTH, y, LABEL_WIDTH, 2 * LABEL_HEIGHT) textString:@"" textColor:DE_TEXT_COLOR textFont:FONT(17)];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:_timeLabel];
    
    y += _deviceNameLabel.frame.size.height;
    _deviceIDLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, LABEL_WIDTH, LABEL_HEIGHT) textString:@"ID:" textColor:DE_TEXT_COLOR textFont:FONT(15)];
    [bgView addSubview:_deviceIDLabel];
    
    y += _deviceIDLabel.frame.size.height + TOP_SPACE_X;
    UIImageView *lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(TOP_SPACE_X/2, y, bgView.frame.size.width - TOP_SPACE_X, 1.0) placeholderImage:nil];
    lineImageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.5];
    [bgView addSubview:lineImageView];
    
    NSArray *imageArray = @[@"icon_alarm_av",@"icon_alarm_pic",@"icon_alarm_play"];
    NSArray *titleArray = @[@"报警视频",@"报警图片",@"查看摄像头"];
    float label_width = (bgView.frame.size.width - 2 * BOTTOM_SPACE_X)/[imageArray count];
    y = lineImageView.frame.size.height + lineImageView.frame.origin.y + BOTTOM_SPACE_Y;
    float button_space_x = (label_width - ITEM_WH)/2;
    for (int i = 0; i < [imageArray count]; i++)
    {
        UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(BOTTOM_SPACE_X + i * label_width, y + ITEM_WH, label_width, LABEL_HEIGHT) textString:titleArray[i] textColor:DE_TEXT_COLOR textFont:FONT(14)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:titleLabel];
        
        UIButton *itembutton = [CreateViewTool createButtonWithFrame:CGRectMake(titleLabel.frame.origin.x + button_space_x, y, ITEM_WH, ITEM_WH) buttonImage:imageArray[i] selectorName:@"" tagDelegate:nil];
        [bgView addSubview:itembutton];
       
        if ( i == 0)
        {
            _videoButton = itembutton;
        }
        if ( i == 1)
        {
            _imageButton = itembutton;
        }
        if ( i == 2)
        {
            _playButton = itembutton;
        }
    }
}

- (void)setAlarmInfo:(Alarm *)alarmInfo
{
    _alarmInfo = alarmInfo;
    _deviceIDLabel.text = [@"ID: " stringByAppendingString:alarmInfo.deviceId];
    _timeLabel.text = alarmInfo.alarmTime;
}

- (void)setDeviceName:(NSString *)name
{
    name = name ? name : @"";
    _deviceNameLabel.text = name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
