//
//  DeviceListCell.h
//  YooSee
//
//  Created by chenlei on 15/11/18.
//  Copyright © 2015年 chenlei. All rights reserved.
//

#define MAIN_TEXT_COLOR     RGB(51.0, 51.0, 51.0)
#define DE_TEXT_COLOR       RGB(155.0, 155.0, 155.0)
#define ROW_HEIGHT          230.0 * CURRENT_SCALE
#define SPACE_Y             15.0 * CURRENT_SCALE
#define SPACE_X             10.0
#define TOP_SPACE_X         15.0 * CURRENT_SCALE
#define TOP_SPACE_Y         30.0 * CURRENT_SCALE
#define TOP_ADD_X           50.0 * CURRENT_SCALE
#define LABEL_HEIGHT        25.0 * CURRENT_SCALE
#define LABEL_WIDTH         160.0 * CURRENT_SCALE
#define ONLINE_WH           10.0 * CURRENT_SCALE
#define EDIT_BUTTON_WH      15.0 * CURRENT_SCALE
#define TIPLABEL_WIDTH      70.0 * CURRENT_SCALE
#define MESSAGE_WIDTH       35.0 * CURRENT_SCALE


#define BOTTOM_SPACE_X      20.0 * CURRENT_SCALE
#define BOTTOM_SPACE_Y      25.0 * CURRENT_SCALE
#define TITLE_LABEL_WIDTH   60.0 * CURRENT_SCALE
#define ITEM_WH             40.0 * CURRENT_SCALE
#define PLAY_BUTTON_WH      54.0 * CURRENT_SCALE

#import "DeviceListCell.h"


@interface DeviceListCell()

@end

@implementation DeviceListCell

- (void)awakeFromNib
{

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initUIWithDelegate:delegate];
    }
    
    return self;
}


- (void)initUIWithDelegate:(id)delegate
{
    UIImageView *bgView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, 0, SCREEN_WIDTH - 2 * SPACE_X, ROW_HEIGHT) placeholderImage:nil];
    bgView.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:bgView withCornerRadius:10.0];
    [self.contentView addSubview:bgView];
    
    float x = TOP_SPACE_X;
    float y = SPACE_Y;
    _deviceNameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, LABEL_WIDTH, LABEL_HEIGHT) textString:@"摄像头" textColor:MAIN_TEXT_COLOR textFont:FONT(17)];
    [bgView addSubview:_deviceNameLabel];
    
    y += _deviceNameLabel.frame.size.height;
    _deviceIDLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, LABEL_WIDTH, LABEL_HEIGHT) textString:@"ID:1454009" textColor:DE_TEXT_COLOR textFont:FONT(15)];
    [bgView addSubview:_deviceIDLabel];
    
    float add_x = 5.0;
    x += [_deviceIDLabel.text sizeWithFont:_deviceIDLabel.font].width + add_x;
    _editDeviceInfoButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y + (LABEL_HEIGHT - EDIT_BUTTON_WH)/2, EDIT_BUTTON_WH, EDIT_BUTTON_WH) buttonImage:@"icon_edit" selectorName:@"editButtonPressed:" tagDelegate:delegate];
    [bgView addSubview:_editDeviceInfoButton];
    
    x = TOP_SPACE_X;
    y += _deviceIDLabel.frame.size.height;
    _onlineColorView = [CreateViewTool createRoundImageViewWithFrame:CGRectMake(x, y + (LABEL_HEIGHT - ONLINE_WH)/2, ONLINE_WH, ONLINE_WH) placeholderImage:nil borderColor:nil imageUrl:nil];
    _onlineColorView.image = [CommonTool imageWithColor:DE_TEXT_COLOR];
    _onlineColorView.highlightedImage = [CommonTool imageWithColor:APP_MAIN_COLOR];
    [bgView addSubview:_onlineColorView];
    
    x = _onlineColorView.frame.origin.x + ONLINE_WH + add_x;
    _onlineStateLabel =  [CreateViewTool createLabelWithFrame:CGRectMake(x, y, LABEL_WIDTH, LABEL_HEIGHT) textString:@"在线" textColor:DE_TEXT_COLOR textFont:FONT(15)];
    [bgView addSubview:_onlineStateLabel];
    
    y += _onlineStateLabel.frame.size.height + TOP_SPACE_X;
    UIImageView *lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(TOP_SPACE_X/2, y, bgView.frame.size.width - TOP_SPACE_X, 1.0) placeholderImage:nil];
    lineImageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.5];
    [bgView addSubview:lineImageView];
    
    UIImage *defenceImage = [UIImage imageNamed:@"icon_defence_off_up"];
    float defence_width = defenceImage.size.width/2;
    float defence_height = defenceImage.size.height/2;
    
    UIImage *image = [UIImage imageNamed:@"icon_alert_up"];
    float alert_width = image.size.width/2;
    float alert_height = image.size.height/2;
    y = TOP_SPACE_Y;
    x = bgView.frame.size.width - SPACE_X - TIPLABEL_WIDTH;
    UILabel *alarmLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y + defence_height, TIPLABEL_WIDTH, LABEL_HEIGHT) textString:@"安全报警" textColor:DE_TEXT_COLOR textFont:FONT(12)];
    alarmLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:alarmLabel];
    
    x -= TIPLABEL_WIDTH;
    _defenceLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y + defence_height, TIPLABEL_WIDTH, LABEL_HEIGHT) textString:@"设防未开启" textColor:DE_TEXT_COLOR textFont:FONT(12)];
    _defenceLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_defenceLabel];

    y = TOP_SPACE_Y;
    x = alarmLabel.frame.origin.x + alarmLabel.frame.size.width/2 - alert_width/2;
    _alarmButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y + (defence_height - alert_height)/2, alert_width, alert_height) buttonImage:@"icon_alert" selectorName:@"alarmButtonPressed:" tagDelegate:delegate];
    [bgView addSubview:_alarmButton];
    
    _alarmMessageCountLabel = [CreateViewTool createLabelWithFrame:CGRectMake(_alarmButton.frame.origin.x + _alarmButton.frame.size.width - MESSAGE_WIDTH/2, y - LABEL_HEIGHT/2, MESSAGE_WIDTH, LABEL_HEIGHT) textString:@"" textColor:[UIColor whiteColor] textFont:FONT(12)];
    _alarmMessageCountLabel.textAlignment = NSTextAlignmentCenter;
    [CommonTool clipView:_alarmMessageCountLabel withCornerRadius:5.0];
    _alarmMessageCountLabel.backgroundColor = [UIColor redColor];
    _alarmMessageCountLabel.hidden = YES;
    [bgView addSubview:_alarmMessageCountLabel];
    
    x = _defenceLabel.frame.origin.x + _defenceLabel.frame.size.width/2 - defence_width/2;
    _defenceButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, defence_width, defence_height) buttonImage:@"icon_defence_off" selectorName:@"" tagDelegate:nil];
    [bgView addSubview:_defenceButton];
    
    y = lineImageView.frame.size.height + lineImageView.frame.origin.y + BOTTOM_SPACE_Y;
    x = BOTTOM_SPACE_X;
    NSArray *imageArray = @[@"icon_file",@"icon_setting",@"icon_back_video"];
    NSArray *titleArray = @[@"照片夹",@"设置",@"历史回放"];
    for (int i = 0; i < [imageArray count]; i++)
    {
        UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x + i * TITLE_LABEL_WIDTH, y + ITEM_WH, TITLE_LABEL_WIDTH, LABEL_HEIGHT) textString:titleArray[i] textColor:DE_TEXT_COLOR textFont:FONT(14)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:titleLabel];
        
        UIButton *itembutton = [CreateViewTool createButtonWithFrame:CGRectMake(titleLabel.frame.origin.x + (TITLE_LABEL_WIDTH - ITEM_WH)/2, y, ITEM_WH, ITEM_WH) buttonImage:imageArray[i] selectorName:@"itemButtonPressed:" tagDelegate:delegate];
        [bgView addSubview:itembutton];
        
        if (i == 0)
        {
            _photosbutton = itembutton;
        }
        else if (i == 1)
        {
            _settingbutton = itembutton;
        }
        else if (i == 2)
        {
            _playbackbutton = itembutton;
        }
    }
    
    x = bgView.frame.size.width - BOTTOM_SPACE_X - PLAY_BUTTON_WH;
    y += (ITEM_WH - PLAY_BUTTON_WH)/2;
    _playbutton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, PLAY_BUTTON_WH, PLAY_BUTTON_WH) buttonImage:@"icon_play" selectorName:@"playButtonPressed:" tagDelegate:delegate];
    [bgView addSubview:_playbutton];
    
    y = bgView.frame.size.height - LABEL_HEIGHT - SPACE_X;
    _showDefaultLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, bgView.frame.size.width - BOTTOM_SPACE_X, LABEL_HEIGHT) textString:@"设为首页默认显示" textColor:DE_TEXT_COLOR textFont:FONT(14)];
    _showDefaultLabel.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:_showDefaultLabel];
    
    _showDefaultButton = [CreateViewTool createButtonWithFrame:_showDefaultLabel.frame buttonImage:@"" selectorName:@"" tagDelegate:nil];
    [bgView addSubview:_showDefaultButton];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



@end
