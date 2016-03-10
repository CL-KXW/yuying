//
//  SycPhotoHandleView.h
//  TrafficStatusCQ
//
//  Created by cellcom on 14-4-30.
//  Copyright (c) 2014年 Suycity. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoHandleView : UIView<UIScrollViewDelegate,UIActionSheetDelegate>

@property (nonatomic , retain) UIImage *image;
@property (nonatomic , assign) CGRect fromRect;

- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from;

- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from target:(id)target;

- (void)show;

@end
