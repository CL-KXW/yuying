//
//  SendRedLibaryViewController.h
//  YooSee
//
//  Created by 周后云 on 16/3/23.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

typedef NS_ENUM(NSUInteger, RedLibaryType) {
    RedLibaryType_immediate = 0,
    RedLibaryType_qrCode,
    RedLibaryType_shake,
};

@interface SendRedLibaryViewController : BasicViewController

@property(nonatomic)RedLibaryType type;
@property(nonatomic,strong)NSNumber *shop_number;

@end
