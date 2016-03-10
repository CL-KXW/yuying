//
//  QrCodeBaseViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y             START_HEIGHT + 80.0 * CURRENT_SCALE
#define SCNNING_WIDTH       240.0 * CURRENT_SCALE
#define SCNNING_HEIGHT      250.0 * CURRENT_SCALE
#define TIP_LABEL_HEIGHT    30.0
#define ADD_Y               80.0 * CURRENT_SCALE

#import "QrCodeBaseViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QrCodeBaseViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrDown;
    NSTimer * timer;
}
@property (strong, nonatomic)AVCaptureDevice * device;
@property (strong, nonatomic)AVCaptureDeviceInput * input;
@property (strong, nonatomic)AVCaptureMetadataOutput * output;
@property (strong, nonatomic)AVCaptureSession * session;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, strong) UIImageView *lineImageView;


@end


@implementation QrCodeBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackItem];
    self.view.backgroundColor = RGBA(0.0, 0.0, 0.0, 1.0);
    
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_session stopRunning];
    [timer invalidate];
}

#pragma mark 初始化UI
- (void)initUI
{
    
    start_y = SPACE_Y;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self setupCamera];
    }
    
    UIImage *pickBgImage = [UIImage imageNamed:@"pick_bg"];
    //float pickBgImageWidth = pickBgImage.size.width/3;
    //float pickBgImageHeight = pickBgImage.size.height/3;
    UIImageView * interImageView = [CreateViewTool createImageViewWithFrame:CGRectMake((self.view.frame.size.width - SCNNING_WIDTH)/2, start_y, SCNNING_WIDTH, SCNNING_HEIGHT) placeholderImage:pickBgImage];
    [self.view addSubview:interImageView];
    
    UIImage *lineImage = [UIImage imageNamed:@"line"];
    float lineImageWidth = lineImage.size.width/2;
    float lineImageHeight = lineImage.size.height/2;
    float lineSpace_x = (interImageView.frame.size.width - lineImageWidth)/2;
    _lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(lineSpace_x, 0, SCNNING_WIDTH - 2 * lineSpace_x, lineImageHeight) placeholderImage:[UIImage imageNamed:@"line"]];
    [interImageView addSubview:_lineImageView];
    
    start_y += interImageView.frame.size.height + ADD_Y;
    
    UILabel * tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, start_y, self.view.frame.size.width, TIP_LABEL_HEIGHT) textString:self.tipString ? self.tipString : @"" textColor:[UIColor lightGrayColor] textFont:FONT(14.0)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
}



#pragma mark 初始化SCANNING
- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = CGRectMake((self.view.frame.size.width - SCNNING_WIDTH)/2, start_y, SCNNING_WIDTH, SCNNING_HEIGHT);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    // Start
    [_session startRunning];
}


#pragma mark 动画定时器
-(void)createTimer
{
    if ([timer isValid])
    {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
}

//动画
-(void)lineAnimation
{
    CGRect frame = _lineImageView.frame;
    if (upOrDown == NO)
    {
        num++;
        
        if (2 * num >= SCNNING_HEIGHT)
        {
            upOrDown = YES;
        }
    }
    else
    {
        num --;
        if (2 * num <= 0)
        {
            upOrDown = NO;
        }
    }
    _lineImageView.frame = CGRectMake(frame.origin.x, 2 * num, frame.size.width, frame.size.height);
    
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    [timer invalidate];
    NSLog(@"%@",stringValue);
    [CommonTool addAlertTipWithMessage:stringValue];
    
    [self getQrcodeSucess:stringValue];
}

#pragma mark 获取成功
- (void)getQrcodeSucess:(NSString *)qrCodeString
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_session stopRunning];
    [timer invalidate];
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
