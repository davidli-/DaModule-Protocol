//
//  DetailProtocolImplementor.m
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/3.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "DetailProtocolImplementor.h"
#import "DetailViewController.h"
#import "ModuleProtocolMediator.h"
#import "DetailModuleProtocol.h"

@interface DetailProtocolImplementor ()<DetailModuleProtocol>

@end

@implementation DetailProtocolImplementor

+ (void)load{
    
    // 注册协议 将协议与实现了此协议的业务类进行绑定
    [ModuleProtocolMediator registerModuleProtocolImplementor:[self class]
                                                   forProtocol:@protocol(DetailModuleProtocol)];
}

// 实现协议 提供具体服务
- (UIViewController *)detailControllerWithPic:(UIImage *)pic
                                     callback:(void (^)(void))callback
{
    // 具体实现
    DetailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                  instantiateViewControllerWithIdentifier:@"DetailViewController"];
    vc.image = pic;
    vc.detailCallback = callback;
    
    return vc;
}

@end
