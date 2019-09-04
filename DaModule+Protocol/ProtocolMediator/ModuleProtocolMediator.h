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


/**
 远程调用接口
 @param url 按照约定好的格式传值
 @param completion 回调
 @return 返回值 是否响应此URL
 */
+ (BOOL)performActionWithUrl:(NSURL *)url
                completion:(void(^)(id info))completion;

@end

NS_ASSUME_NONNULL_END
