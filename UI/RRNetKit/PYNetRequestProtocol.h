//
//  PYNetRequestProtocol.h
//
//  Created by yr on 16/5/11.
//  Copyright © 2016年 yr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PYNetStartRequestInfo;
@class PYNetFinishRequestInfo;
@class PYNetStartRequestWithRequestInfo;


/**
 *  开始网络请求前,需要执行操作的协议
 */
@protocol  PYNetStartRequestPro  <NSObject>

///所有开始前的处理
- (void)oprBeforeAllStartWithInfo:(PYNetStartRequestInfo *)info;

///单部件请求时,在创建request后的处理
- (void)oprAfterSinglepartFormRequesCreateWithInfo:(PYNetStartRequestWithRequestInfo *)info;

///多部件请求时,在创建request前的处理
- (void)oprBeforeMultipartFormRequestCreateWithInfo:(PYNetStartRequestInfo *)info;


@end



/**
 *  网络请求结束,需要执行chu的协议
 */
@protocol  PYNetFinishRequestPro  <NSObject>

- (void)oprAfterFinishWithInfo:(PYNetFinishRequestInfo *)info;

@end


/**
 * 开始网络请求信息
 */
@interface PYNetStartRequestInfo : NSObject

@property (nonatomic, strong) NSDictionary *header;  //请求header
@property (nonatomic, strong) NSDictionary *param;   //请求参数
@property (nonatomic, strong) NSString     *path;    //请求路径

@property (nonatomic, copy)   void (^successBlock)(NSDictionary *res); //请求成功回调
@property (nonatomic, copy)   void (^failureBlock)(NSDictionary *res); //请求失败回调

@property (nonatomic, assign) BOOL needStop; //当具体一个操作,修改为true的时候,将停止处理和请求
@property (nonatomic, assign) BOOL isMultipartBody; //是否为多部件请求体

@end


/**
 * 开始网络请求信息, 包含NSURLRequest
 */
@interface PYNetStartRequestWithRequestInfo : PYNetStartRequestInfo

@property (nonatomic, strong) NSMutableURLRequest *request;


@end


/**
 * 结束网络请求信息
 */
@interface PYNetFinishRequestInfo : NSObject

@property (nonatomic, strong) id       responseObject; //请求返回数据
@property (nonatomic, assign) BOOL     needStop;      //当具体一个操作,修改为true的时候,将停止处理和请求
@property (nonatomic, strong) NSString *stopReason;    //停止处理的原因

@end