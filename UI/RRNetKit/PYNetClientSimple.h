//
//  PYNetClientSimple.h
//  test
//
//  Created by rrkd on 16/5/16.
//  Copyright © 2016年 yr. All rights reserved.
//

#import "RRNetClient.h"


/**
 *  上传文件,简化方法
 */
@interface RRNetClient (PostFileSimple)


/// imageInfos  {@"name", UIImage; @"name2", UIImage; ...}
/// quality  压缩质量
- (void)postJpegImageTo:(NSString *)path
             parameters:(NSDictionary *)parameters
             ImageInfos:(NSDictionary *)imageInfos
                quality:(float)compressionQuality
           successBlock:(void (^)(NSDictionary *res))successBlock
           failureBlock:(void (^)(NSDictionary *res))failureBlock
           netFailBlock:(void (^)(NSError *error))netFailBlock;

/// imageInfos  {@"name", UIImage; @"name2", UIImage; ...}
- (void)postPngImageTo:(NSString *)path
            parameters:(NSDictionary *)parameters
            ImageInfos:(NSDictionary *)imageInfos
          successBlock:(void (^)(NSDictionary *res))successBlock
          failureBlock:(void (^)(NSDictionary *res))failureBlock
          netFailBlock:(void (^)(NSError *error))netFailBlock;

/// amrInfos {@"name", NSData; @"name2", NSData; ...}
- (void)postAmrsTo:(NSString *)path
        parameters:(NSDictionary *)parameters
          AmrInfos:(NSDictionary *)amrInfos
      successBlock:(void (^)(NSDictionary *res))successBlock
      failureBlock:(void (^)(NSDictionary *res))failureBlock
      netFailBlock:(void (^)(NSError *error))netFailBlock;

@end
