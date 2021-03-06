# PSNetWork
`PSNetWork`是对[AFNetworking](https://github.com/AFNetworking/AFNetworking)的二次封装，使用了`ReactiveObjC`进行封装，定义了各种请求的RACSignal，使用时只需要监听信号

# 快速集成
```
pod 'PSNetWork'
```

# 说明
首先注册一个请求的baseURL
```
- (void)registerBaseUrl:(NSString*_Nonnull)baseUrlString;
```

可以为每一个请求定义超时时间，默认是60s
```
@property (nonatomic, assign) NSTimeInterval timeout;
```
是否为HTTPS请求
```
@property (nonatomic, assign) BOOL isHttps;
```
不同的请求方式
```
//get
- (RACSignal*_Nonnull)mic_GET:(NSDictionary*_Nonnull)params;
//post
- (RACSignal*_Nonnull)mic_POST:(NSDictionary*_Nonnull)params;
//head
- (RACSignal*_Nonnull)mic_HEAD:(NSDictionary*_Nonnull)params;
//patch
- (RACSignal*_Nonnull)mic_PATCH:(NSDictionary*_Nonnull)params;
//put
- (RACSignal*_Nonnull)mic_PUT:(NSDictionary*_Nonnull)params;
//delete
- (RACSignal*_Nonnull)mic_DELETE:(NSDictionary*_Nonnull)params;
//upload
- (RACSignal*_Nonnull)mic_upload:(NSDictionary * _Nonnull )params
                data:(id _Nullable )data
              mimeType:(nullable NSString*)mimeType
              progress:(void(^_Nullable)(NSProgress * _Nullable progress))progressBlock
```
使用示例
```
[[[MicNetworkUtil shareInstance] mic_GET:params] subscribeNext:^(NSDictionary * _Nullable responseDict) {
        safeBlock(complete, nil);
    } error:^(NSError * _Nullable error) {
        safeBlock(complete, error);
    }];
  ```
