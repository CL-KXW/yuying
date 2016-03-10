//
//  RegistRulesViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RegistRulesViewController.h"

@interface RegistRulesViewController ()

@end

@implementation RegistRulesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"鱼鹰使用条款及规则";
    // Do any additional setup after loading the view.
}

#pragma mark 加载网页
- (void)loadWebView
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                   {
                       NSString *htmlPath = [[[NSBundle mainBundle] resourcePath] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                       NSString *path = [[NSBundle mainBundle] pathForResource:@"rule.txt" ofType:nil];
                       NSData *data = [NSData dataWithContentsOfFile:path];
                       
                       [weakSelf.webView loadData:data MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:htmlPath]];
                   });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
