//
//  GCJTOBD2.m
//  iAppPay
//
//  Created by sam on 15/12/28.
//  Copyright © 2015年 iPay. All rights reserved.
//

#import "GCJTOBD2.h"
const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;

@implementation GCJTOBD2

+(double)bd_encryptLon:(double)gg_lat gglon:(double)gg_lon
{
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    return z * cos(theta) + 0.0065;
}


+(double)bd_encryptLat:(double)gg_lat gglon:(double)gg_lon
{
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    return z * sin(theta) + 0.006;
}

+(double)bd_decryptLon:(double) bd_lat gglon:(double)bd_lon
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    return z * cos(theta);
}

+(double)bd_decryptLat:(double) bd_lat gglon:(double)bd_lon
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    return  z * sin(theta);
}
@end
