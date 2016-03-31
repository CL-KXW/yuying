//
//  RobRedPackgeListCell.m
//  YooSee
//
//  Created by Shaun on 16/3/16.
//  Copyright © 2016年 chenlei. All rights reserved.
//
#define ICON_HEIGHT     60 * CURRENT_SCALE
#define CELL_HEIGHT     90*CURRENT_SCALE
#define SPACE_X         12
#define LABEL_W         180*CURRENT_SCALE
#define LABEL_H         50
#import "RobRedPackgeListCell.h"

@implementation RobRedPackgeListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = 0;
        [self initViews];
    }
    return self;
}

- (void)initViews {
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(SPACE_X, 0, SCREEN_WIDTH - 2 * SPACE_X, CELL_HEIGHT)];
    bgView.image = [UIImage imageNamed:@"img_hongbao_bg.png"];
    UIImageView *hongbao = [[UIImageView alloc] initWithFrame:CGRectMake(115 * CURRENT_SCALE, 20 * CURRENT_SCALE, 40 * CURRENT_SCALE, 50 * CURRENT_SCALE)];
    hongbao.image = [UIImage imageNamed:@"icon_bongbao1.png"];
    [self.contentView addSubview:bgView];
    [self.contentView addSubview:hongbao];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.descLabel];
}

- (UILabel*)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - LABEL_W - 25, 20 * CURRENT_SCALE, LABEL_W, LABEL_H)];
        _descLabel.font = FONT(14);
        _descLabel.textColor = [UIColor whiteColor];
    }
    return _descLabel;
}

- (UIImageView*)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 15, ICON_HEIGHT, ICON_HEIGHT)];
        [CommonTool setViewLayer:_iconImageView withLayerColor:[UIColor lightGrayColor] bordWidth:.5];
    }
    return _iconImageView;
}

+ (CGFloat)cellHeight {
    return CELL_HEIGHT;
}
@end
