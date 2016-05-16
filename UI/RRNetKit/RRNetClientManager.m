//
//  RRNetClientCreator.m
//  rrkd
//
//  Created by rrkd on 15/12/24.
//  Copyright © 2015年 创物科技. All rights reserved.
//

#import "RRNetClientManager.h"
#import "Reachability.h"
#import "RRAppInfo.h"
#import "RRUser.h"
#import "RRUtils.h"

@implementation RRNetClientManager

+ (RRNetClient *)client
{
    static RRNetClient *client = nil;
    static BOOL        isNoticeNetWork = NO;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable && !isNoticeNetWork) {
        isNoticeNetWork = YES;
        [UITrayView showTray:@"无法连接到网络，请检查您的网络设置" animated:YES];
    }
    
    if (client == nil) {
      
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", KAppServer]];
        client = [[RRNetClient alloc] initWithBaseURL:url];
        if ([RRUser isLogin]) {
            [self appendAuthHeaderAboutClient:client];
        }
        
        //添加过滤处理
        [client addInOpr:[RRNetClientInOpr new]];
        [client addOutOpr:[RRNetClientOutOpr new]];
    }
    
    [client setDefaultHeader:@"UDID" value:[RRUtils getUID]];

    return client;
}


//用户注销登录 清除掉http header内容
+ (void)clearAuthHeader
{
    [self clearAuthHeaderAboutClient:[self client]];
}


+ (void)appendAuthHeader
{
    [self appendAuthHeaderAboutClient:[self client]];
}


//用户注销登录 清除掉http header内容
+ (void)clearAuthHeaderAboutClient:(RRNetClient*)client
{
    [client setDefaultHeader:@"USERNAME" value:nil];
    [client setDefaultHeader:@"TOKEN"    value:nil];
    [client setDefaultHeader:@"type"     value:nil];
}


+ (void)appendAuthHeaderAboutClient:(RRNetClient*)client
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [client setDefaultHeader:@"USERNAME" value:[user objectForKey:kRRUser]];
    [client setDefaultHeader:@"TOKEN" value:[user objectForKey:kRRToken]];
    [client setDefaultHeader:@"type" value:@"ios"];
}

@end
