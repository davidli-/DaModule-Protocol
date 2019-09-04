//
//  ModuleProtocolMediator.m
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/3.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "ModuleProtocolMediator.h"
#import <UIKit/UIKit.h>

@interface ModuleProtocolMediator ()

@property (nonatomic, strong) NSMutableDictionary *mProtocolsDic;

@end

@implementation ModuleProtocolMediator

+ (instancetype)shareInstance{
    
    static ModuleProtocolMediator *mProtocolManager;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        mProtocolManager = [[ModuleProtocolMediator alloc] init];
    });
    
    return mProtocolManager;
}

- (instancetype)init{
    if (self = [super init]) {
        _mProtocolsDic = [NSMutableDictionary dictionary];
    }
    return self;
}

// 注册 将协议与实现类进行绑定 以便后续查找此类
+ (void)registerModuleProtocolImplementor:(Class)implementor
                      forProtocol:(Protocol*)protocol{
    
    NSString *key = NSStringFromProtocol(protocol);
    [ModuleProtocolMediator shareInstance].mProtocolsDic[key] = implementor;
}

// 查找实现了此协议的类 生成其实例
+ (id)protocolImplementorWithProtocol:(Protocol*)protocol{
    
    NSString *key = NSStringFromProtocol(protocol);
    Class className = [ModuleProtocolMediator shareInstance].mProtocolsDic[key];
    id obj = [[className alloc] init];
    
    return obj;
}

/* url示例：@"DaModuleProtocolScheme://DetailModuleProtocol:detailControllerWithPic%3acallback%3a"
 * scheme://[protocolName]:[protocolMethod]?key1=value1&key2=value2
 * [scheme]  [host]         [path]           [query]
 */
+ (BOOL)performActionWithUrl:(NSURL *)url
                completion:(void (^)(id info))completion
{
    NSMutableArray *params = [[NSMutableArray alloc] init];
    NSString *urlString = [url query];
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params addObject:[elts lastObject]];
    }
    // 反射协议对象
    Protocol *protocol = NSProtocolFromString(url.host);
    // 调用本类查询协议的实现类
    NSObject *target = [self protocolImplementorWithProtocol:protocol];
    // 取出想调用的协议方法
    NSString *protocolMethod = [[url.path stringByRemovingPercentEncoding]
                                stringByReplacingOccurrencesOfString:@"/" withString:@""];
    // 反射SEL，即协议中定义的方法
    SEL selector = NSSelectorFromString(protocolMethod);
    
    // 调用 perform 方法或者 NSInvocation 实现通信
    NSDictionary *resultDic = [self safePerformAction:selector target:target params:params];
    BOOL hasError = [resultDic[@"error"] boolValue];
    if (hasError) {
        return NO;
    }else{
        id value = resultDic[@"retValue"];
        if (completion) {
            completion(value);
        }
        return YES;
    }
}


+ (NSDictionary*)safePerformAction:(SEL)action
                 target:(NSObject *)target
                 params:(NSArray *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return @{@"error":@(YES)};
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0 ||
        strcmp(retType, @encode(NSInteger)) == 0 ||
        strcmp(retType, @encode(BOOL)) == 0 ||
        strcmp(retType, @encode(CGFloat)) == 0 ||
        strcmp(retType, @encode(NSUInteger)) == 0)
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setSelector:action];
        [invocation setTarget:target];
        
        NSInteger count = params.count;
        for (int i = 0; i < count; i++) {
            NSObject *value = params[i];
            [invocation setArgument:&value atIndex:i + 2]; // 参数从第二位开始算起
        }
        [invocation invoke];
        
        // 区分返回值类型
        if (strcmp(retType, @encode(void)) == 0) {
            return @{@"error":@(NO)};
        }
        
        else if (strcmp(retType, @encode(NSInteger)) == 0) {
            NSInteger result = 0;
            [invocation getReturnValue:&result];
            return @{@"error":@(NO),@"retValue":@(result)};
        }
        
        else if (strcmp(retType, @encode(BOOL)) == 0) {
            BOOL result = 0;
            [invocation getReturnValue:&result];
            return @{@"error":@(NO),@"retValue":@(result)};
        }
        
        else if (strcmp(retType, @encode(CGFloat)) == 0) {
            CGFloat result = 0;
            [invocation getReturnValue:&result];
            return @{@"error":@(NO),@"retValue":@(result)};
        }
        
        else if (strcmp(retType, @encode(NSUInteger)) == 0) {
            NSUInteger result = 0;
            [invocation getReturnValue:&result];
            return @{@"error":@(NO),@"retValue":@(result)};
        }
    }
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id retValue = [target performSelector:action withObject:params];
    return @{@"error":@(NO),@"retValue":retValue};
#pragma clang diagnostic pop
}
@end
