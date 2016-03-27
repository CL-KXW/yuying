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

@end

@implementation RedLibaryQRcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"红包二维码";
    [self.shareButton viewRadius:20 backgroundColor:ButtonColor_Green];
    [self makeQRcode];
}

-(IBAction)shareButtonClick:(id)sender
{
    
}

-(void)makeQRcode
{
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    
    NSData *data=[@"www.baidu.com" dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    self.qrCodeImageView.image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:140.0];
    
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

@end
