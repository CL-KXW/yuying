//
//  SetCameraInfoViewController.h
//  YooSee
//
//  Created by chenlei on 16/2/27.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"
#import "Contact.h"

@interface SetCameraInfoViewController : BasicViewController

@property (nonatomic, strong) NSString *deviceNo;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) NSString *imageUrl;

@end
