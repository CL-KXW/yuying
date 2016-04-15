//
//  TempPicViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/4/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "TempPicViewController.h"
#import "FunctionViewController.h"

@interface TempPicViewController ()

@end

@implementation TempPicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addBackItem];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollView.scrollEnabled = NO;
    [self.view addSubview:scrollView];
    
    UIImage *image = [UIImage imageNamed:_imageString];
    if (image)
    {
        UIImageView *imageView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*image.size.height/image.size.width) placeholderImage:image];
        scrollView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
        [scrollView addSubview:imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturehandle:)];
        [imageView addGestureRecognizer:tapGesture];
        
    }
    
    // Do any additional setup after loading the view.
}


- (void)tapGesturehandle:(UITapGestureRecognizer *)tapGesture
{
    FunctionViewController *functionViewController = [[FunctionViewController alloc] init];
    [self.navigationController pushViewController:functionViewController animated:YES];
}

@end
