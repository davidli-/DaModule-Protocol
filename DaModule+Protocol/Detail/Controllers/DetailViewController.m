//
//  DetailViewController.m
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/2.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mIconImv;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mIconImv.image = self.image;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBackWithBlock) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}


- (void)dealloc{
    NSLog(@"+++%@ dealloced~",[self class]);
}

- (void)onBackWithBlock{
    self.detailCallback();
    [self.navigationController popViewControllerAnimated:YES];
}

@end
