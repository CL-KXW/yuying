//
//  BasicViewController.m
//  GeniusWatch
//
//  Created by chenlei on 15/8/22.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//

#import "BasicViewController.h"




@interface BasicViewController ()

@end

@implementation BasicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    //[self.navigationController.navigationBar setBackgroundImage:[CommonTool imageWithColor:NAVBAR_COLOR] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:FONT(17.0)}];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationController.navigationBar.translucent = YES;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//#pragma mark 设置statusBarStyle
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark 设置导航条Item

// 1.设置导航条Item
- (void)setNavBarItemWithTitle:(NSString *)title navItemType:(NavItemType)type selectorName:(NSString *)selName
{
    //UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
    //                                                                               target:nil action:nil];
    //negativeSpacer.width = (LeftItem == type) ? -15 : 15;
    //float x = negativeSpacer.width;
    //float x = (LeftItem == type) ? negativeSpacer.width : 0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //button.frame = CGRectMake(x, 0, 60, 30);
    button.frame = CGRectMake(0, 0, 80, 30);
    button.showsTouchWhenHighlighted = YES;
    button.titleLabel.font = FONT(17.0);
    [button setTitleColor:APP_MAIN_COLOR forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    if (selName && ![@"" isEqualToString:selName])
    {
        [button addTarget:self action:NSSelectorFromString(selName) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem  *barItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    if(LeftItem == type)
        //self.navigationItem.leftBarButtonItems = @[negativeSpacer,barItem];
        self.navigationItem.leftBarButtonItems = @[barItem];
    else if (RightItem == type)
        self.navigationItem.rightBarButtonItems = @[barItem];
}


// 2.设置导航条Item
- (void)setNavBarItemWithImageName:(NSString *)imageName navItemType:(NavItemType)type selectorName:(NSString *)selName
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil action:nil];
    negativeSpacer.width = (LeftItem == type) ? -15 : 15;
    //float x = (LeftItem == type) ? negativeSpacer.width : 0;
    //float x = negativeSpacer.width;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image_up = [UIImage imageNamed:[imageName stringByAppendingString:@"_up"]];
    UIImage *image_down = [UIImage imageNamed:[imageName stringByAppendingString:@"_down"]];
    if (!image_up && !image_down)
    {
        image_up = [UIImage imageNamed:imageName];
    }
    
    //button.frame = CGRectMake(x, 0, image_up.size.width/2, image_up.size.height/2);
    button.frame = CGRectMake(0, 0, image_up.size.width/2, image_up.size.height/2);
    [button setBackgroundImage:image_up forState:UIControlStateNormal];
    if (!image_down)
    {
        [button setBackgroundImage:image_down forState:UIControlStateHighlighted];
        [button setBackgroundImage:image_down forState:UIControlStateSelected];
    }

    if (selName && ![@"" isEqualToString:selName])
    {
        [button addTarget:self action:NSSelectorFromString(selName) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem  *barItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    if(LeftItem == type)
        //self.navigationItem.leftBarButtonItems = @[negativeSpacer,barItem];
        self.navigationItem.leftBarButtonItems = @[barItem];
    else if (RightItem == type)
        self.navigationItem.rightBarButtonItems = @[barItem];
}



#pragma mark 添加返回Item
//添加返回按钮
- (void)addBackItem
{
    [self setNavBarItemWithImageName:@"back" navItemType:LeftItem selectorName:@"backButtonPressed:"];
}

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 添加表
//添加表
- (void)addTableViewWithFrame:(CGRect)frame tableType:(UITableViewStyle)type tableDelegate:(id)delegate
{
    _table = [[UITableView alloc]initWithFrame:frame style:type];
    _table.dataSource=delegate;
    _table.delegate=delegate;
    _table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_table];
    [self setExtraCellLineHidden:_table];
}


- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}


#pragma mark 添加刷新试图
- (void)addRefreshHeaderView
{
    if (_refreshHeaderView)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    _refreshHeaderView = [MJRefreshHeaderView header];
    _refreshHeaderView.scrollView = self.table;
    _refreshHeaderView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView)
    {
        [weakSelf refreshData];
    };

}

- (void)refreshData
{

}

#pragma mark 添加加载更多视图
- (void)addRefreshFooterView
{
    if (_refreshFooterView)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    _refreshFooterView = [MJRefreshFooterView footer];
    _refreshFooterView.scrollView = self.table;
    _refreshFooterView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView)
    {
        [weakSelf getMoreData];
    };
}

- (void)getMoreData
{
    
}



#pragma mark 方位
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_refreshHeaderView free];
    [_refreshFooterView free];
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
