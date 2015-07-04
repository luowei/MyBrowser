//
//  ListWebViewController.h
//  MyBrowser
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyWKWebView;

@interface ListWebViewController : UIViewController

@property(nonatomic, copy) void (^updateDatasourceBlock)(MyWKWebView *);

@property(nonatomic, copy) void (^addWebViewBlock)(MyWKWebView **,NSURL *url);

@property(nonatomic, copy) void (^updateActiveWindowBlock)(MyWKWebView *);

@property(nonatomic, strong) NSMutableArray *windows;

- (instancetype)initWithWebView:(MyWKWebView *)webView;

@end
