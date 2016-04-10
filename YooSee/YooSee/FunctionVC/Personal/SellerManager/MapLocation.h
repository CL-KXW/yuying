//
//  MapLocation.h
//  YooSee
//
//  Created by 周后云 on 16/4/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface MapLocation : NSObject<MKAnnotation>

@property (nonatomic ,readwrite) CLLocationCoordinate2D coordinate ;

@end
