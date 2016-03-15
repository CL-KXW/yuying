//
//  SettingCameraMainViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define ROW_HEIGHT2     55.0
#define ROW_HEIGHT1     100.0
#define SPACE_X         10.0
#define SPACE_Y         10.0
#define ADD_X           10.0
#define LABEL_WIDTH     200.0

#import "SettingCameraMainViewController.h"
#import "SetCameraInfoViewController.h"
#import "SetCameraPasswordViewController.h"
#import "SetCameraTimeViewController.h"
#import "SetCameraRecordAudioViewController.h"
#import "SetCameraAlarmViewController.h"
#import "SetCameraNetworkViewController.h"
#import "SetCameraDefenceAreaViewController.h"

@interface SettingCameraMainViewController ()

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation SettingCameraMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    [self addBackItem];
    
    [self initData];
    [self initUI];
    
    // Do any additional setup after loading the view.
}

#pragma mark 初始化数据
- (void)initData
{
    _imageArray = @[@"camera_icon_default",@"setting_warn",@"setting_record",@"setting_defence",@"setting_time",@"setting_network",@"setting_password"];
    _titleArray = @[self.contact.contactName,@"报警设置",@"录像设置",@"防区设置",@"时间设置",@"网络设置",@"密码设置"];
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addTableView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
}

#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.imageArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? ROW_HEIGHT1 : ROW_HEIGHT2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }


    UIImage *image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    
    if (indexPath.row == 0)
    {
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        float x = SPACE_X;
        UIImageView *imageView = [CreateViewTool createRoundImageViewWithFrame:CGRectMake(x, SPACE_Y, ROW_HEIGHT1 - 2 * SPACE_X, ROW_HEIGHT1 - 2 * SPACE_Y) placeholderImage:image borderColor:DE_TEXT_COLOR imageUrl:self.imageUrl];
        [cell.contentView addSubview:imageView];
        
        x += imageView.frame.size.width + ADD_X;
        UILabel *nameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, 0, LABEL_WIDTH, ROW_HEIGHT1) textString:self.contact.contactName textColor:DE_TEXT_COLOR textFont:FONT(16.0)];
        [cell.contentView addSubview:nameLabel];
        cell.textLabel.text = @"";
    }
    else
    {
        cell.imageView.image = image;
        cell.textLabel.text = self.titleArray[indexPath.row];
        cell.textLabel.font = FONT(16.0);
        cell.textLabel.textColor = DE_TEXT_COLOR;
    }
    


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingCameraBasicViewController *viewController;
    if (indexPath.row == 0)
    {
        SetCameraInfoViewController *setCameraInfoViewController = [[SetCameraInfoViewController alloc] init];
        setCameraInfoViewController.imageUrl = self.imageUrl;
        setCameraInfoViewController.contact = self.contact;
        setCameraInfoViewController.deviceID = self.contact.contactId;
        [self.navigationController pushViewController:setCameraInfoViewController animated:YES];
        return;
    }
    if (indexPath.row == 1)
    {
        viewController = [[SetCameraAlarmViewController alloc] init];
    }
    if (indexPath.row == 2)
    {
        viewController = [[SetCameraRecordAudioViewController alloc] init];
    }
    if (indexPath.row == 3)
    {
        viewController = [[SetCameraDefenceAreaViewController alloc] init];
    }
    if (indexPath.row == 4)
    {
        viewController = [[SetCameraTimeViewController alloc] init];
    }
    if (indexPath.row == 5)
    {
        viewController = [[SetCameraNetworkViewController alloc] init];
    }
    if (indexPath.row == 6)
    {
        viewController = [[SetCameraPasswordViewController alloc] init];
    }
    if (viewController)
    {
        viewController.imageUrl = self.imageUrl;
        viewController.contact = self.contact;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
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
