//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseWebViewController.h"

@class MyUIWebView;
@class ListUIWebViewController;


@interface MyUIWebViewController : BaseWebViewController

@property(nonatomic, strong) MyUIWebView *activeWindow;
@property(nonatomic, strong) ListUIWebViewController *listWebViewController;

@end