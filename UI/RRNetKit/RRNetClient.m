//
//  RRNetClient.m
//
//  Created by yr on 15/12/24.
//  Copyright © 2015年 yr. All rights reserved.
//

#import "RRNetClient.h"
#import <AFNetworking/AFNetworking.h>
#import "RRHttpDNSService.h"

#define _M_SafeCall(block, param) if (nil != block) {block(param); }

@implementation RRNetClient {
    AFHTTPSessionManager *_realClient;

    NSMutableArray<id<PYNetStartRequestPro> >  *_inOprs;
    NSMutableArray<id<PYNetFinishRequestPro> > *_outOprs;
}

#pragma mark - Outer

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super init]) {
        _inOprs     = [NSMutableArray array];
        _outOprs    = [NSMutableArray array];
        _realClient = [[AFHTTPSessionManager alloc] initWithBaseURL:url];

        NSSet *types = _realClient.responseSerializer.acceptableContentTypes;
        types = [types setByAddingObject:@"text/html"];
        types = [types setByAddingObject:@"application/octet-stream"];

        _realClient.responseSerializer.acceptableContentTypes = types;

        _realClient.responseSerializer = [AFCompoundResponseSerializer serializer];
        _realClient.requestSerializer  = [AFJSONRequestSerializer serializer];
    }

    return self;
}


- (void)addInOpr:(id<PYNetStartRequestPro>)inOpr
{
    [_inOprs addObject:inOpr];
}


- (void)addOutOpr:(id<PYNetFinishRequestPro>)outOpr
{
    [_outOprs addObject:outOpr];
}


- (void)removeInOpr:(id<PYNetStartRequestPro>)inOpr
{
    [_inOprs removeObject:inOpr];
}


- (void)removeOutOpr:(id<PYNetFinishRequestPro>)outOpr
{
    [_outOprs removeObject:outOpr];
}


- (void)setDefaultHeader:(NSString *)header value:(NSString *)value
{
    [_realClient.requestSerializer setValue:value forHTTPHeaderField:header];
}


//////////////////////////

- (NSURLSessionTask *)postFileTo:(NSString *)path
                      parameters:(NSDictionary *)parameters
                    fileEntities:(NSArray<RRNetFile *> *)fileEntities
                    successBlock:(void (^)(NSDictionary *res))successBlock
                    failureBlock:(void (^)(NSDictionary *res))failureBlock
                    netFailBlock:(void (^)(NSError *error))netFailBlock
{
    PYNetStartRequestWithRequestInfo *startInfo = nil;

    startInfo = [self _oprBeforeAllStartWithPath:path
                                      parameters:parameters
                                    successBlock:successBlock
                                    failureBlock:failureBlock];

    if (startInfo.needStop) return nil;

    [self _oprBeforeMultipartFormRequestCreateWithInfo:startInfo];

    if (startInfo.needStop) return nil;

    void (^constructingBodyWithBlock)(id <AFMultipartFormData>) = ^(id <AFMultipartFormData> formData) {
        for (RRNetFile *aFile in fileEntities) {
            [formData appendPartWithFileData:aFile.data
                                        name:aFile.name
                                    fileName:aFile.fileName
                                    mimeType:aFile.type];
        }
    };

    NSMutableURLRequest *req = [[_realClient requestSerializer] multipartFormRequestWithMethod:@"POST"
                                                                                     URLString:path
                                                                                    parameters:startInfo.param
                                                                     constructingBodyWithBlock:constructingBodyWithBlock
                                                                                         error:nil];

    [self _appendHears:startInfo.header aboutRequest:req];
    return [self _startJsonRequest:req successBlock:successBlock failureBlock:failureBlock netFailBlock:netFailBlock];
}


- (NSURLSessionTask *)postTo:(NSString *)path
                  parameters:(NSDictionary *)parameters
                successBlock:(void (^)(NSDictionary *res))successBlock
                failureBlock:(void (^)(NSDictionary *res))failureBlock
                netFailBlock:(void (^)(NSError *error))netFailBlock
{
    PYNetStartRequestWithRequestInfo *startInfo = nil;

    startInfo = [self _oprBeforeAllStartWithPath:path
                                      parameters:parameters
                                    successBlock:successBlock
                                    failureBlock:failureBlock];

    if (startInfo.needStop) return nil;

    NSMutableURLRequest *request = [[_realClient requestSerializer] requestWithMethod:@"POST"
                                                                            URLString:path
                                                                           parameters:parameters
                                                                                error:nil];

    [self _oprAfterSinglepartFormRequesCreate:request withInfo:startInfo];

    if (startInfo.needStop) return nil;

    return [self _startJsonRequest:request successBlock:successBlock failureBlock:failureBlock netFailBlock:netFailBlock];
}


///下载
- (NSURLSessionTask *)downloadFileWithPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                   success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSError *error))failure
{
    PYNetStartRequestWithRequestInfo *startInfo = nil;

    startInfo = [self _oprBeforeAllStartWithPath:path
                                      parameters:parameters
                                    successBlock:success
                                    failureBlock:nil];

    if (startInfo.needStop) return nil;

    NSMutableURLRequest *request = [[_realClient requestSerializer] requestWithMethod:@"GET"
                                                                            URLString:path
                                                                           parameters:parameters
                                                                                error:nil];

    [self _oprAfterSinglepartFormRequesCreate:request withInfo:startInfo];

    if (startInfo.needStop) return nil;

    return [self _createAndStartTaskWithRequest:request
                                netSuccessBlock:success
                                   netFailBlock:failure];
}


#pragma mark - Private

///开始json数据的请求
- (NSURLSessionTask *)_startJsonRequest:(NSMutableURLRequest *)request
                           successBlock:(void (^)(NSDictionary *res))successBlock
                           failureBlock:(void (^)(NSDictionary *res))failureBlock
                           netFailBlock:(void (^)(NSError *error))netFailBlock
{
    void (^httpSuccessBlock)(id) = ^(id responseObject) {
        PYNetFinishRequestInfo *finishInfo = nil;

        finishInfo = [self _oprAfterFinishWithResponser:responseObject];

        if (finishInfo.needStop == YES) {
            _M_SafeCall(netFailBlock, [NSError errorWithDomain:finishInfo.stopReason code:0 userInfo:nil]);
            return;
        }

        NSDictionary *serverData = responseObject;

        if ([responseObject isKindOfClass:[NSData class]]) {
            serverData = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        }

        if (![serverData isKindOfClass:[NSDictionary class]]) {
            serverData = @{};
        }

        if ([[NSString stringWithFormat:@"%@", serverData[@"success"]] isEqualToString:@"true"]) {
            _M_SafeCall(successBlock, serverData);
        } else {
            _M_SafeCall(failureBlock, serverData);
        }
    };

    return [self _createAndStartTaskWithRequest:request
                                netSuccessBlock:httpSuccessBlock
                                   netFailBlock:netFailBlock];
}


///创建task,并运行
- (NSURLSessionDataTask *)_createAndStartTaskWithRequest:(NSURLRequest *)request
                                         netSuccessBlock:(void (^)(id responseObject))netSuccessBlock
                                            netFailBlock:(void (^)(NSError *error))netFailBlock
{
    NSURLSessionDataTask *task;
    task = [_realClient dataTaskWithRequest:request
                          completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error == nil) {
                    _M_SafeCall(netSuccessBlock, responseObject);
                } else {
                    _M_SafeCall(netFailBlock, error);
                }
            }];

    [task resume];

    return task;
}


///进行需要的处理在一切开始,并创建RequestInfo
- (PYNetStartRequestWithRequestInfo *)_oprBeforeAllStartWithPath:(NSString *)path
                                                      parameters:(NSDictionary *)parameters
                                                    successBlock:(void (^)(NSDictionary *res))successBlock
                                                    failureBlock:(void (^)(NSDictionary *res))failureBlock
{
    PYNetStartRequestWithRequestInfo *startInfo = [PYNetStartRequestWithRequestInfo new];
    startInfo.successBlock = successBlock;
    startInfo.failureBlock = failureBlock;
    startInfo.param        = parameters;
    startInfo.path         = path;

    for (id<PYNetStartRequestPro> opr in _inOprs) {
        if ([opr respondsToSelector:@selector(oprBeforeAllStartWithInfo:)]) {
            [opr oprBeforeAllStartWithInfo:startInfo];
        }
    }

    return startInfo;
}


///进行需要的处理在多部件request创建前
- (void)_oprBeforeMultipartFormRequestCreateWithInfo:(PYNetStartRequestWithRequestInfo *)info
{
    for (id<PYNetStartRequestPro> opr in _inOprs) {
        if ([opr respondsToSelector:@selector(oprBeforeMultipartFormRequestCreateWithInfo:)]) {
            [opr oprBeforeMultipartFormRequestCreateWithInfo:info];
        }
    }
}


///进行需要的处理在单部件request创建后
- (void)_oprAfterSinglepartFormRequesCreate:(NSMutableURLRequest *)req
                                   withInfo:(PYNetStartRequestWithRequestInfo *)info
{
    info.request = req;
    info.header  = req.allHTTPHeaderFields;

    for (id<PYNetStartRequestPro> opr in _inOprs) {
        if ([opr respondsToSelector:@selector(oprAfterSinglepartFormRequesCreateWithInfo:)]) {
            [opr oprAfterSinglepartFormRequesCreateWithInfo:info];
        }
    }

    req.allHTTPHeaderFields = info.header;
}


///进行需要的处理在http请求完成
- (PYNetFinishRequestInfo *)_oprAfterFinishWithResponser:(id)responseObject
{
    PYNetFinishRequestInfo *finishInfo = [PYNetFinishRequestInfo new];
    finishInfo.responseObject = responseObject;

    for (id<PYNetFinishRequestPro> opr in _outOprs) {
        if ([opr respondsToSelector:@selector(oprAfterFinishWithInfo:)]) {
            [opr oprAfterFinishWithInfo:finishInfo];
        }
    }

    return finishInfo;
}


//
- (void)_appendHears:(NSDictionary *)appendHeader aboutRequest:(NSMutableURLRequest *)req
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:req.allHTTPHeaderFields];

    [info setValuesForKeysWithDictionary:appendHeader];

    req.allHTTPHeaderFields = info;
}


@end


@implementation RRNetFile

@end