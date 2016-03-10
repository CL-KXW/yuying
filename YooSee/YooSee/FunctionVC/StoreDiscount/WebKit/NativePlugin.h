//
//  NativePlugin.h
//  osprey
//
//  Created by  apple on 15/12/22.
//  Copyright © 2015年 杨氏宅淘阁科技公司. All rights reserved.
//
//定义一个JSExport protocol

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSExportNative <JSExport>

- (void)loadingStatusStart;
- (void)loadingStatusClose;
- (void)setTitle:(NSString*)title;
- (void)setType:(NSString*)type;
- (NSString*)getUserInfo;

@end

//协议-改变viewcontroller的title
@protocol WebviewDelegate <NSObject>
@optional
- (void) changeTitle:(NSString*)title;
- (void) changeType:(NSString*)type;
@end

//建一个对象去实现这个协议：

@interface NativePlugin : NSObject<JSExportNative>
{
    UIViewController *_viewController;
}

@property(nonatomic,assign) id <WebviewDelegate> delegate;

@end
