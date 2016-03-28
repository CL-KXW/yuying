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
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:0 tableDelegate:self];
    self.table.separatorStyle = 0;
    [[self table] reloadData];
    if (self.dataArray.count == 0) {
        [self.dataArray addObject:@"1"];
    }
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_HEIGHT - 64;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pic = [self.dataArray objectAtIndex:indexPath.row];
    NSString *cellID = @"cellID";
    if (indexPath.row == self.dataArray.count - 1) {
        cellID = @"lastCellID";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:cellID];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        [cell.contentView addSubview:imageView];
        imageView.tag = 100;
        if ([cellID isEqualToString:@"lastCellID"]) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-130)/2, SCREEN_HEIGHT - 60 - 64,130, 40)];
            [button addTarget:self action:@selector(buttonActino) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"领取资格" forState:UIControlStateNormal];
            [cell.contentView addSubview:button];
            [button setBackgroundImage:[UIImage imageNamed:@"HBGXQANTP.png"] forState:UIControlStateNormal];
            button.tag = 101;
        }
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
    [[RequestTool alloc] getRequestWithUrl:MAKE_ROB
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
