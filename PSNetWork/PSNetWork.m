//
//  PSNetWork.m
//  PSNetWork
//
//  Created by sheep on 2017/6/21.
//  Copyright © 2017年 sheep. All rights reserved.
//

#import "PSNetWork.h"
#import <AFNetworking/AFNetworking.h>
#define defaultTimeout 60

@interface PSNetWork()
@property (nonatomic, strong) AFHTTPSessionManager *safeManager;
@property (nonatomic, strong) AFHTTPSessionManager *normalManager;
@property (nonatomic, copy) NSString *baseUrlString;
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

- (void)registerBaseUrl:(NSString *)baseUrlString {
    self.baseUrlString = baseUrlString;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.timeout = defaultTimeout;
        [self p_createSafeManager];
        [self p_createNormalManager];
    }
    return self;
}

- (void)setSessionDidReceiveAuthenticationChallenge:(AFURLSessionDidReceiveAuthenticationChallengeBlock)sessionDidReceiveAuthenticationChallenge {
    _sessionDidReceiveAuthenticationChallenge = sessionDidReceiveAuthenticationChallenge;
    [self.safeManager setSessionDidReceiveAuthenticationChallengeBlock:sessionDidReceiveAuthenticationChallenge];
}

#pragma mark - 创建Https SessionManager
- (void)p_createSafeManager {
    AFSecurityPolicy *securityPolicy =  [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    self.safeManager = [[AFHTTPSessionManager alloc] init];
    AFHTTPResponseSerializer* responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",
                                                 @"application/json",
                                                 nil];
    self.safeManager.responseSerializer = responseSerializer;
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [requestSerializer setValue:@"iPad" forHTTPHeaderField:@"header-platform"];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [requestSerializer setValue:@"iPhone" forHTTPHeaderField:@"header-platform"];
    }
    self.safeManager.requestSerializer = requestSerializer;
    self.safeManager.securityPolicy = securityPolicy;
}

#pragma mark - 创建Http SessionManager
- (void)p_createNormalManager {
    self.normalManager = [[AFHTTPSessionManager alloc] init];
    AFHTTPResponseSerializer* responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",
                                                 @"application/json",
                                                 nil];
    self.normalManager.responseSerializer = responseSerializer;
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [requestSerializer setValue:@"iPad" forHTTPHeaderField:@"header-platform"];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [requestSerializer setValue:@"iPhone" forHTTPHeaderField:@"header-platform"];
    }
    self.normalManager.requestSerializer = requestSerializer;
    self.normalManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
}

#pragma mark - GET
- (RACSignal*)mic_GET:(NSDictionary*)params {
    return [[self rac_request:params method:@"GET"] setNameWithFormat:@"%@ -rac_GET, parameters: %@",self.class, params];
}

#pragma mark - HEAD
- (RACSignal*)mic_HEAD:(NSDictionary*)params {
    return [[self rac_request:params method:@"HEAD"] setNameWithFormat:@"%@ -rac_HEAD, parameters: %@",self.class, params];
}

#pragma mark - POST
- (RACSignal*)mic_POST:(NSDictionary*)params {
    return [[self rac_request:params method:@"POST"] setNameWithFormat:@"%@ -rac_POST, parameters: %@",self.class, params];
}

#pragma mark - PATCH
- (RACSignal*)mic_PATCH:(NSDictionary*)params {
    return [[self rac_request:params method:@"PATCH"] setNameWithFormat:@"%@ -rac_PATCH, parameters: %@",self.class, params];
}

#pragma mark - PUT
- (RACSignal*)mic_PUT:(NSDictionary*)params {
    return [[self rac_request:params method:@"PUT"] setNameWithFormat:@"%@ -rac_PUT, parameters: %@",self.class, params];
}

#pragma mark - DELETE
- (RACSignal*)mic_DELETE:(NSDictionary*)params {
    return [[self rac_request:params method:@"DELETE"] setNameWithFormat:@"%@ -rac_DELETE, parameters: %@",self.class, params];
}

- (RACSignal*)rac_request:(id)parameters method:(NSString*)method {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        AFHTTPSessionManager *manager = self.isHttps ? self.safeManager : self.normalManager;
        manager.requestSerializer.timeoutInterval = self.timeout;
        self.timeout = defaultTimeout;
        NSString *urlString = nil;
        if ([method isEqualToString:@"POST"]) {
            urlString = self.baseUrlString;
        } else {
            urlString = [self baseUrl:self.baseUrlString parameters:parameters];
        }
        NSURLRequest *request = [manager.requestSerializer requestWithMethod:method URLString:urlString parameters:mutableParameters error:nil];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                if ([responseDict[self.result] integerValue] != 1) {
                    NSError *newError = [NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:responseDict[self.message]?:@""}];
                    [subscriber sendError:newError];
                } else {
                    [subscriber sendNext:responseDict];
                    [subscriber sendCompleted];
                }
            }
        }];
        [dataTask resume];
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

#pragma mark - 上传数据
- (RACSignal*)mic_upload:(NSDictionary*)parameters
                data:(id)data
              mimeType:(NSString *)mimeType
              progress:(void(^)(NSProgress *progress))progressBlock {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        AFHTTPSessionManager *manager = self.isHttps? self.safeManager : self.normalManager;
        manager.requestSerializer.timeoutInterval = self.timeout;
        self.timeout = defaultTimeout;
        NSString *urlString = self.baseUrlString;
        NSMutableURLRequest *request = nil;
        NSError *formError = nil;
        NSURLSessionUploadTask *dataTask = nil;
        if ([data isKindOfClass:[NSArray class]]) {
            request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
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
            NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
            dataTask = [manager uploadTaskWithRequest:request fromData:data progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                [self processResponse:subscriber error:error responseObject:responseObject];
            }];
        } else if ([data isKindOfClass:[NSURL class]]) {
            NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
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

- (void)processResponse:(id<RACSubscriber>)subscriber error:(NSError*)error responseObject:(id)responseObject {
    if (error) {
        [subscriber sendError:error];
    } else {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([responseDict[self.result] integerValue] != 1) {
            NSError *newError = [NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:responseDict[self.message]?:@""}];
            [subscriber sendError:newError];
        } else {
            [subscriber sendNext:responseDict];
            [subscriber sendCompleted];
        }
    }
}

-(NSString*)baseUrl:(NSString*)url parameters:(id)parameters {
    NSMutableArray *mutableArray = @[].mutableCopy;
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString * obj, BOOL * _Nonnull stop) {
        NSString *string=[NSString stringWithFormat:@"%@=%@",key,obj];
        [mutableArray addObject:string];
    }];
    NSString *parameterString = [mutableArray componentsJoinedByString:@"&"];
    NSString *baseUrl=[NSString stringWithFormat:@"%@?%@",url,parameterString];
    baseUrl = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return baseUrl;
    
}

@end
