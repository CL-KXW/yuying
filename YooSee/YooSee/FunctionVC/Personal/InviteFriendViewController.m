//
//  InviteFriendViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y             30.0 * CURRENT_SCALE
#define SPACE_X             25.0 * CURRENT_SCALE
#define LABEL_WIDTH         280.0 * CURRENT_SCALE
#define LABEL_HEIGHT        30.0 * CURRENT_SCALE
#define ADD_Y               20.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2
#define QRCODE_WH           200 * CURRENT_SCALE

#import "InviteFriendViewController.h"
#import "UMSocial.h"

@interface InviteFriendViewController ()

@property(nonatomic,strong)UIImageView *imageview;

@end

@implementation InviteFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"邀请好友";
    [self addBackItem];
    
    [self initUI];
    // Do any additional setup after loading the view.
    [self makeQRcode];
}

#pragma mark 初始化UI
- (void)initUI
{
    start_y = SPACE_Y + START_HEIGHT;
    NSString *text = @"        邀请朋友使用鱼鹰，朋友注册的时候，输入您的手机号码，双方都能获得1000亮币的话费。不输入邀请人电话号码也可以注册。";
    UILabel *tiplabel = [CreateViewTool createLabelWithFrame:CGRectMake((self.view.frame.size.width - LABEL_WIDTH)/2, start_y, LABEL_WIDTH, LABEL_HEIGHT) textString:text textColor:MAIN_TEXT_COLOR textFont:FONT(17.0)];
    CGFloat height = [CommonTool labelHeightWithTextLabel:tiplabel textFont:tiplabel.font];
    CGRect frame = tiplabel.frame;
    frame.size.height = height;
    tiplabel.frame = frame;
    tiplabel.hidden = YES;
    [self.view addSubview:tiplabel];
    
    //start_y += height + 2 * ADD_Y;
    start_y += height;

    self.imageview = [CreateViewTool createImageViewWithFrame:CGRectMake((self.view.frame.size.width - QRCODE_WH)/2, start_y, QRCODE_WH, QRCODE_WH) placeholderImage:nil];
    [self.view addSubview:self.imageview];
    
    start_y += self.imageview.frame.size.height + ADD_Y;
    UILabel *tiplabel2 = [CreateViewTool createLabelWithFrame:CGRectMake(0, start_y, self.view.frame.size.width, LABEL_HEIGHT) textString:@"扫描二维码，邀请好友安装鱼鹰APP" textColor:MAIN_TEXT_COLOR textFont:FONT(17.0)];
    tiplabel2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tiplabel2];
    
    start_y += tiplabel2.frame.size.height + 3 * ADD_Y;
    UIButton *inviteButton = [CreateViewTool createButtonWithFrame:CGRectMake(SPACE_X, start_y, self.view.frame.size.width - 2 * SPACE_X, BUTTON_HEIGHT) buttonTitle:@"分享" titleColor:[UIColor grayColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:nil selectorName:@"inviteButtonPressed:" tagDelegate:self];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CommonTool clipView:inviteButton withCornerRadius:BUTTON_RADIUS];
    [CommonTool setViewLayer:inviteButton withLayerColor:[UIColor grayColor] bordWidth:1.0];
    [self.view addSubview:inviteButton];
}

#pragma mark 邀请好友
- (void)inviteButtonPressed:(UIButton *)sender
{
    NSString *shareText = SHARE_TEXT;
    UIImage *shareImage = [UIImage imageNamed:@"big_icon"];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UM_APP_KEY
                                      shareText:shareText
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToQzone,UMShareToEmail,UMShareToSms,nil]
                                       delegate:nil];
}


#pragma mark -
-(void)makeQRcode
{
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    NSString *string = @"http://www.dianliangtech.com";
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    self.imageview.image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:140.0];
}

//改变二维码大小
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}


@end
