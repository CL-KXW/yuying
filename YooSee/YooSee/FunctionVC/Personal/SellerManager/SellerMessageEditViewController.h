//
//  SellerMessageEditViewController.h
//  YooSee
//
//  Created by 周后云 on 16/3/29.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"
#import "ResponseSellerMessage.h"

@interface SellerMessageEditViewController : BasicViewController

@property(nonatomic,strong)NSNumber *id;
@property(nonatomic,strong)SellerMessage *sellerMessage;


@end
