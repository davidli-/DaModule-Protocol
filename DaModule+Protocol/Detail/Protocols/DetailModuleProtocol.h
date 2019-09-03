//
//  DetailModuleProtocol.h
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/3.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#ifndef DetailModuleProtocol_h
#define DetailModuleProtocol_h

#import <UIKit/UIKit.h>

/**
 *详情组件对外提供的所有服务，都在这里以协议方法的形式对外曝光；
 *此协议对所有其他组件可见，所以其他组件导入此头文件即可知道详情组件有哪些服务可用；
 *面向协议编程；
 */
@protocol DetailModuleProtocol <NSObject>

@required

/**
 进入详情页

 @param pic 图片
 @param callback 从详情页返回时的回调
 @return 返回详情页，以便主页调用push进入此页面
 */
- (UIViewController*)detailControllerWithPic:(UIImage*)pic callback:(void(^)(void))callback;

@end

#endif /* DetailModuleProtocol_h */
