//
//  ModuleProtocolMediator.h
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/3.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModuleProtocolMediator : NSObject

+ (instancetype)shareInstance;

// 将实现了协议的服务类注册到全局字典中
+ (void)registerModuleProtocolImplementor:(Class)implementor
                      forProtocol:(Protocol*)protocol;

// 根据协议查询实现了此协议的服务类，并返回它的一个实例
+ (id)protocolImplementorWithProtocol:(Protocol*)protocol;

@end

NS_ASSUME_NONNULL_END
