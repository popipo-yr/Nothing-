//
//  RRNetClient.h
//
//  Created by yr on 15/12/24.
//  Copyright © 2015年 yr. All rights reserved.
//

#import "RRNetClientOpr.h"

#import "PYNetRequestProtocol.h"


@class RRNetFile;

@interface RRNetClient : NSObject

/*处理添加,删除*/
- (void)addInOpr:(id<PYNetStartRequestPro>)inOpr;
- (void)removeInOpr:(id<PYNetStartRequestPro>)inOpr;

- (void)addOutOpr:(id<PYNetFinishRequestPro>)outOpr;
- (void)removeOutOpr:(id<PYNetFinishRequestPro>)outOpr;

/*设置默认header*/
- (void)setDefaultHeader:(NSString *)header value:(NSString *)value;

/**
 *  post方式请求服务器数据
 *
 *  @param path                 请求的服务器api
 *  @param parameters           参数
 *  @param successBlock         http返回200状态时执行,server执行成功
 *  @param failureBlock         http返回200状态时执行,server执行失败
 *  @param netFailBlock         http返回非200状态时执行
 */
- (NSURLSessionTask *)postTo:(NSString *)path
                  parameters:(NSDictionary *)parameters
                successBlock:(void (^)(NSDictionary *res))successBlock
                failureBlock:(void (^)(NSDictionary *res))failureBlock
                netFailBlock:(void (^)(NSError *error))netFailBlock;

/**
 *  post方式提交文件到服务器
 *
 *  @param path                 请求的服务器api
 *  @param parameters           附加参数
 *  @param fileEntities         要提交到服务器的文件
 */
- (NSURLSessionTask*)postFileTo:(NSString *)path
        parameters:(NSDictionary *)parameters
      fileEntities:(NSArray<RRNetFile *> *)fileEntities
      successBlock:(void (^)(NSDictionary *res))successBlock
      failureBlock:(void (^)(NSDictionary *res))failureBlock
      netFailBlock:(void (^)(NSError *error))netFailBlock;


/**
 *  get方式下载文件
 */
- (NSURLSessionTask*)downloadFileWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                     success:(void (^)(id responseObject))success
                     failure:(void (^)(NSError *error))failure;


/**
 *  创建实例
 */
- (id)initWithBaseURL:(NSURL *)url;


@end


/**
 * 网络文件
 */
@interface RRNetFile : NSObject

@property (nonatomic, strong) NSString *name;      //接收name
@property (nonatomic, strong) NSString *fileName;  //文件名
@property (nonatomic, strong) NSString *type;      //文件类型
@property (nonatomic, strong) NSData   *data;      //文件数据

@end
