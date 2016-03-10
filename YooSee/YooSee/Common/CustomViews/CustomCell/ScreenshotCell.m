//
//  YCScreenshotCell.m
//  OspreyIAD
//
//  Created by cellcom on 15/4/9.
//  Copyright (c) 2015年 Suycity. All rights reserved.
//

#import "ScreenshotCell.h"

@interface ScreenshotCell ()
@property (nonatomic, strong) NSArray *infos;
@property (nonatomic, copy) void(^didClickBlock)(ScreenshotView *,UIImage *,NSInteger);
@property (nonatomic, assign) CGPoint delete_pt_tap;//删除文件时，手指按下的坐标
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation ScreenshotCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1)
    {
        NSLog(@"%@",@"will delete file!");
        NSDictionary *dic;
        if ([_infos count] == 1)
        {
            dic = _infos[0];
        }
        else
        {
           dic = _infos[_delete_pt_tap.x > self.frame.size.width/2 ? 1 : 0];
        }
        NSString *filepath = dic[@"filepath"];
        NSLog(@"删除文件的路径：%@",filepath);
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL result = [fm removeItemAtPath:filepath error:nil];
        NSLog(@"result===%d",result);
        [SVProgressHUD showSuccessWithStatus:@"删除成功!"];

        //视频cell还要删除对应的视频文件
        if(_isVideoCell)
        {
            filepath = [filepath stringByReplacingOccurrencesOfString:@"png" withString:@"mp4"];
            [fm removeItemAtPath:filepath error:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshFiles" object:nil];

    }

}

//长按cell删除对应的文件
 - (void)deleteFileLongPress:(UILongPressGestureRecognizer*)recognizer
{
     
     if(recognizer.state == UIGestureRecognizerStateEnded)
         return;
     
     if(recognizer.state == UIGestureRecognizerStateBegan)
     {
         _delete_pt_tap = [recognizer locationInView:self];;
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
         [alert show];
         [alert release];
     }
 }

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //添加长按手势
    if (!_longPressGesture)
    {
        _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(deleteFileLongPress:)];
        //self.gestureRecognizers
        [self addGestureRecognizer:_longPressGesture];
    }
    
    CGFloat height = CGRectGetHeight([self frame]);
    CGFloat width = CGRectGetWidth([self frame]);
    if (!self.screenshotView1)
    {
        _screenshotView1 = [[ScreenshotView alloc] initWithFrame:(CGRect){
            0,0,width/2,height
        }];
        [self addSubview:self.screenshotView1];
    }
    if (!self.screenshotView2)
    {
        _screenshotView2 = [[ScreenshotView alloc] initWithFrame:(CGRect){
            width/2,0,width/2,height
        }];
        [self addSubview:self.screenshotView2];
    }
    
    if ([self.infos count] == 1)
    {
        [self.screenshotView1 setHidden:NO];
        [self.screenshotView2 setHidden:YES];
        
        NSDictionary *dict = self.infos[0];
        [_screenshotView1 config:dict[@"image"] top:dict[@"top"] bottom:dict[@"bottom"] clickBlock:^(UIImage *image) {
            if (self.didClickBlock) {
                self.didClickBlock(self.screenshotView1,image,0);
            }
        }];
    }
    else if ([self.infos count] == 2)
    {
        [self.screenshotView1 setHidden:NO];
        [self.screenshotView2 setHidden:NO];
        NSDictionary *dict = self.infos[0];
        [_screenshotView1 config:dict[@"image"] top:dict[@"top"] bottom:dict[@"bottom"] clickBlock:^(UIImage *image) {
            if (self.didClickBlock) {
                self.didClickBlock(self.screenshotView1,image,0);
            }
        }];
        dict = self.infos[1];
        UIImage *image = dict[@"image"];
        if ([image isKindOfClass:[UIImage class]]) {
            [self.screenshotView2 config:image top:dict[@"top"] bottom:dict[@"bottom"] clickBlock:^(UIImage *image) {
                if (self.didClickBlock) {
                    self.didClickBlock(self.screenshotView2,image,1);
                }
            }];
        }
    }
}

- (void)config:(NSArray *)infos block:(void(^)(ScreenshotView *,UIImage *,NSInteger))block
{
    [self setInfos:infos];
    _didClickBlock = Block_copy(block);
}

- (void)dealloc
{
    SycRelease(_longPressGesture);
    Block_release(_didClickBlock);
    SycRelease(_screenshotView1);
    SycRelease(_screenshotView2);
    SycRelease(_infos);
    SycSuperDealloc;
}
@end
