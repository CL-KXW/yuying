//
//  CameraManager.h
//  Yoosee
//
//  Created by guojunyi on 14-4-18.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) NSInteger frameRate;
@property (nonatomic) BOOL isRun;
@property (nonatomic) BOOL isFinishCaptureOutput;
+ (id)sharedManager;

- (void)addCameraView:(UIView *)view;
- (int)cameraChange;
-(void)startCamera:(BOOL)isFont;
-(void)stopCamera;

@end
