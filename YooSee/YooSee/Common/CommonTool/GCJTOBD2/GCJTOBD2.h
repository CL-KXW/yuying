//
//  GCJTOBD2.h
//  iAppPay
//
//  Created by sam on 15/12/28.
//  Copyright © 2015年 iPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCJTOBD2 : NSObject

+(double)bd_encryptLon:(double)gg_lat gglon:(double)gg_lon;
+(double)bd_encryptLat:(double)gg_lat gglon:(double)gg_lon;


//百度转高德
+(double)bd_decryptLon:(double) bd_lat gglon:(double)bd_lon;


+(double)bd_decryptLat:(double) bd_lat gglon:(double)bd_lon;

@end
