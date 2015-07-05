//
//  ListWKWebViewController.h
//  MyBrowser
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyWKWebView;

@interface ListWKWebViewController : UIViewController

@property(nonatomic, copy) void (^updateWKDatasourceBlock)(MyWKWebView *);

@property(nonatomic, copy) void (^addWKWebViewBlock)(MyWKWebView **,NSURL *url);

@property(nonatomic, copy) void (^updateWKActiveWindowBlock)(MyWKWebView *);

@property(nonatomic, strong) NSMutableArray *windows;

- (instancetype)initWithWKWebView:(MyWKWebView *)webView;

@end
