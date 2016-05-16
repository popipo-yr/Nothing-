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
    PYNetStartRequestWithRequestInfo *startInfo = [self _createReqInfoWithPath:path
                                                                    parameters:parameters
                                                                  successBlock:successBlock
                                                                  failureBlock:failureBlock];
    startInfo.isMultipartBody = YES;

    [self _oprBeforeAllStartWithInfo:startInfo];
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

    [self _oprAfterRequestCreate:req withInfo:startInfo];
    if (startInfo.needStop) return nil;

    return [self _startJsonRequest:req successBlock:successBlock failureBlock:failureBlock netFailBlock:netFailBlock];
}


- (NSURLSessionTask *)postTo:(NSString *)path
                  parameters:(NSDictionary *)parameters
                successBlock:(void (^)(NSDictionary *res))successBlock
                failureBlock:(void (^)(NSDictionary *res))failureBlock
                netFailBlock:(void (^)(NSError *error))netFailBlock
{
    PYNetStartRequestWithRequestInfo *startInfo = [self _createReqInfoWithPath:path
                                                                    parameters:parameters
                                                                  successBlock:successBlock
                                                                  failureBlock:failureBlock];

    [self _oprBeforeAllStartWithInfo:startInfo];
    if (startInfo.needStop) return nil;

    NSMutableURLRequest *request = [[_realClient requestSerializer] requestWithMethod:@"POST"
                                                                            URLString:path
                                                                           parameters:parameters
                                                                                error:nil];

    [self _oprAfterRequestCreate:request withInfo:startInfo];
    if (startInfo.needStop) return nil;

    return [self _startJsonRequest:request successBlock:successBlock failureBlock:failureBlock netFailBlock:netFailBlock];
}


///下载
- (NSURLSessionTask *)downloadFileWithPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                   success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSError *error))failure
{
    PYNetStartRequestWithRequestInfo *startInfo = [self _createReqInfoWithPath:path
                                                                    parameters:parameters
                                                                  successBlock:success
                                                                  failureBlock:nil];

    [self _oprBeforeAllStartWithInfo:startInfo];
    if (startInfo.needStop) return nil;

    NSMutableURLRequest *request = [[_realClient requestSerializer] requestWithMethod:@"GET"
                                                                            URLString:path
                                                                           parameters:parameters
                                                                                error:nil];

    [self _oprAfterRequestCreate:request withInfo:startInfo];
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


- (PYNetStartRequestWithRequestInfo *)_createReqInfoWithPath:(NSString *)path
                                                  parameters:(NSDictionary *)parameters
                                                successBlock:(void (^)(NSDictionary *res))successBlock
                                                failureBlock:(void (^)(NSDictionary *res))failureBlock
{
    PYNetStartRequestWithRequestInfo *reqInfo = [PYNetStartRequestWithRequestInfo new];
    reqInfo.successBlock = successBlock;
    reqInfo.failureBlock = failureBlock;
    reqInfo.param        = parameters;
    reqInfo.path         = path;

    return reqInfo;
}


///进行需要的处理在一切开始,并创建RequestInfo
- (void)_oprBeforeAllStartWithInfo:(PYNetStartRequestWithRequestInfo *)info
{
    for (id<PYNetStartRequestPro> opr in _inOprs) {
        if ([opr respondsToSelector:@selector(oprBeforeRequestCreateWithInfo:)]) {
            [opr oprBeforeRequestCreateWithInfo:info];
        }
    }
}


///进行需要的处理在request创建后
- (void)_oprAfterRequestCreate:(NSMutableURLRequest *)req
                      withInfo:(PYNetStartRequestWithRequestInfo *)info
{
    info.request = req;
    info.header  = req.allHTTPHeaderFields;

    for (id<PYNetStartRequestPro> opr in _inOprs) {
        if ([opr respondsToSelector:@selector(oprAfterRequestCreateWithInfo:)]) {
            [opr oprAfterRequestCreateWithInfo:info];
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


@end


@implementation RRNetFile

@end