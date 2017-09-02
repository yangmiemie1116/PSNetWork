//
//  PSNetWork.h
//  PSNetWork
//
//  Created by sheep on 2017/6/21.
//  Copyright © 2017年 sheep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
@protocol PSNetConfig;
typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential * _Nonnull __autoreleasing * _Nonnull credential);

@interface PSNetWork : NSObject
/**
 创建网络请求单例
 @return PSNetWork
 */
+ (instancetype _Nonnull )shareInstance;
@property (nonatomic, strong) id<PSNetConfig> _Nullable config;
@property (nonatomic, assign) BOOL isPartHttps;//某个请求是https
@property (nonatomic, assign) BOOL isGlobalHttps;//全局都是HTTPS
@property (readwrite, nonatomic, copy) AFURLSessionDidReceiveAuthenticationChallengeBlock _Nonnull sessionDidReceiveAuthenticationChallenge;

/**
 GET 请求
 @param params 参数
 @return GET Signal
 */
- (RACSignal*_Nonnull)mic_GET:(NSDictionary*_Nonnull)params;
//path 自定义请求路径
- (RACSignal*_Nonnull)mic_GET:(NSDictionary*_Nonnull)params path:(NSString*_Nullable)path;

/**
 HEAD 请求
 @param params 参数
 @return HEAD Signal
 */
- (RACSignal*_Nonnull)mic_HEAD:(NSDictionary*_Nonnull)params;
//path 自定义请求路径
- (RACSignal*_Nonnull)mic_HEAD:(NSDictionary*_Nonnull)params path:(NSString*_Nullable)path;

/**
 POST 请求
 @param params 参数
 @return POST Signal
 */
- (RACSignal*_Nonnull)mic_POST:(NSDictionary*_Nonnull)params;
//path 自定义请求路径
- (RACSignal*_Nonnull)mic_POST:(NSDictionary*_Nonnull)params path:(NSString*_Nullable)path;
/**
 PATCH 请求
 @param params 参数
 @return PATCH Signal
 */
- (RACSignal*_Nonnull)mic_PATCH:(NSDictionary*_Nonnull)params;
//path 自定义请求路径
- (RACSignal*_Nonnull)mic_PATCH:(NSDictionary*_Nonnull)params path:(NSString*_Nullable)path;
/**
 PUT 请求
 @param params 参数
 @return PUT Signal
 */
- (RACSignal*_Nonnull)mic_PUT:(NSDictionary*_Nonnull)params;
//path 自定义请求路径
- (RACSignal*_Nonnull)mic_PUT:(NSDictionary*_Nonnull)params path:(NSString*_Nullable)path;

/**
 DELETE 请求
 @param params 参数
 @return DELETE Signal
 */
- (RACSignal*_Nonnull)mic_DELETE:(NSDictionary*_Nonnull)params;
//path 自定义请求路径
- (RACSignal*_Nonnull)mic_DELETE:(NSDictionary*_Nonnull)params path:(NSString*_Nullable)path;

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
- (RACSignal*_Nonnull)mic_upload:(NSDictionary * _Nonnull )params
                            data:(id _Nullable )data
                        mimeType:(nullable NSString*)mimeType
                            path:(NSString*_Nullable)path
                        progress:(void(^_Nullable)(NSProgress * _Nullable progress))progressBlock;

@end
