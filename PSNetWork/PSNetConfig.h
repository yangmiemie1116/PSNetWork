//
//  PSNetConfig.h
//  PSNetWork
//
//  Created by sheep on 2017/9/2.
//  Copyright © 2017年 sheep. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSNetConfig <NSObject>
@required
/**
 请求的 baseUrl
 */
- (NSString*)baseUrlString;
@optional
/**
 请求的 https 请求的baseUrl
 */
- (NSString*)httpsUrlString;
/**
 请求成功后返回的信息字段, 默认 “message”
 */
- (NSString*)message;
/**
 请求成功后返回的状态字段，默认 “result”
 */
- (NSString*)result;
/**
 请求成功状态码 NSInteger 类型 默认 1
 */
- (NSInteger)successCode;
/**
 请求成功状态码 NSString 类型 默认 “00”
 */
- (NSString*)successCodeString;
/**
 超时时间 默认60s
 */
- (NSTimeInterval)timeout;
/**
 请求 head
 */
- (NSMutableDictionary*)headerDictionary;

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
/**
 请求公用字段
 */
- (NSMutableDictionary*)commonRequestParameters;
/**
 请求头是否要为json 默认 NO
 */
- (BOOL)isJsonHeader;
@end
