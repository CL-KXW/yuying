//
//  RedLibaryQRcodeViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/16.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RedLibaryQRcodeViewController.h"

@interface RedLibaryQRcodeViewController ()

@property(nonatomic,weak)IBOutlet UIButton *shareButton;
@property(nonatomic,weak)IBOutlet UIImageView *qrCodeImageView;
@property(nonatomic,weak)IBOutlet UIImageView *logoImageView;
@property(nonatomic,strong)NSString *totalString;
@property(nonatomic,strong)UIImage *image;

@end

@implementation RedLibaryQRcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = @"红包二维码";
    [self.shareButton viewRadius:20 backgroundColor:ButtonColor_Green];
    [self makeQRcode];
}

#pragma mark -
-(IBAction)shareButtonClick:(id)sender
{
    [self showShareView];
}

#pragma mark -
-(void)makeQRcode
{
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    NSString *string = @"http://www.dianliang.yuying/app?type=";
    NSString *temp;
    if (self.type == QRcodeType_advertisement) {
        temp = [NSString stringWithFormat:@"gg&id=%@",self.dic[@"id"]];
    }else if (self.type == QRcodeType_redLibary){
        if([self.dic[@"hongbao_type"] intValue] == 1){
            temp = [NSString stringWithFormat:@"hb-js&id=%@",self.dic[@"id"]];
        }else if ([self.dic[@"hongbao_type"] intValue] == 2){
            //扫码
            temp = [NSString stringWithFormat:@"hb-sm&id=%@",self.dic[@"id"]];
        }else if ([self.dic[@"hongbao_type"] intValue] == 3){
            //摇一摇
            temp = [NSString stringWithFormat:@"yyy&id=%@",self.dic[@"id"]];
        }
    }
    self.totalString = [string stringByAppendingString:temp];
    NSData *data=[self.totalString dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    self.qrCodeImageView.image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:140.0];
    self.image = self.qrCodeImageView.image;
    //如果还想加上阴影，就在ImageView的Layer上使用下面代码添加阴影
    self.qrCodeImageView.layer.shadowOffset=CGSizeMake(0, 0.5);//设置阴影的偏移量
    self.qrCodeImageView.layer.shadowRadius=1;//设置阴影的半径
    self.qrCodeImageView.layer.shadowColor=[UIColor blackColor].CGColor;//设置阴影的颜色为黑色
    self.qrCodeImageView.layer.shadowOpacity=0.3;
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

#pragma mark -
- (void)showShareView
{
    NSString *url = @"http://yyw.dianliangtech.com/dianliang/qr_code/share?qr_text=";
    NSString *shareUrl = [NSString stringWithFormat:@"%@%@",url,self.totalString];
    NSString *text = @"欢迎加入鱼鹰，看广告赚话费金币，免费兑换商品，照顾家车安全,红包二维码";
    
    NSString *shareText = [NSString stringWithFormat:@"%@",text];
    
    UIImage *shareImage = self.qrCodeImageView.image;
    [self share:shareImage url:shareUrl text:shareText];
}

-(void)share:(UIImage *)image url:(NSString *)url text:(NSString *)text{
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeWeb url:url];
    [UMSocialData defaultData].shareImage = image;
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UM_APP_KEY
                                      shareText:text
                                     shareImage:image
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToQzone,UMShareToEmail,UMShareToSms,nil]
                                       delegate:nil];
    
    NSString *shareTitle = @"鱼鹰";
    [UMSocialData defaultData].extConfig.wechatSessionData.title = shareTitle;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
    
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = shareTitle;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
    
    [UMSocialData defaultData].extConfig.qqData.title = shareTitle;
    [UMSocialData defaultData].extConfig.qqData.url = url;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.urlResource.resourceType = UMSocialUrlResourceTypeWeb;
    [UMSocialData defaultData].extConfig.qqData.urlResource.url = url;
    
    [UMSocialData defaultData].extConfig.qzoneData.title = shareTitle;
    [UMSocialData defaultData].extConfig.qzoneData.url = url;
    [UMSocialData defaultData].extConfig.qzoneData.urlResource.resourceType = UMSocialUrlResourceTypeWeb;
    
    //微信收藏
    [UMSocialData defaultData].extConfig.wechatFavoriteData.title = shareTitle;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.url = url;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.urlResource.resourceType = UMSocialUrlResourceTypeWeb;
    
    //新浪微博
    [UMSocialData defaultData].extConfig.sinaData.shareText = text;
    [UMSocialData defaultData].extConfig.sinaData.urlResource.url = url;
    [UMSocialData defaultData].extConfig.sinaData.urlResource.resourceType = UMSocialUrlResourceTypeWeb;
}

@end
