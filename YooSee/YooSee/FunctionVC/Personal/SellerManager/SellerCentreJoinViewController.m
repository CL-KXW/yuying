//
//  SellerCentreJoinViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreJoinViewController.h"

@interface SellerCentreJoinViewController ()

@property(nonatomic,weak)IBOutlet UIButton *termsOfServiceButton;
@property(nonatomic,weak)IBOutlet UIButton *joinButton;

@end

@implementation SellerCentreJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"商家注册";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"点击“入驻鱼鹰”即表示已阅读并同意《商家服务条款》"];
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:[UIColor blackColor]
                        range:NSMakeRange(0, 17)];
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:[UIColor yellowColor]
                        range:NSMakeRange(17, 8)];
    [self.termsOfServiceButton setAttributedTitle:attriString forState:UIControlStateNormal];
}

#pragma mark -
-(IBAction)joinButtonClick:(id)sender{
    @autoreleasepool {
        
    }
}

-(IBAction)termsOfServiceButtonClick:(id)sender{
    @autoreleasepool {
        
    }
}

@end
