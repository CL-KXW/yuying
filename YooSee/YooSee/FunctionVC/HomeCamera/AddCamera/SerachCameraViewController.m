//
//  SerachCameraViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/25.
//  Copyright © 2016年 chenlei. All rights reserved.
//


#define ROW_HEIGHT     80.0 * CURRENT_SCALE
#define BUTTON_WIDTH   60.0 * CURRENT_SCALE
#define BUTTON_HEIGHT  40.0 * CURRENT_SCALE
#define BUTTON_RADIUS  BUTTON_HEIGHT/2

#import "SerachCameraViewController.h"
#import "RadarView.h"
#import "GCDAsyncUdpSocket.h"
#import "CameraPasswordViewController.h"
#import "mesg.h"


@interface SerachCameraViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) RadarView  *searchAnimateView;
@property (nonatomic, strong) GCDAsyncUdpSocket *socket;
@property (nonatomic, assign) BOOL isRun;
@property (nonatomic, assign) BOOL isPrepared;
@property (nonatomic, strong) NSMutableArray *deviceInfoArray;
@property (nonatomic, strong) NSMutableArray *deviceIDArray;

@end

@implementation SerachCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"加载";
    [self addBackItem];
    
    [self initUI];
    
    [self startSearchDeviceInLan];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isRun = NO;
    if(self.socket)
    {
        [self.socket close];
        self.socket=nil;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    self.isRun = YES;
    self.isPrepared = NO;
    [self startSearchDeviceInLan];
}


#pragma mark 初始化UI

- (void)initUI
{
    [self addTableView];
    [self addSearchView];
}


- (void)addSearchView
{
    _searchAnimateView = [[RadarView alloc] init];
    [self.view addSubview:_searchAnimateView];
}

- (void)addTableView
{
    _deviceInfoArray = [NSMutableArray arrayWithCapacity:0];
    _deviceIDArray = [NSMutableArray arrayWithCapacity:0];
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.backgroundColor = [UIColor whiteColor];
}


#pragma mark - Create GCDAsyncUdpSocket

//开始在局域网内搜索设备
- (void)startSearchDeviceInLan
{
    self.isRun = YES;
    self.isPrepared = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        while(weakSelf.isRun)
        {
            if(!weakSelf.isPrepared)
            {
                if (!(weakSelf.isPrepared = [weakSelf prepareSocket])
                    && weakSelf.socket)
                {
                    [weakSelf.socket close];
                }
                else
                    [weakSelf sendUDPBroadcast];
            }
            else
            {
                [weakSelf sendUDPBroadcast];
            }
            usleep(1000000);
        }
    });
    
}

- (BOOL)prepareSocket
{
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    
    int port = 9988;
    
    if (![socket bindToPort:port error:&error])
    {
        NSLog(@"Error binding: %@", [error localizedDescription]);
        return NO;
    }
    if (![socket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", [error localizedDescription]);
        return NO;
    }
    
    if (![socket enableBroadcast:YES error:&error])
    {
        NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
        return NO;
    }
    
    self.socket = socket;
    self.isPrepared = YES;
    return YES;
}


- (void)sendUDPBroadcast
{
    NSString *host = @"255.255.255.255";
    int port = 8899;

    
    sMesgShakeType message;
    message.dwCmd = LAN_TRANS_SHAKE_GET;
    message.dwStructSize = 28;
    message.dwStrCon = 0;
    
    Byte sendBuffer[1024];
    memset(sendBuffer, 0, 1024);
    sendBuffer[0] = 1;
    
    [self.socket sendData:[NSData dataWithBytes:sendBuffer length:1024]
                   toHost:host port:port withTimeout:-1 tag:0];
}




#pragma mark - GCDAsyncUdpSocket delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose %@", error);
    
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (data)
    {
        Byte receiveBuffer[1024];
        [data getBytes:receiveBuffer length:1024];
        
        if(receiveBuffer[0] == 2 || receiveBuffer[0] == 1)
        {
            NSString *host = nil;
            uint16_t port = 0;
            [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
            
            int contactId = *(int*)(&receiveBuffer[16]);
            int type = *(int*)(&receiveBuffer[20]);
            int flag = *(int*)(&receiveBuffer[24]);
            NSLog(@"%i:%i:%i",contactId,type,flag);
            
            NSString *cameraID = [NSString stringWithFormat:@"%d",contactId];
            if ([self.deviceIDArray containsObject:cameraID])
            {
                return;
            }
            
            [self.deviceIDArray addObject:cameraID];
            
            NSDictionary *infoDic = @{@"contactId":@(contactId),@"type":@(type),@"flag":@(flag),@"address":host};
            [self.deviceInfoArray addObject:infoDic];
            
            
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [weakSelf.table reloadData];
                [weakSelf.searchAnimateView endAnimating];
                weakSelf.title = @"摄像头";
            });
        }
    }
}


#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deviceInfoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
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

    if (self.deviceInfoArray && [self.deviceInfoArray count] > indexPath.row)
    {
        NSDictionary *infoDic = self.deviceInfoArray[indexPath.row];
        NSString *deviceID = [NSString stringWithFormat:@"%d",[infoDic[@"contactId"] intValue]];
        cell.textLabel.text = [@"      ID: " stringByAppendingString:deviceID];
        cell.textLabel.font = FONT(16.0);
        cell.textLabel.textColor = MAIN_TEXT_COLOR;
        cell.imageView.image = [UIImage imageNamed:@"camera_icon"];
        
        NSString *title = @"添加";
        UIColor *color = APP_MAIN_COLOR;
        if ([self isCameraAdded:deviceID])
        {
            title = @"已添加";
            color = [UIColor lightGrayColor];
        }
        
        UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT) buttonTitle:title titleColor:[UIColor whiteColor] normalBackgroundColor:color highlightedBackgroundColor:nil selectorName:@"addButtonPressed:" tagDelegate:self];
        [CommonTool clipView:button withCornerRadius:BUTTON_RADIUS];
        button.tag = indexPath.row + 1;
        cell.accessoryView = button;
        button.enabled = !([self isCameraAdded:deviceID]);
    }
    
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 是否已添加
- (BOOL)isCameraAdded:(NSString *)deviceID
{
    BOOL isAdd = NO;
    deviceID = deviceID ? deviceID : @"";
    if (deviceID.length == 0)
    {
        return YES;
    }
    
    NSArray *deviceArray = [YooSeeApplication shareApplication].devInfoListArray;
    if (!deviceArray || [deviceArray count] == 0)
    {
        isAdd = NO;
    }
    else
    {
        for (NSDictionary *dataDic in deviceArray)
        {
            NSString *contactID = dataDic[@"camera_number"];
            contactID = contactID ? contactID : @"";
            if ([contactID isEqualToString:deviceID])
            {
                isAdd = YES;
                break;
            }
        }
    }
    return isAdd;
}

#pragma mark 添加按钮
- (void)addButtonPressed:(UIButton *)sender
{
    int tag = (int)sender.tag - 1;
    NSString *deviceID = self.deviceIDArray[tag];
    CameraPasswordViewController *cameraPasswordViewController = [[CameraPasswordViewController alloc] init];
    cameraPasswordViewController.deviceID = deviceID;
    cameraPasswordViewController.isChange = NO;
    [self.navigationController pushViewController:cameraPasswordViewController animated:YES];
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
