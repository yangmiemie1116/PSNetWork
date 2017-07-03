//
//  PSNetWork.h
//  PSNetWork
//
//  Created by sheep on 2017/6/21.
//  Copyright © 2017年 sheep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential * _Nonnull __autoreleasing * _Nonnull credential);

@interface PSNetWork : NSObject
/**
 创建网络请求单例
 @return PSNetWork
 */
+ (instancetype _Nonnull )shareInstance;

@property (readwrite, nonatomic, copy) AFURLSessionDidReceiveAuthenticationChallengeBlock _Nonnull sessionDidReceiveAuthenticationChallenge;
/**
 超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/**
 是否为HTTPS请求
 */
@property (nonatomic, assign) BOOL isHttps;

/**
 网络请求结束，标识成功或者失败的字段
 */
@property (nonatomic, copy) NSString * _Nullable result;

/**
 网络请求返回message关键字
 */
@property (nonatomic, copy) NSString * _Nullable message;

/**
 写入全局的请求地址

 @param baseUrlString baseUrlString
 */
- (void)registerBaseUrl:(NSString*_Nonnull)baseUrlString;

/**
 GET 请求
 @param params 参数
 @return GET Signal
 */
- (RACSignal*_Nonnull)mic_GET:(NSDictionary*_Nonnull)params;

/**
 HEAD 请求
 @param params 参数
 @return HEAD Signal
 */
- (RACSignal*_Nonnull)mic_HEAD:(NSDictionary*_Nonnull)params;

/**
 POST 请求
 @param params 参数
 @return POST Signal
 */
- (RACSignal*_Nonnull)mic_POST:(NSDictionary*_Nonnull)params;

/**
 PATCH 请求
 @param params 参数
 @return PATCH Signal
 */
- (RACSignal*_Nonnull)mic_PATCH:(NSDictionary*_Nonnull)params;

/**
 PUT 请求
 @param params 参数
 @return PUT Signal
 */
- (RACSignal*_Nonnull)mic_PUT:(NSDictionary*_Nonnull)params;

/**
 DELETE 请求
 @param params 参数
 @return DELETE Signal
 */
- (RACSignal*_Nonnull)mic_DELETE:(NSDictionary*_Nonnull)params;


/**
 上传数据
 @param params params
 @param data data
 @param mimeType mimeType
 @param progressBlock progressBlock
 @return RACSignal
 */
- (RACSignal*_Nonnull)mic_upload:(NSDictionary * _Nonnull )params
                data:(id _Nullable )data
              mimeType:(nullable NSString*)mimeType
              progress:(void(^_Nullable)(NSProgress * _Nullable progress))progressBlock;

@end
