//
//  QrCodeBaseViewController.h
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

@interface QrCodeBaseViewController : BasicViewController

@property (nonatomic, strong) NSString *tipString;

- (void)getQrcodeSucess:(NSString *)qrCodeString;

@end
