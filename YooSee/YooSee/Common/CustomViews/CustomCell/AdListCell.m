//
//  AdListCell.m
//  YooSee
//
//  Created by Shaun on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define IMAGE_HEIGHT    281.5 * CURRENT_SCALE
#define BOTTOM_HEIGHT   35
#define CELL_HEIGHT     (IMAGE_HEIGHT + BOTTOM_HEIGHT)
#define SPACE_X         12
#define SPACE_Y         12
#define TIME_LABEL_W    80
#define LABEL_H         20

#import "AdListCell.h"
@interface AdListCell ()
/**
 *  描述
 */
@property (nonatomic, strong) UILabel *descLabel;
/**
 *  描述背景图
 */
@property (nonatomic, strong) UIImageView *descBgView;
@end

@implementation AdListCell

+ (CGFloat)cellHeight {
    return CELL_HEIGHT;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
    }
    return self;
}

- (void)initViews {
    [self.contentView addSubview:self.adView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.descBgView];
    [self.contentView addSubview:self.descLabel];
}

- (UIImageView*)adView {
    if (!_adView) {
        _adView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IMAGE_HEIGHT)];
        _adView.contentMode = UIViewContentModeScaleAspectFit;
        _adView.clipsToBounds = YES;
    }
    return _adView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACE_X, IMAGE_HEIGHT + (BOTTOM_HEIGHT - LABEL_H) * 0.5 , SCREEN_HEIGHT - SPACE_X - SPACE_Y - TIME_LABEL_W, LABEL_H)];
        _nameLabel.font = FONT(12);
        _nameLabel.textColor = RGB(74, 74, 74);
    }
    return _nameLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - SPACE_Y - TIME_LABEL_W, IMAGE_HEIGHT + (BOTTOM_HEIGHT - LABEL_H) * 0.5 , TIME_LABEL_W, LABEL_H)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = FONT(9);
        _timeLabel.textColor = RGB(155, 155, 155);
    }
    return _timeLabel;
}

- (UILabel*)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - SPACE_Y - TIME_LABEL_W, IMAGE_HEIGHT - 30, TIME_LABEL_W, LABEL_H)];
        _descLabel.textAlignment = NSTextAlignmentRight;
        _descLabel.font = FONT(9);
        _descLabel.textColor = [UIColor whiteColor];
    }
    return _descLabel;
}

- (UIImageView*)descBgView {
    if (!_descBgView) {
        _descBgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - TIME_LABEL_W, IMAGE_HEIGHT - 30, TIME_LABEL_W + SPACE_Y, LABEL_H)];
    }
    return _descBgView;
}

- (void)dealHadGet:(BOOL)hadGet descTitle:(NSString*)descTitle {
    if (hadGet) {
        self.descBgView.image = [UIImage imageNamed:@"img_tab_bg_2.png"];
        self.descLabel.text = @"您已领取";
    } else {
        self.descBgView.image = [UIImage imageNamed:@"img_tab_bg_1.png"];
        self.descLabel.text = descTitle;
    }
}
@end
