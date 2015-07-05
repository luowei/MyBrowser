//
//  MyWKWebViewController.h
//  MyBrowser
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseWebViewController.h"

@class MyWKWebView;
@class ListWKWebViewController;
@class MyPopupView;

@interface MyWKWebViewController : BaseWebViewController

@property(nonatomic, strong) MyWKWebView *activeWindow;
@property(nonatomic, strong) ListWKWebViewController *listWebViewController;

@end
