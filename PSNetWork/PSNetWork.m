//
//  PSNetWork.m
//  PSNetWork
//
//  Created by sheep on 2017/6/21.
//  Copyright © 2017年 sheep. All rights reserved.
//

#import "PSNetWork.h"
#import <AFNetworking/AFNetworking.h>
#import "PSNetConfig.h"
#define defaultTimeout 60

@interface PSNetWork()
@property (nonatomic, strong) AFHTTPSessionManager *safeManager;
@property (nonatomic, strong) AFHTTPSessionManager *normalManager;
@end

@implementation PSNetWork
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static PSNetWork *util = nil;
    dispatch_once(&onceToken, ^{
        util = [[self alloc] init];
    });
    return util;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_createSessionManager];
    }
    return self;
}

#pragma mark - GET
- (RACSignal*)mic_GET:(NSDictionary*)params {
    return [self mic_GET:params path:nil];
}

- (RACSignal*)mic_GET:(NSDictionary *)params path:(NSString *)path {
    return [[self rac_request:params method:@"GET" path:path] setNameWithFormat:@"%@ -rac_GET, parameters: %@",self.class, params];
}

#pragma mark - HEAD
- (RACSignal*)mic_HEAD:(NSDictionary*)params {
    return [self mic_HEAD:params path:nil];
}

- (RACSignal*)mic_HEAD:(NSDictionary *)params path:(NSString *)path {
    return [[self rac_request:params method:@"HEAD" path:path] setNameWithFormat:@"%@ -rac_HEAD, parameters: %@",self.class, params];
}

#pragma mark - POST
- (RACSignal*)mic_POST:(NSDictionary*)params {
    return [self mic_POST:params path:nil];
}

- (RACSignal*)mic_POST:(NSDictionary *)params path:(NSString *)path {
    return [[self rac_request:params method:@"POST" path:path] setNameWithFormat:@"%@ -rac_POST, parameters: %@",self.class, params];
}

#pragma mark - PATCH
- (RACSignal*)mic_PATCH:(NSDictionary*)params {
    return [self mic_PATCH:params path:nil];
}

- (RACSignal*)mic_PATCH:(NSDictionary *)params path:(NSString *)path {
    return [[self rac_request:params method:@"PATCH" path:path] setNameWithFormat:@"%@ -rac_PATCH, parameters: %@",self.class, params];
}

#pragma mark - PUT
- (RACSignal*)mic_PUT:(NSDictionary*)params {
    return [self mic_PUT:params path:nil];
}

- (RACSignal*)mic_PUT:(NSDictionary *)params path:(NSString *)path {
    return [[self rac_request:params method:@"PUT" path:path] setNameWithFormat:@"%@ -rac_PUT, parameters: %@",self.class, params];
}

#pragma mark - DELETE
- (RACSignal*)mic_DELETE:(NSDictionary*)params {
    return [self mic_DELETE:params path:nil];
}

- (RACSignal*)mic_DELETE:(NSDictionary *)params path:(NSString *)path {
    return [[self rac_request:params method:@"DELETE" path:path] setNameWithFormat:@"%@ -rac_DELETE, parameters: %@",self.class, params];
}

- (RACSignal*)rac_request:(NSDictionary*)parameters method:(NSString*)method path:(NSString*)path {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSTimeInterval timeout = defaultTimeout;
        if (respondSel(self.config, @selector(timeout))) {
            timeout = [self.config timeout];
        }
        NSDictionary *commonParameters = nil;
        NSString *baseUrlStr = nil;
        if (respondSel(self.config, @selector(commonRequestParameters))) {
            commonParameters = [self.config commonRequestParameters];
        }
        AFHTTPSessionManager *manager = self.normalManager;
        manager.requestSerializer.timeoutInterval = timeout;
        if (self.isGlobalHttps) {
            if (respondSel(self.config, @selector(httpsUrlString))) {
                baseUrlStr = [self.config httpsUrlString];
            }
            manager = self.safeManager;
        } else if (self.isPartHttps){
            if (respondSel(self.config, @selector(httpsUrlString))) {
                baseUrlStr = [self.config httpsUrlString];
            }
            manager = self.safeManager;
            self.isPartHttps = NO;
        } else {
            if (respondSel(self.config, @selector(baseUrlString))) {
                baseUrlStr = [self.config baseUrlString];
            }
        }
        if (respondSel(self.config, @selector(headerDictionary))) {
            [self.config.headerDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
        NSString *httpStr = [self join:baseUrlStr path:path parameters:commonParameters];
        NSURLRequest *request = [manager.requestSerializer requestWithMethod:method URLString:httpStr parameters:parameters error:nil];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self processResponse:subscriber error:error responseObject:responseObject];
        }];
        [dataTask resume];
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

#pragma mark - 上传数据
- (RACSignal*)mic_upload:(NSDictionary *)params data:(id)data mimeType:(NSString *)mimeType progress:(void (^)(NSProgress * _Nullable))progressBlock {
    return [self mic_upload:params data:data mimeType:mimeType path:nil progress:progressBlock];
}
- (RACSignal*)mic_upload:(NSDictionary*)parameters
                data:(id)data
              mimeType:(NSString *)mimeType
                    path:(NSString*)path
              progress:(void(^)(NSProgress *progress))progressBlock {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSDictionary *commonParameters = nil;
        NSString *baseUrlStr = nil;
        NSTimeInterval timeout = defaultTimeout;
        if (respondSel(self.config, @selector(timeout))) {
            timeout = [self.config timeout];
        }
        if (respondSel(self.config, @selector(commonRequestParameters))) {
            commonParameters = [self.config commonRequestParameters];
        }
        AFHTTPSessionManager *manager = self.normalManager;
        manager.requestSerializer.timeoutInterval = timeout;
        if (self.isGlobalHttps) {
            if (respondSel(self.config, @selector(httpsUrlString))) {
                baseUrlStr = [self.config httpsUrlString];
            }
            manager = self.safeManager;
        } else if (self.isPartHttps){
            if (respondSel(self.config, @selector(httpsUrlString))) {
                baseUrlStr = [self.config httpsUrlString];
            }
            manager = self.safeManager;
            self.isPartHttps = NO;
        } else {
            if (respondSel(self.config, @selector(baseUrlString))) {
                baseUrlStr = [self.config baseUrlString];
            }
        }
        if (respondSel(self.config, @selector(headerDictionary))) {
            [self.config.headerDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
        NSString *httpStr = [self join:baseUrlStr path:path parameters:commonParameters];
        NSMutableURLRequest *request = nil;
        NSError *formError = nil;
        NSURLSessionUploadTask *dataTask = nil;
        if ([data isKindOfClass:[NSArray class]]) {
            request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:httpStr parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                [(NSArray*)data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[UIImage class]]) {
                        NSData *imageData = UIImageJPEGRepresentation(obj, 0.5);
                        [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"image%@",@(idx)] fileName:[NSString stringWithFormat:@"image%@.jpg",@(idx)] mimeType:mimeType];
                    } else {
                        NSData *data=[NSData dataWithContentsOfFile:obj];
                        if (data) {
                            [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"uploadData%@",@(idx)] fileName:[NSString stringWithFormat:@"uploadData%@",@(idx)] mimeType:mimeType];
                        }
                    }
                }];
            } error:&formError];
            if (formError) {
                [subscriber sendError:formError];
            }
            dataTask = [manager uploadTaskWithStreamedRequest:request progress:progressBlock completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                [self processResponse:subscriber error:error responseObject:responseObject];
            }];
        } else if ([data isKindOfClass:[NSData class]]) {
            NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:httpStr parameters:parameters error:nil];
            dataTask = [manager uploadTaskWithRequest:request fromData:data progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                [self processResponse:subscriber error:error responseObject:responseObject];
            }];
        } else if ([data isKindOfClass:[NSURL class]]) {
            NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:httpStr parameters:parameters error:nil];
            dataTask = [manager uploadTaskWithRequest:request fromFile:data progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                [self processResponse:subscriber error:error responseObject:responseObject];
            }];
        }
        [dataTask resume];
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

#pragma mark - 处理请求结果
- (void)processResponse:(id<RACSubscriber>)subscriber error:(NSError*)error responseObject:(id)responseObject {
    if (error) {
        [subscriber sendError:error];
    } else {
        NSString *result = @"result";
        NSInteger code = 1;
        NSString *codeStr = @"00";
        NSString *message = @"message";
        if (respondSel(self.config, @selector(result))) {
            result = [self.config result];
        }
        if (respondSel(self.config, @selector(message))) {
            message = [self.config message];
        }
        if (respondSel(self.config, @selector(successCodeString))) {
            codeStr = [self.config successCodeString];
        }
        if (respondSel(self.config, @selector(successCode))) {
            code = [self.config successCode];
        }
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (codeStr) {
            if ([responseDict[result] isEqualToString:codeStr]) {
                [subscriber sendNext:responseDict];
                [subscriber sendCompleted];
            } else {
                NSError *newError = [NSError errorWithDomain:NSOSStatusErrorDomain code:[responseDict[result] integerValue] userInfo:@{NSLocalizedDescriptionKey:responseDict[message]?:@""}];
                [subscriber sendError:newError];
            }
        } else {
            if ([responseDict[result] integerValue] == code) {
                [subscriber sendNext:responseDict];
                [subscriber sendCompleted];
            } else {
                NSError *newError = [NSError errorWithDomain:NSOSStatusErrorDomain code:[responseDict[result] integerValue] userInfo:@{NSLocalizedDescriptionKey:responseDict[message]?:@""}];
                [subscriber sendError:newError];
            }
        }
    }
}

#pragma mark - 拼装公用数据
-(NSString*)join:(NSString*)url path:(NSString*)path parameters:(NSDictionary*)parameters {
    NSMutableArray *mutableArray = @[].mutableCopy;
    if (path) {
        url = [NSString stringWithFormat:@"%@/%@",url, path];
    }
    NSString *baseUrl = url;
    if (parameters) {
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString * obj, BOOL * _Nonnull stop) {
            NSString *string=[NSString stringWithFormat:@"%@=%@",key,obj];
            [mutableArray addObject:string];
        }];
        NSString *parameterString = [mutableArray componentsJoinedByString:@"&"];
        baseUrl = [baseUrl stringByAppendingFormat:@"?%@",parameterString];
        baseUrl = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return baseUrl;
}

- (void)setSessionDidReceiveAuthenticationChallenge:(AFURLSessionDidReceiveAuthenticationChallengeBlock)sessionDidReceiveAuthenticationChallenge {
    _sessionDidReceiveAuthenticationChallenge = sessionDidReceiveAuthenticationChallenge;
    [self.safeManager setSessionDidReceiveAuthenticationChallengeBlock:sessionDidReceiveAuthenticationChallenge];
}

BOOL respondSel(id config, SEL selector) {
    return [config respondsToSelector:selector];
}

- (void)setConfig:(id<PSNetConfig>)config {
    _config = config;
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    BOOL isJson = NO;
    if (respondSel(self.config, @selector(isJsonHeader))) {
        isJson = [config isJsonHeader];
    }
    if (isJson) {
        [requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return json;
        }];
    }
    self.safeManager.requestSerializer = requestSerializer;
    self.normalManager.requestSerializer = requestSerializer;
}

#pragma mark - 创建Https SessionManager
- (void)p_createSessionManager {
    AFHTTPResponseSerializer* responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",
                                                 @"application/json",
                                                 nil];
    AFSecurityPolicy *securityPolicy =  [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    self.safeManager = [[AFHTTPSessionManager alloc] init];
    self.safeManager.responseSerializer = responseSerializer;
    self.safeManager.securityPolicy = securityPolicy;
    
    self.normalManager = [[AFHTTPSessionManager alloc] init];
    self.normalManager.responseSerializer = responseSerializer;
    self.normalManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
}

@end
