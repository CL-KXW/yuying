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
@end
//领取资格
@implementation Y1YDetail2ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:1 tableDelegate:self];
    self.table.separatorStyle = 0;
    [[self table] reloadData];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55)];
    [self.table setTableHeaderView:headView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 20)];
    titleLabel.text = self.nameString;
    [headView addSubview:titleLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 150, 20)];
    timeLabel.text = self.timeString;
    timeLabel.font = FONT(11);
    [headView addSubview:timeLabel];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, 150, 20)];
    authorLabel.text = self.authorString;
    authorLabel.font = FONT(11);
    authorLabel.textColor = [UIColor blueColor];
    [headView addSubview:authorLabel];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    [self.table setTableFooterView:footView];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-130)/2, 10, 130, 40)];
    [button addTarget:self action:@selector(buttonActino) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"领取资格" forState:UIControlStateNormal];

    [button setBackgroundImage:[UIImage imageNamed:@"HBGXQANTP.png"] forState:UIControlStateNormal];
    [footView addSubview:button];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_WIDTH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 20)];
    label.numberOfLines = 0;
    label.text = self.descArray[section];
    label.font = FONT(14);
    [label sizeToFit];
    return label.frame.size.height + 20;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self tableView:tableView heightForFooterInSection:section])];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 20)];
    label.numberOfLines = 0;
    label.text = self.descArray[section];
    label.font = FONT(14);
    [label sizeToFit];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pic = [self.dataArray objectAtIndex:indexPath.section];
    NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:cellID];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.tag = 100;
    }
    UIImageView *imgView = (UIImageView*)[cell.contentView viewWithTag:100];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:101];
    if (self.hasMakedRob) {
        btn.hidden = YES;
    } else {
        btn.hidden = NO;
    }
    [imgView setImageWithURL:[NSURL URLWithString:pic] placeholderImage:nil];
    
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
             [self.table reloadData];
             [SVProgressHUD showSuccessWithStatus:errorMessage duration:2.5];
         }
         else
         {
             self.hasMakedRob = NO;
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%d", error.code] duration:2.5];
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
