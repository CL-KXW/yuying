//
//  YAudioStreamPlayer.h
//  Yoosee
//
//  Created by guojunyi on 14-7-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAudioStreamPlayer : NSObject
@property (nonatomic) BOOL isPlay;
+ (id)sharedDefault;
-(BOOL)start;
-(void)stop;
-(void)playCmd:(NSInteger)cmd;
-(void)playWIFI:(NSString*)ssid wifiPassword:(NSString*)wifiPassword devicePassword:(NSString*)devicePassword;
@end
