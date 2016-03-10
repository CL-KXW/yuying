//
//  CameraFileViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/5.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SEGMENTVIEW_HEIGHT      44.0

#import "CameraFileViewController.h"
#import "SegmentView.h"
#import "UDManager.h"
#import "Utils.h"
#import "ScreenshotCell.h"
#import "PhotoHandleView.h"
#import "AVPlayerViewController.h"

@interface CameraFileViewController ()<UITableViewDataSource,UITableViewDelegate,SegmentViewDelegate,AVPlayerVCDelegate>

@property (strong, nonatomic) NSMutableArray *screenshotFilesArray;
@property (strong, nonatomic) NSMutableArray *recordFilesArray;
@property (strong, nonatomic) SegmentView *segmentView;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation CameraFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"照片夹";
    [self addBackItem];
    
    [self initUI];
    
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initData) name:@"RefreshFiles" object:nil];
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
    self.table.backgroundColor = [UIColor whiteColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
}


#pragma mark 初始化数据
- (void)initData
{
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    if (_segmentView.selectedIndex == 0)
    {
        //从本地中获取图片
        NSArray *datas = [NSArray arrayWithArray:[Utils getScreenshotFilesWithId:loginResult.contactId]];
        self.screenshotFilesArray = [NSMutableArray arrayWithArray:datas];
    }
    else
    {
        //获取录像文件数据
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *savePath = [NSString stringWithFormat:@"%@/videorecord/%@",rootPath,loginResult.contactId];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *files = [manager subpathsAtPath:savePath];
        NSMutableArray *videoFiles = [NSMutableArray arrayWithCapacity:0];
        for(NSString *str in files)
        {
            if([str hasSuffix:@".png"])
            {
                [videoFiles addObject:str];
            }
        }
        self.recordFilesArray = [NSMutableArray arrayWithArray:videoFiles];
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [weakSelf.table reloadData];
                   });
}


#pragma mark UITableViewDelegate&UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SEGMENTVIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_segmentView)
    {
        _segmentView = [[SegmentView alloc] initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, SEGMENTVIEW_HEIGHT)];
        [_segmentView setItemTitleWithArray:@[@"抓拍信息",@"录像信息"]];
        _segmentView.delegate = self;
    }
    return _segmentView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = (_segmentView.selectedIndex == 0 ? [self.screenshotFilesArray count] : [self.recordFilesArray count]);
    count = count/2 + count%2;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetWidth([tableView frame])/2 * 3 / 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ScreenshotCell";
    ScreenshotCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[ScreenshotCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(_segmentView.selectedIndex == 0)
    {
        //获取登录信息
        LoginResult *loginResult = [UDManager getLoginInfo];
        
        //获取图片名字
        NSInteger row = [indexPath row] * 2;
        NSString *name1 = self.screenshotFilesArray[row];
        NSString *name2 = [self.screenshotFilesArray count] > row + 1 ? self.screenshotFilesArray[row + 1] : nil;
        
        //获取图片地址
        NSString *filePath1 = [Utils getScreenshotFilePathWithName:name1 contactId:loginResult.contactId];
        if (!self.formatter)
        {
            _formatter = [[NSDateFormatter alloc] init];
            [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        NSArray *name1s = [name1 componentsSeparatedByString:@"_"];
        NSString *topStr1 = [name1s count] > 1 ? name1s[0] : @"";
        NSString *bottomStr1 = [name1s count] > 1 ? name1s[1] : name1s[0];
        bottomStr1 = [bottomStr1 stringByDeletingPathExtension];
        bottomStr1 = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[bottomStr1 doubleValue]]];
        UIImage *image1 = [UIImage imageWithContentsOfFile:filePath1];
        NSMutableArray *infos = [NSMutableArray array];
        if([filePath1 length])[infos addObject:@{@"image" : image1 ? image1 : @"",
                                                 @"top" : [topStr1 length] ? topStr1 : @"" ,
                                                 @"bottom" : [bottomStr1 length] ? bottomStr1 : @"",
                                                 @"filepath" : [filePath1 length] ? filePath1:@""}];
        
        if (name2)
        {
            NSString *filePath2 = [Utils getScreenshotFilePathWithName:name2 contactId:loginResult.contactId];
            NSArray *name2s = [name2 componentsSeparatedByString:@"_"];
            NSString *topStr2 = [name2s count] > 1 ? name2s[0] : @"";
            NSString *bottomStr2 = [name2s count] > 1 ? name2s[1] : name2s[0];
            bottomStr2 = [bottomStr2 stringByDeletingPathExtension];
            bottomStr2 = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[bottomStr2 doubleValue]]];
            UIImage *image2 = [UIImage imageWithContentsOfFile:filePath2];
            
            
            if([filePath2 length])[infos addObject:@{@"image" : image2 ? image2 : @"",
                                                     @"top" : [topStr2 length] ? topStr2 : @"",
                                                     @"bottom" : [bottomStr2 length] ? bottomStr2 : @"",
                                                     @"filepath" : [filePath2 length] ? filePath2:@""}];
        }
        
        [cell config:infos block:^(ScreenshotView *view, UIImage *image,NSInteger index)
        {
            CGRect rect = [[view superview] convertRect:[view frame] toView:nil];
            PhotoHandleView *handleView = [[PhotoHandleView alloc] initWithImage:image transFrom:rect target:self];
            [handleView show];
        }];
    }else
    {
        //获取登录信息
        LoginResult *loginResult = [UDManager getLoginInfo];
        
        //获取图片名字
        NSInteger row = [indexPath row] * 2;
        NSString *name1 = self.recordFilesArray[row];
        //获取图片地址
        NSString *filePath1 = _recordFilesArray[indexPath.row * 2];
        NSString *filePath2 = @"";
        if([_recordFilesArray count] > indexPath.row * 2 + 1)
            filePath2 = _recordFilesArray[indexPath.row* 2 +1];
        
        //获取录像文件数据
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *recordPath = [NSString stringWithFormat:@"%@/videorecord/%@",rootPath,loginResult.contactId];
        
        if ( !self.formatter)
        {
            _formatter = [[NSDateFormatter alloc] init];
            [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        
        
        filePath1 = [NSString stringWithFormat:@"%@/%@",recordPath,filePath1];
        NSArray *name1s = [name1 componentsSeparatedByString:@"_"];
        NSString *topStr1 = [name1s count] > 1 ? name1s[0] : @"";
        NSString *bottomStr1 = [name1s count] > 1 ? name1s[1] : name1s[0];
        bottomStr1 = [bottomStr1 stringByDeletingPathExtension];
        bottomStr1 = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[bottomStr1 doubleValue]]];
        UIImage *image1 = [UIImage imageWithContentsOfFile:filePath1];
        NSMutableArray *infos = [NSMutableArray array];
        if([filePath1 length])[infos addObject:@{@"image" : image1 ? image1 : @"",
                                                 @"top" : [topStr1 length] ? topStr1 : @"" ,
                                                 @"bottom" : [bottomStr1 length] ? bottomStr1 : @"",
                                                 @"filepath" : [filePath1 length] ? filePath1:@""}];
        
        NSString *name2 = [self.recordFilesArray count] > row + 1 ? self.recordFilesArray[row + 1] : nil;
        if (name2)
        {
            filePath2 = [NSString stringWithFormat:@"%@/%@",recordPath,filePath2];
            NSArray *name2s = [name2 componentsSeparatedByString:@"_"];
            NSString *topStr2 = [name2s count] > 1 ? name2s[0] : @"";
            NSString *bottomStr2 = [name2s count] > 1 ? name2s[1] : name2s[0];
            bottomStr2 = [bottomStr2 stringByDeletingPathExtension];
            bottomStr2 = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[bottomStr2 doubleValue]]];
            UIImage *image2 = [UIImage imageWithContentsOfFile:filePath2];
            
            if([filePath2 length])[infos addObject:@{@"image" : image2 ? image2 : @"",
                                                     @"top" : [topStr2 length] ? topStr2 : @"",
                                                     @"bottom" : [bottomStr2 length] ? bottomStr2 : @"",
                                                     @"filepath" : [filePath2 length] ? filePath2:@""}];
        }
        __weak typeof(self) weakSelf = self;
        [cell config:infos block:^(ScreenshotView *view, UIImage *image,NSInteger index)
         {
            //弹出播放视图
            NSString *videoPath = infos[index][@"filepath"];
            videoPath = [videoPath stringByReplacingOccurrencesOfString:@"png" withString:@"mp4"];

//            //加上这行代码，外放才有声音
            //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
             AVPlayerViewController *player = [[AVPlayerViewController alloc]init];
             player.url = [NSURL fileURLWithPath:videoPath];
             player.delegate = self;
             //  旋转
             AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
             appDelegate.isRotation = YES;
             [weakSelf presentViewController:player animated:YES completion:nil];
        }];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dismissViewController:(id)player
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.isRotation = NO;
    [player dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark SegementDelegate
- (void)segmentView:(SegmentView *)segmentView  selectedItemAtIndex:(int)index
{
    [self initData];
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
