//
//  RedPackgeLibraryCell.m
//  YooSee
//
//  Created by Shaun on 16/3/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RedPackgeLibraryCell.h"
#define SPACE_X 20
#define SPACE_Y 15
#define CELL_HEIGHT 110
#define SPACE_R 12.5
@implementation RedPackgeLibraryCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = 0;
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
    }
    return self;
}

- (void)initViews {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.moneyLabel];
}

- (UIImageView*)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SPACE_X, SPACE_Y, 60, 80)];
        _iconImageView.image = [UIImage imageNamed:@"icon_bongbao1.png"];
    }
    return _iconImageView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, SPACE_Y, SCREEN_WIDTH - SPACE_R - 90, 20)];
        _nameLabel.textColor = RGB(84, 84, 84);
        _nameLabel.font = FONT(17);
    }
    return _nameLabel;
}

- (UILabel*)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, SCREEN_WIDTH - SPACE_R - 90, 20)];
        _descLabel.textColor = RGB(205, 205, 205);
        _descLabel.font = FONT(12);
    }
    return _descLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 75, SCREEN_WIDTH - SPACE_R - 90, 20)];
        _timeLabel.textColor = RGB(205, 205, 205);
        _timeLabel.font = FONT(12);
    }
    return _timeLabel;
}

- (UILabel*)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90 - SPACE_R, 75, 90, 20)];
        _moneyLabel.textColor = RGB(200, 0, 0);
        _moneyLabel.font = FONT(17);
        _moneyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLabel;
}

+ (CGFloat)cellHeight {
    return CELL_HEIGHT;
}
@end
