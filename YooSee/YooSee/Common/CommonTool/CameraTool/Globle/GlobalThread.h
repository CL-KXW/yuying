//
//  GlobalThread.h
//  Yoosee
//
//  Created by guojunyi on 14-4-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalThread : NSObject

@property (nonatomic) BOOL isRun;
@property (nonatomic) BOOL isPause;
+(id)sharedThread:(BOOL)isRelease;
-(void)kill;
-(void)start;
@end
