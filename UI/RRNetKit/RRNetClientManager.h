//
//  RRNetClientCreator.h
//  rrkd
//
//  Created by rrkd on 15/12/24.
//  Copyright © 2015年 创物科技. All rights reserved.
//

#import "RRNetClient.h"

@interface RRNetClientManager : NSObject

+ (RRNetClient*)client;

+ (void)clearAuthHeader;
+ (void)appendAuthHeader;

@end
