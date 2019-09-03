//
//  DetailViewController.h
//  DaModule+Protocol
//
//  Created by Macmafia on 2019/9/2.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^detailCallback) (void);

@end

NS_ASSUME_NONNULL_END
