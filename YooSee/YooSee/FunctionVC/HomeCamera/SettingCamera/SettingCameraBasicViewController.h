//
//  SettingCameraBasicViewController.h
//  YooSee
//
//  Created by 陈磊 on 16/3/12.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"
#import "Contact.h"
#import "P2PClient.h"
#import "FListManager.h"

@interface SettingCameraBasicViewController : BasicViewController

@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) NSString *imageUrl;

@end
