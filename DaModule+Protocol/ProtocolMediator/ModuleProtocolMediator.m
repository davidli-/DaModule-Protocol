//
//  ModuleProtocolMediator.m
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/3.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "ModuleProtocolMediator.h"
#import <UIKit/UIKit.h>

struct CallResult {
    BOOL raiseError; // 是否产生异常错误（如target或SEL为nil）
    id result;       // perform 或 invocation 的返回值
};

@interface ModuleProtocolMediator ()
@property (nonatomic, strong) NSMutableDictionary *mProtocolsDic; // 保存协议与实现类的全局容器
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

/* url示例：@"DaModuleProtocolScheme://DetailModuleProtocol:detailControllerWithPic:callback:"
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
    // 取出想调用的协议方法(URL Decode)
    NSString *protocolMethod = [[url.path stringByRemovingPercentEncoding]
                                stringByReplacingOccurrencesOfString:@"/" withString:@""];
    // 反射SEL，即协议中定义的方法
    SEL selector = NSSelectorFromString(protocolMethod);
    
    // 调用 perform 方法或者 NSInvocation 实现通信
    struct CallResult retStruct = [self safePerformAction:selector target:target params:params];

    if (retStruct.raiseError) {
        return NO;
    }else{
        id value = retStruct.result;
        if (completion) {
            completion(value);
        }
        return YES;
    }
}


+ (struct CallResult)safePerformAction:(SEL)action
                 target:(NSObject *)target
                 params:(NSArray *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        struct CallResult retStruct = {YES,nil};
        return retStruct;
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0 ||
        strcmp(retType, @encode(BOOL)) == 0 ||
        strcmp(retType, @encode(CGFloat)) == 0 ||
        strcmp(retType, @encode(NSInteger)) == 0 ||
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
        
        // 无返回值时，结构体中result字段为nil
        if (strcmp(retType, @encode(void)) == 0) {
            struct CallResult retStruct = {NO,nil};
            return retStruct;
        }
        else { // 返回值为数值类型时，包装成对象
            NSInteger result = 0;
            [invocation getReturnValue:&result];
            struct CallResult retStruct = {NO,@(result)};
            return retStruct;
        }
    }
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // 返回值为对象类型，直接调用即可
    id result = [target performSelector:action withObject:params];
    struct CallResult retStruct = {NO,result};
    return retStruct;
#pragma clang diagnostic pop
}
@end
