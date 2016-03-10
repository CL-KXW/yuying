//
//  WebViewController.h
//  GeniusWatch
//
//  Created by clei on 15/9/16.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

@interface WebViewController : BasicViewController

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) UIWebView *webView;

@end
