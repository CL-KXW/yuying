//
//  SettingViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define ROW_HEIGHT          50.0 * CURRENT_SCALE
#define SPACE_X             10.0
#define SPACE_Y             10.0 * CURRENT_SCALE

#import "SettingViewController.h"
#import "WebViewController.h"
#import "AboutUsViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    [self addBackItem];
    
    _titleArray = @[@" 帮助",@" 关于鱼鹰"];
    
    [self initUI];
    // Do any additional setup after loading the view.
}


#pragma mark 初始化UI
- (void)initUI
{
    [self addBgView];
    [self addTableView];
}

- (void)addBgView
{
    UIImageView *imageView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, SPACE_Y + START_HEIGHT, self.view.frame.size.width - 2 * SPACE_X, [self.titleArray count] * ROW_HEIGHT) placeholderImage:nil];
    imageView.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:imageView withCornerRadius:10.0];
    [self.view addSubview:imageView];
}

- (void)addTableView
{

    [self addTableViewWithFrame:CGRectMake(0, START_HEIGHT, self.view.frame.size.width, [self.titleArray count] * ROW_HEIGHT) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.scrollEnabled = NO;
    [self.view addSubview:self.table];
}

#pragma mark - tableView datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SPACE_Y;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.textLabel.font = FONT(16.0);

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    int row = indexPath.row;
    if (row == 1)
    {
        AboutUsViewController *aboutUsViewController = [[AboutUsViewController alloc] init];
        [self.navigationController pushViewController:aboutUsViewController animated:YES];
    }
    else if (row == 0)
    {
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.title = @"帮助";
        webViewController.urlString = HELP_URL;
        [self.navigationController pushViewController:webViewController animated:YES];
    }

}


- (void)didReceiveMemoryWarning
{
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
