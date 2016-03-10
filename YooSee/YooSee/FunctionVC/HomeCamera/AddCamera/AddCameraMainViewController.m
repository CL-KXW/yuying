//
//  AddCameraMainViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/25.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define LABEL_HEIGHT        30.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2
#define TOP_VIEW_HEIGHT     330.0 * CURRENT_SCALE
#define BOTTOM_VIEW_HEIGHT  190.0 * CURRENT_SCALE

#define SPACE_X             10.0
#define SPACE_Y             10.0
#define ADD_Y               20.0

#define TOP_SPACE_X         25.0 * CURRENT_SCALE
#define TOP_SPACE_Y         60.0 * CURRENT_SCALE
#define TOP_ADD_Y           40.0 * CURRENT_SCALE

#define BOTTOM_SPACE_Y      25.0 * CURRENT_SCALE
#define BOTTOM_BTM_Y        15.0 * CURRENT_SCALE
#define BOTTOM_LABEL_HEIGHT 30.0 * CURRENT_SCALE



#import "AddCameraMainViewController.h"
#import "WifiPasswordViewController.h"
#import "SerachCameraViewController.h"
#import "AddCameraByIDViewController.h"
#import "AddCameraByQrcodeViewController.h"

@interface AddCameraMainViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIImageView *bottomView;

@end

@implementation AddCameraMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"添加摄像头";
    [self addBackItem];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addTableView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark 添加上视图
- (void)addTopView
{
    if (!_topView)
    {
        _topView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, 0, self.view.frame.size.width - 2 * SPACE_X, TOP_VIEW_HEIGHT) placeholderImage:nil];
        _topView.backgroundColor = [UIColor whiteColor];
        //[CommonTool setViewShadow:_topView withShadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(0, 5.0) shadowOpacity:.2];
        [CommonTool clipView:_topView withCornerRadius:10.0];
        [self.view addSubview:_topView];
        
        float y = TOP_SPACE_Y;
        UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, _topView.frame.size.width, LABEL_HEIGHT) textString:@"新摄像头,未联网?" textColor:DE_TEXT_COLOR textFont:FONT(24.0)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_topView addSubview:titleLabel];
        
        y += titleLabel.frame.size.height + TOP_ADD_Y;
        
        UILabel *tipLabel1 = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, _topView.frame.size.width, LABEL_HEIGHT) textString:@"准备好摄像头,并连接电源" textColor:MAIN_TEXT_COLOR textFont:FONT(16.0)];
        tipLabel1.textAlignment = NSTextAlignmentCenter;
        [_topView addSubview:tipLabel1];
        
        y += tipLabel1.frame.size.height;
        
        UILabel *tipLabel2 = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, _topView.frame.size.width, LABEL_HEIGHT) textString:@"摄像头与手机置于同一WIFI环境下" textColor:LIGHT_MAIN_COLOR textFont:FONT(16.0)];
        tipLabel2.textAlignment = NSTextAlignmentCenter;
        [_topView addSubview:tipLabel2];
        
        y += tipLabel2.frame.size.height + TOP_ADD_Y;
        
        UIButton *startButton = [CreateViewTool createButtonWithFrame:CGRectMake(TOP_SPACE_X, y, _topView.frame.size.width - 2 * TOP_SPACE_X, BUTTON_HEIGHT) buttonTitle:@"开始" titleColor:[UIColor grayColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:nil selectorName:@"startButtonPressed:" tagDelegate:self];
        [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [CommonTool clipView:startButton withCornerRadius:BUTTON_RADIUS];
        [CommonTool setViewLayer:startButton withLayerColor:[UIColor grayColor] bordWidth:1.0];
        [_topView addSubview:startButton];

    }
    
    //start_y = _topView.frame.origin.y + _topView.frame.size.height + ADD_Y;
    
}

#pragma mark 添加下视图
- (void)addBottomView
{
    if (!_bottomView)
    {
        _bottomView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, 0, self.view.frame.size.width - 2 * SPACE_X, BOTTOM_VIEW_HEIGHT) placeholderImage:nil];
        _bottomView.backgroundColor = [UIColor whiteColor];
        //[CommonTool setViewShadow:_topView withShadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(0, 5.0) shadowOpacity:.2];
        [CommonTool clipView:_bottomView withCornerRadius:10.0];
        [self.view addSubview:_bottomView];
        
        float y = BOTTOM_SPACE_Y;
        UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, _bottomView.frame.size.width, LABEL_HEIGHT) textString:@"添加已联网成功的摄像头" textColor:MAIN_TEXT_COLOR textFont:FONT(18.0)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_bottomView addSubview:titleLabel];
        
        NSArray *imageArray = @[@"icon_camera_id",@"icon_camera_qcode",@"icon_camera_net"];
        NSArray *titleArray = @[@" 输入ID号",@"扫描二维码",@"搜索局域网"];
        UIImage *image = [UIImage imageNamed:@"icon_camera_id_up"];
        float item_wh = image.size.width/2 * CURRENT_SCALE;
        float space_x = (_bottomView.frame.size.width - [imageArray count] * item_wh)/4;
        
        
        for (int i = 0; i < [imageArray count]; i++)
        {
            y = _bottomView.frame.size.height - BOTTOM_BTM_Y - BOTTOM_LABEL_HEIGHT;
            UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(space_x + (item_wh + space_x) * i, y, item_wh, BOTTOM_LABEL_HEIGHT) textString:titleArray[i] textColor:DE_TEXT_COLOR textFont:FONT(12.0)];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [_bottomView addSubview:label];
            
            y -= item_wh;
            UIButton *itemButton = [CreateViewTool createButtonWithFrame:CGRectMake(space_x + (item_wh + space_x) * i, y, item_wh, item_wh) buttonImage:imageArray[i] selectorName:@"itemButtonPressed:" tagDelegate:self];
            itemButton.tag = 1 + i ;
            [_bottomView addSubview:itemButton];
        }

    }
    
}


#pragma mark 开始按钮
- (void)startButtonPressed:(UIButton *)sender
{
    WifiPasswordViewController *connectWIFIViewController = [[WifiPasswordViewController alloc] init];
    [self.navigationController pushViewController:connectWIFIViewController animated:YES];
}

#pragma mark 添加
- (void)itemButtonPressed:(UIButton *)sender
{
    int tag = (int)sender.tag;
    UIViewController *viewController;
    if (tag == 1)
    {
        viewController = [[AddCameraByIDViewController alloc] init];
    }
    if (tag == 2)
    {
        viewController = [[AddCameraByQrcodeViewController alloc] init];
        ((AddCameraByQrcodeViewController *)viewController).tipString = @"设备二维码，视频二维码卡片";
    }
    if (tag == 3)
    {
        viewController = [[SerachCameraViewController alloc] init];
        
    }
    if (viewController)
    {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}


#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? TOP_VIEW_HEIGHT : BOTTOM_VIEW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? SPACE_Y : ADD_Y;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }

    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (indexPath.section == 0)
    {
        [self addTopView];
        [cell.contentView addSubview:self.topView];
    }
    if (indexPath.section == 1)
    {
        [self addBottomView];
        [cell.contentView addSubview:self.bottomView];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
