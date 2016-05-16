//
//  RRHttpDNSService.m
//  rrkd
//
//  Created by rrkd on 16/5/6.
//  Copyright © 2016年 创物科技. All rights reserved.
//

#import "RRHttpDNSService.h"
#import "QNDnspodEnterprise.h"
#import "QNResolverDelegate.h"
#import "QNDomain.h"
#import "QNRecord.h"
#import "QNHosts.h"
#import "QNNetworkInfo.h"
#import "Reachability.h"



#define _C_ResolverID  @"151"
#define _C_ResolverKey @"EaZ[tb,T"

#define _C_UROfExpiredTime  0.7  //有效时间使用率


@implementation RRHttpDNSService {
    __block QNHosts *_hosts;
    __block NSDate  *_expiredTime;

    QNDomain      *_domain;
    QNNetworkInfo *_info;

    dispatch_semaphore_t _semaphore;
    NSOperationQueue     *_oprQueue;
}




- (instancetype)init
{
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(1);
        _oprQueue  = [NSOperationQueue new];

        [self clean];
        
        [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(netChanged)
                                                      name:kReachabilityChangedNotification object:nil];
    }

    return self;
}

-(void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)clean
{
    _hosts  = [QNHosts new];
    _domain = [[QNDomain alloc] init:_C_QueryDomain];
    _info   = [QNNetworkInfo normal];
}


- (void)getIpsWithDelay:(NSNumber *)delayNumber
{
    [self performSelector:@selector(getIps) withObject:nil afterDelay:[delayNumber intValue]];
}


- (void)getIps
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];

    [_oprQueue cancelAllOperations];

    NSBlockOperation *opr = [NSBlockOperation new];

    __weak typeof(opr) opr_weak_   = opr;
    __weak typeof(self) self_weak_ = self;

    [opr addExecutionBlock:^{
         id <QNResolverDelegate> resolver = [[QNDnspodEnterprise alloc] initWithId:_C_ResolverID key:_C_ResolverKey];
         NSArray *records = [resolver query:_domain networkInfo:nil error:nil];

         dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);

         if ([opr_weak_ isCancelled]) {
             dispatch_semaphore_signal(_semaphore);
             return;
         }

         int ttl = 0;
         _hosts = [QNHosts new];// ONLY FOR CLEAR
         for (QNRecord *aRecord in records) {
             [_hosts put:_domain.domain ip:aRecord.value provider:_info.provider];
             _expiredTime = [[NSDate new] dateByAddingTimeInterval:aRecord.ttl];
             ttl = aRecord.ttl;

             break;
         }

         dispatch_semaphore_signal(_semaphore);

         [self_weak_ performSelectorOnMainThread:@selector(getIpsWithDelay:)
                                      withObject:[NSNumber numberWithInt:ttl * _C_UROfExpiredTime]
                                   waitUntilDone:YES];
     }];

    [_oprQueue addOperation:opr];
}


- (void)start
{
    [self getIps];
}


- (void)stop
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [_oprQueue cancelAllOperations];
}


- (NSString *)curIP
{
    if (_expiredTime == nil || [[NSDate new] compare:_expiredTime] == NSOrderedDescending) {
        return nil;
    }

    NSString *ip = nil;

    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);

    ip = [_hosts query:_domain networkInfo:_info].firstObject;

    dispatch_semaphore_signal(_semaphore);

    return ip;
}


- (void)netChanged{

    _expiredTime = nil;
    [self getIps];
}


+ (RRHttpDNSService *)defaultDNS
{
    static RRHttpDNSService *_s_HttpDNS;

    static dispatch_once_t once_pred;

    dispatch_once(&once_pred, ^{
        _s_HttpDNS = [RRHttpDNSService new];
    });

    return _s_HttpDNS;
}


+ (void)start
{
    [[self defaultDNS] start];
}


+ (void)stop
{
    [[self defaultDNS] stop];
}


+ (NSString *)curIP
{
    return [[self defaultDNS] curIP];
}


@end