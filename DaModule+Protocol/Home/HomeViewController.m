//
//  HomeViewController.m
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/2.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "HomeViewController.h"
#import "ModuleProtocolMediator.h"
#import "CommonProtocol.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onShowDetail:(id)sender {
    
    UIButton *btn = sender;
    
    /* 调用详情组件 因为导入了 ModuleProtocolMediator 和 DetailModuleProtocol，所以当前类中直到详情组件提供了哪些服务接口，调用这些接口即可~
     当前类只跟ModuleProtocolMediator交互，不与DetailViewController耦合~
     */
    id<DetailModuleProtocol> implementor = [ModuleProtocolMediator protocolImplementorWithProtocol:@protocol(DetailModuleProtocol)];
    
    // 调用接口 传递参数 获取返回值
    UIViewController *vc = [implementor detailControllerWithPic:btn.currentBackgroundImage callback:^{
        self.title = @"Info Checked";
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
