//
//  PlayBackViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y         15.0 * CURRENT_SCALE
#define LABEL_HEIGHT    30.0 * CURRENT_SCALE
#define IMAGEVIEW_WH    100.0 * CURRENT_SCALE
#define BUTTON_HEIGHT   45.0
#define SECTION_HEIGHT  LABEL_HEIGHT + IMAGEVIEW_WH + BUTTON_HEIGHT + SPACE_Y

#import "ReplayRecordFileViewController.h"
#import "P2PClient.h"

@interface ReplayRecordFileViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) NSMutableArray *recordFileArray;

@end

@implementation ReplayRecordFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"回放";
    [self addBackItem];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

#pragma mark 初始化uI
- (void)initUI
{
    [self addTableView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
}


#pragma mark - 接收设备通知消息
- (void)receiveRemoteMessage:(NSNotification *)notification
{
    NSDictionary *parameter = [notification userInfo];
    int key = [[parameter valueForKey:@"key"] intValue];
    switch(key)
    {
        case RET_GET_PLAYBACK_FILES:
        {
            NSArray *array = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"files"]];
            NSArray *times = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"times"]];
            if([array count] == 0 )
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    [CommonTool addPopTipWithMessage:@"暂无数据"];
                });
                return;
            }
            
            if( [array count] == 1 && [_recordFileArray containsObject:array[0]])
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    [CommonTool addPopTipWithMessage:@"没有更多数据"];
                });
                return;
            }
            
//            recordFileArray = [NSMutableArray arrayWithArray:array];
//            recordTimeArray = [NSMutableArray arrayWithArray:times];
//            //读取每个新接收的文件类型，并加入数组中
//            /*int num = [[P2PClient sharedClient] getPlaybackFilesLength];
//             sRecFilenameType* typeArray = [[P2PClient sharedClient] getPlaybackFilenameTypeCArray];
//             if(num > maxLenOfTypeArray-curLenOfTypeArray)
//             {//如果数组剩余空间不足，重新分配内存
//             maxLenOfTypeArray += 1000;
//             sRecFilenameType* newArray = malloc(maxLenOfTypeArray*sizeof(sRecFilenameType));
//             memcpy(newArray, recordFilenameTypeArray, curLenOfTypeArray*sizeof(sRecFilenameType));
//             free(recordFilenameTypeArray);
//             recordFilenameTypeArray = newArray;
//             }
//             memcpy(recordFilenameTypeArray+curLenOfTypeArray*sizeof(sRecFilenameType),typeArray, num*sizeof(sRecFilenameType));
//             curLenOfTypeArray += num;*/
//            
//            
//            if([recordTimeArray count] > 0)
//                nextStartTime = [recordTimeArray lastObject];
//            else
//            {//因为有时接收的时间数组为空，所以，把文件名中包含的时间字符串截取出来
//                NSString *lastFileName = [recordFileArray lastObject];
//                NSRange range;
//                range.location = 6;
//                range.length = 16;
//                lastFileName = [lastFileName substringWithRange:range];
//                nextStartTime = [lastFileName stringByReplacingOccurrencesOfString:@"_" withString:@" "];
//            }
//            
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                topReached = NO;
//                [table setHidden:NO];
//                [scrollView setHidden:YES];
//                [table reloadData];
//                [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//                
//            });
            //NSLog(@"%d",[array count]);
            // NSLog(@"%d",[[P2PClient sharedClient]getPlaybackFilesLength]);
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification
{
    
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    __weak typeof(self) weakSelf = self;
    switch(key){
        case ACK_RET_GET_PLAYBACK_FILES:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if(result==1)
                {
                    [CommonTool addPopTipWithMessage:@"设备密码错误"];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                    {
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    });
                }
                else if(result==2)
                {
                    [CommonTool addPopTipWithMessage:@"网络异常"];
                }

            });
        }
            break;
    }
    
}


#pragma mark UITableViewDelegate&UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_headerView)
    {
        _headerView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SECTION_HEIGHT) placeholderImage:nil];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        float y = SPACE_Y;
        UIImageView *iconImageView = [CreateViewTool createRoundImageViewWithFrame:CGRectMake((_headerView.frame.size.width - IMAGEVIEW_WH)/2, y, IMAGEVIEW_WH, IMAGEVIEW_WH) placeholderImage:[UIImage imageNamed:@"camera_icon_default"] borderColor:DE_TEXT_COLOR imageUrl:self.imageUrl];
        [_headerView addSubview:iconImageView];
        
        y += iconImageView.frame.size.height;
        
        UILabel *nameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, _headerView.frame.size.width, LABEL_HEIGHT) textString:@"" textColor:DE_TEXT_COLOR textFont:FONT(16)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = self.contact.contactName;
        [_headerView addSubview:nameLabel];
        
        y += nameLabel.frame.size.height;
        NSArray *array = @[@"最近一天",@"最近三天",@"最近一月"];
        float width = _headerView.frame.size.width/[array count];
        for (int i = 0; i < [array count]; i++)
        {
            UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(width * i, y, width, BUTTON_HEIGHT) buttonTitle:array[i] titleColor:MAIN_TEXT_COLOR normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:[UIColor clearColor] selectorName:@"itemButotnPressed:" tagDelegate:self];
            button.tag = 100 + i;
            [CommonTool setViewLayer:button withLayerColor:DE_TEXT_COLOR bordWidth:.5];
            [_headerView addSubview:button];
            
            if (i == 0)
            {
                _lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y + button.frame.size.height - 2, button.frame.size.width, 2.0) placeholderImage:nil];
                _lineImageView.backgroundColor = RGB(251.0,80.0,36.0);
                [_headerView addSubview:_lineImageView];
            }
        }
        
        //请求最近一天录像文件列表
        [LoadingView showLoadingView];
        [[P2PClient sharedClient] getPlaybackFilesWithId:self.contact.contactId password:self.contact.contactPassword timeInterval:1];
    }
    
    return _headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recordFileArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.text = @"1";

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark 选项卡
- (void)itemButotnPressed:(UIButton *)sender
{
    [UIView animateWithDuration:.35 animations:^
    {
        _lineImageView.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y + sender.frame.size.height - 2, sender.frame.size.width, 2.0);
    }];
    
    int index = (int)sender.tag - 100;
    NSArray *array = @[@(1),@(3),@(31)];
    //请求最近一天录像文件列表
    [[P2PClient sharedClient] getPlaybackFilesWithId:self.contact.contactId password:self.contact.contactPassword timeInterval:[array[index] intValue]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
