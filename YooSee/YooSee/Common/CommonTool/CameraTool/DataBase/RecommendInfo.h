//
//  RecommendInfo.h
//  Yoosee
//
//  Created by gwelltime on 15-1-19.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendInfo : NSObject

@property (nonatomic) NSInteger messageID;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *contentString;
@property (strong, nonatomic) NSString *imageURLString;
@property (strong, nonatomic) NSString *imageLinkURLString;
@property (strong, nonatomic) NSString *timeString;

@property (nonatomic,assign) BOOL isRead;

@end
