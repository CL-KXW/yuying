//
//  Y1YDetail2ViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "Y1YDetail2ViewController.h"
@interface Y1YDetail2ViewController ()
@property (nonatomic, assign) BOOL hasMakedRob;
@property (nonatomic, strong) NSMutableArray *heightArray;
@end
//领取资格
@implementation Y1YDetail2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addTableViewWithFrame:CGRectMake(0, START_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - START_HEIGHT) tableType:1 tableDelegate:self];
    self.table.separatorStyle = 0;
    [[self table] reloadData];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    [self.table setTableHeaderView:headView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, SCREEN_WIDTH - 20, 70)];
    titleLabel.numberOfLines = 1;
    titleLabel.font = FONT(28);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.textColor = RGB(74, 74, 74);
    titleLabel.text = self.nameString;
    [headView addSubview:titleLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 70, 20)];
    timeLabel.text = [CommonTool dateString2MDString:self.timeString];
    timeLabel.font = FONT(15);
    timeLabel.textColor = RGB(185, 185, 185);
    [headView addSubview:timeLabel];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 100, 150, 20)];
    authorLabel.text = self.authorString;
    authorLabel.font = FONT(15);
    authorLabel.textColor = RGB(155, 179, 204);
    [headView addSubview:authorLabel];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
    [self.table setTableFooterView:footView];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(35, 10, SCREEN_WIDTH - 70, 50)];
    [button addTarget:self action:@selector(buttonActino) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"领取资格" forState:UIControlStateNormal];

    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:RGB(86, 192, 245)];
    button.layer.cornerRadius = 25;
    [button setShowsTouchWhenHighlighted:YES];
    [footView addSubview:button];
    
    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, SCREEN_WIDTH - 20, 20)];
    startTimeLabel.textColor = RGB(102, 102, 102);
    startTimeLabel.font = FONT(12);
    startTimeLabel.text = [NSString stringWithFormat:@"%@ 准时开抢",[CommonTool dateString2MDHMString:self.startTimeString]];
    startTimeLabel.textAlignment = NSTextAlignmentCenter;
    [footView addSubview:startTimeLabel];
    
    _heightArray = [NSMutableArray arrayWithArray:@[@(220 * CURRENT_SCALE),@(220 * CURRENT_SCALE),@(220 * CURRENT_SCALE)]];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_heightArray[indexPath.section] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 20)];
    label.numberOfLines = 0;
    label.text = self.descArray[section];
    label.font = FONT(14);
    [label sizeToFit];
    return label.frame.size.height + 20;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self tableView:tableView heightForFooterInSection:section])];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 20)];
    label.numberOfLines = 0;
    label.text = self.descArray[section];
    label.font = FONT(14);
    label.textColor = RGB(74, 74, 74);
    [label sizeToFit];
    [view addSubview:label];
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pic = [self.dataArray objectAtIndex:indexPath.section];
    NSString *cellID = @"cellID";
    float space_x = 10.0;
    float width = SCREEN_WIDTH - space_x * 2;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:cellID];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(space_x, 0, width, 220 * CURRENT_SCALE)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        imageView.clipsToBounds = YES;
        imageView.tag = 100;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = 0;
    }
    UIImageView *imgView = (UIImageView*)[cell.contentView viewWithTag:100];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:101];
    if (self.hasMakedRob) {
        btn.hidden = YES;
    } else {
        btn.hidden = NO;
    }
    UIImage *defaultImage = [UIImage imageNamed:@"default_image2"];
    [imgView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:defaultImage options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize)
    {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        if (defaultImage != image)
        {
            CGRect frame = imgView.frame;
            float height = width/image.size.width * image.size.height;
            frame.size.height = height;
            imgView.frame = frame;
            imgView.image = image;
            if (height != [_heightArray[indexPath.section] floatValue])
            {
                [_heightArray replaceObjectAtIndex:indexPath.section withObject:@(height)];
                [self.table reloadData];
            }
            
        }
    }];
    

    
    return cell;
}

- (void)buttonActino {
    NSLog(@"领取资格");
    if (!self.ggid) {
        return;
    }
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"user_id":[NSString stringWithFormat:@"%@", uid],
                                 @"only_number":[NSString stringWithFormat:@"%@",self.ggid]};
    [[RequestTool alloc] requestWithUrl:MAKE_ROB
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_Y1Y_LIST===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             self.hasMakedRob = YES;
             //[self.table reloadData];
             [SVProgressHUD showSuccessWithStatus:errorMessage];
//             [self.navigationController popViewControllerAnimated:NO];
         }
         else
         {
             self.hasMakedRob = NO;
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%d", error.code]];
     }];

}

//- (void)getPicRequest {
//    if (!self.ggid) {
//        return;
//    }
//    NSDictionary *requestDic = @{@"ggid":self.ggid};
//    [[RequestTool alloc] getRequestWithUrl:GET_Y1Y_PIC
//                            requestParamas:requestDic
//                               requestType:RequestTypeAsynchronous
//                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
//     {
//         NSLog(@"GET_Y1Y_LIST===%@",responseDic);
//         NSDictionary *dataDic = (NSDictionary *)responseDic;
//         int errorCode = [dataDic[@"returnCode"] intValue];
//         NSString *errorMessage = dataDic[@"returnMessage"];
//         errorMessage = errorMessage ? errorMessage : @"";
//         [LoadingView dismissLoadingView];
//         if (errorCode == 1)
//         {
//             @synchronized(_dataArray) {
//                 if (_currentPage == 1) {
//                     [_dataArray removeAllObjects];
//                 }
//                 NSArray *ary = dataDic[@"body"];
//                 if (ary) {
//                     [_dataArray addObjectsFromArray:ary];
//                 }
//                 [self.table reloadData];
//             }
//         }
//         else
//         {
//             [SVProgressHUD showErrorWithStatus:errorMessage];
//         }
//     }
//                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         
//     }];
//
//}
@end
