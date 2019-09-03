//
//  ModuleProtocolMediator.m
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/3.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "ModuleProtocolMediator.h"

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

@end
