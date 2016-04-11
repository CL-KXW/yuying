//
//  ResponseSellerMessage.h
//  YooSee
//
//  Created by 周后云 on 16/3/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ZHYBaseResponse.h"

@interface ResponseSellerMessage : ZHYBaseResponse

@property(nonatomic,strong)NSArray *resultList;

@end

@interface SellerMessage: NSObject

@property(nonatomic,strong)NSNumber *turnover_money;
@property(nonatomic,strong)NSString *area_name;
@property(nonatomic,strong)NSString *address;
@property(nonatomic,strong)NSString *contact_phone;
@property(nonatomic,strong)NSNumber *capital_money;
@property(nonatomic,strong)NSString *dian_logo;
@property(nonatomic,strong)NSString *dian_name;
//@property(nonatomic,strong)NSNumber *jigndu;
@property(nonatomic,strong)NSString *province_name;
@property(nonatomic,strong)NSNumber *weidu;
@property(nonatomic,strong)NSString *city_name;
//@property(nonatomic,strong)NSNumber *hangye_id;
@property(nonatomic,strong)NSNumber *freeze_money;
@property(nonatomic,strong)NSString *dian_content;
@property(nonatomic,strong)NSString *hangye_name;
@property(nonatomic,strong)NSNumber *id;  //商家id

@end
