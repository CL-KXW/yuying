//
//  RedLibaryManageViewController.h
//  YooSee
//
//  Created by 周后云 on 16/3/15.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

typedef NS_ENUM(NSUInteger, ManageType) {
    ManageType_redLibary = 0,
    ManageType_advertisement,
};

@interface RedLibaryManageViewController : BasicViewController

@property(nonatomic)ManageType type;

@end
