//
//  UncaughtExceptionHandler.h
//  Yoosee
//
//  Created by guojunyi on 14-8-2.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}

@end
void HandleException(NSException *exception);
void SignalHandler(int signal);


void InstallUncaughtExceptionHandler(void);
