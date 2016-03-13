//
//  PlayerAdvDetailViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/12.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "PlayerAdvDetailViewController.h"
#import "CameraMainViewController.h"

@interface PlayerAdvDetailViewController ()

@end

@implementation PlayerAdvDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackItem];
    // Do any additional setup after loading the view.
}

- (void)backButtonPressed:(UIButton *)sender
{
    CameraMainViewController *cameraMainViewController = [[CameraMainViewController alloc] init];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([array[1] isKindOfClass:[CameraMainViewController class]])
    {
        [array replaceObjectAtIndex:1 withObject:cameraMainViewController];
    }
    self.navigationController.viewControllers = array;
    [self.navigationController popViewControllerAnimated:YES];
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
