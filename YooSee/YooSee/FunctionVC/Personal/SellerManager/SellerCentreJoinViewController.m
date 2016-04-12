//
//  SellerCentreJoinViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreJoinViewController.h"

#import "SellerCentreWriteDataViewController.h"
#import "WebViewController.h"

@interface SellerCentreJoinViewController ()

@property(nonatomic,weak)IBOutlet UIButton *termsOfServiceButton;
@property(nonatomic,weak)IBOutlet UIButton *joinButton;

@end

@implementation SellerCentreJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = @"商家注册";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.view.backgroundColor = RGB(234, 234, 234);
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"点击“入驻鱼鹰”即表示已阅读并同意《鱼鹰商家注册协议》"];
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:[UIColor blackColor]
                        range:NSMakeRange(0, 17)];
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:ButtonColor_Common
                        range:NSMakeRange(17, 10)];
    [self.termsOfServiceButton setAttributedTitle:attriString forState:UIControlStateNormal];
    self.termsOfServiceButton.titleLabel.numberOfLines = 0;
    
    [self.joinButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
}

#pragma mark -
-(IBAction)joinButtonClick:(id)sender{
    @autoreleasepool {
        SellerCentreWriteDataViewController *vc = Alloc_viewControllerNibName(SellerCentreWriteDataViewController);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//商家服务条款
-(IBAction)termsOfServiceButtonClick:(id)sender{
    @autoreleasepool {
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.urlString = [Url_Host stringByAppendingString:@"protocol/shopRegister"];
        webViewController.title = @"鱼鹰个人注册协议";
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

@end
