//
//  Y1YDetailViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "Y1YDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Y1YDetail2ViewController.h"

#define WIDTH   SCREEN_WIDTH
#define HEIGHT  SCREEN_HEIGHT
@interface Y1YDetailViewController ()
{
    UIImageView  *imageV;
    AVAudioPlayer *audioPlayer;
}
@end

@implementation Y1YDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackItem];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"welcom_yhb.mp3" ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:NULL];
    [audioPlayer play];
    
    imageV= [[UIImageView alloc]initWithFrame:CGRectMake(0, START_HEIGHT ,WIDTH, HEIGHT)];
    imageV.animationImages = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"y1y_bg_1.jpg"],
                              [UIImage imageNamed:@"y1y_bg_2.jpg"],
                              [UIImage imageNamed:@"y1y_bg_3.jpg"],
                              nil];
    [imageV setAnimationDuration:0.5f];
    [imageV setAnimationRepeatCount:0];
    [imageV startAnimating];
    imageV.userInteractionEnabled = YES;
    [self.view addSubview:imageV];
    
    UIImageView  *imageV1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, WIDTH,WIDTH*0.73333 )];
    NSURL *url = [NSURL URLWithString:self.dataDic[@"largepic"]];
    [imageV1 setImageWithURL:url placeholderImage:nil];
    [imageV addSubview:imageV1];
    
    UIImageView  *imageV2 = [[UIImageView alloc]initWithFrame:CGRectMake(0+5, imageV1.frame.size.height-10, WIDTH,WIDTH*1.005)];
    imageV2.image = [UIImage imageNamed:@"y1y_hb.png"];
    [imageV addSubview:imageV2];
    [imageV insertSubview:imageV2 belowSubview:imageV1];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((WIDTH-130)/2, imageV2.frame.size.height*0.4+imageV1.frame.size.height,130, 40)];
    [button addTarget:self action:@selector(buttonActino) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"感兴趣" forState:UIControlStateNormal];
    [imageV addSubview:button];
    [button setBackgroundImage:[UIImage imageNamed:@"HBGXQANTP.png"] forState:UIControlStateNormal];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, imageV2.frame.size.height*0.55+5, WIDTH - 100, 20)];
    label.text =[NSString stringWithFormat:@"%@  准时抢",self.dataDic[@"begintime"]]; //@"2015年9月10日  15:30 准时抢!";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.font = FONT(14);
    
    [imageV2 addSubview:label];
}

- (void)buttonActino{
    NSLog(@"点击了感兴趣");
    Y1YDetail2ViewController *detail2  = [[Y1YDetail2ViewController alloc]init];
    detail2.ggid = self.dataDic[@"ggid"];
    [self.navigationController pushViewController:detail2 animated:NO];
}


@end
