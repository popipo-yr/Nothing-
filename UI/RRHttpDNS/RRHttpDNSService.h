//
//  RRHttpDNSService.h
//  rrkd
//
//  Created by rrkd on 16/5/6.
//  Copyright © 2016年 创物科技. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _C_QueryDomain    @"interface.rrkd.cn"

@interface RRHttpDNSService : NSObject


+ (void) start;
+ (void) stop;

+ (NSString*)curIP; //获取 _C_QueryDomain 对应的ip

@end
