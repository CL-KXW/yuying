//
//  StoreDiscountViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/24.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define HOST @"asset/mobile_web/index.html#"

#import "LocalWebViewController.h"
#import "NativePlugin.h"

@interface LocalWebViewController ()<UIWebViewDelegate,WebviewDelegate>

@property (nonatomic, strong) NativePlugin *natiovePlugin;
@property (nonatomic, strong) JSContext *context;

@end

@implementation LocalWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackItem];
    // Do any additional setup after loading the view.
}



#pragma mark 加载网页
- (void)loadWebView
{
    _natiovePlugin = [NativePlugin alloc];
    _natiovePlugin.delegate = self;
    
    _context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _context[@"nativePlugin"] = _natiovePlugin;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                   {
                       weakSelf.urlString = weakSelf.urlString ? weakSelf.urlString : @"";
                       NSString *htmlPath = [[[NSBundle mainBundle] resourcePath] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                       htmlPath = [htmlPath stringByAppendingPathComponent:HOST];
                       NSString *urlString = [htmlPath stringByAppendingString:weakSelf.urlString];
                       NSURL *url = [NSURL URLWithString:urlString];
                       NSLog(@"%@",url);
                       NSURLRequest *request = [NSURLRequest requestWithURL:url];
                       [weakSelf.webView loadRequest:request];
                   });
    
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*) reuqest navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"load url:%@",[reuqest URL]);
    NSString* str = [[reuqest URL]absoluteString];
    if([str hasPrefix:@"yuying"] == 1){  //如果链接以yuying开头
        NSString* path = [[reuqest URL] path];
        NSLog(@"load path:%@",path);
        if ([path isEqualToString:@"/target/dhb"]) {
            NSString* query = [[reuqest URL] query];
            NSArray* params = [query componentsSeparatedByString:@"&"];
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
            [params enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
                string = [string lowercaseString];
                NSArray *params = [string componentsSeparatedByString:@"="];
                if(params.count >= 2)
                {
                    
                    paramDict[params[0]] = [params[1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    
                }
            }];
            //弹出打电话界面
//            NSString* name = paramDict[@"phone"];
//            NSString* phone = [paramDict[@"cname"] isEqualToString:@"" ]? @"商家": paramDict[@"cname"];
//            SFJCallViewController *callViewController = [[SFJCallViewController alloc] init];
//            [callViewController setNumberString:phone];
//            [callViewController setName:name];
//            [self.navigationController pushViewController:callViewController animated:YES];
        }
    }
    return YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    NSLog(@"error===%@",error);
}


//代理方法 -- 设置标题
-(void)changeTitle:(NSString *)title
{
    self.title = title;
}

//代理方法 -- 改变type
-(void)changeType:(NSString *)newType
{
   // [self setType:newType];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.natiovePlugin.delegate = nil;
    self.natiovePlugin = nil;
    self.context = nil;
    self.webView.delegate = nil;
    self.webView = nil;
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
