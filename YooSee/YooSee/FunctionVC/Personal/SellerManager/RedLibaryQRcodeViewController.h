//
//  RedLibaryQRcodeViewController.h
//  YooSee
//
//  Created by 周后云 on 16/3/16.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

typedef NS_ENUM(NSUInteger, QRcodeType) {
    QRcodeType_redLibary = 0,
    QRcodeType_advertisement = 1,
};

@interface RedLibaryQRcodeViewController : BasicViewController

@property(nonatomic,strong)NSDictionary *dic;
@property(nonatomic)QRcodeType type;

@end
