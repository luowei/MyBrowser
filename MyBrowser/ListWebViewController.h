//
//  ListWebViewController.h
//  MyBrowser
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyWebView;

@interface ListWebViewController : UIViewController

@property(nonatomic, copy) void (^updateDatasourceBlock)(MyWebView *);

@property(nonatomic, copy) void (^addWebViewBlock)(MyWebView **,NSURL *url);

@property(nonatomic, copy) void (^updateActiveWindowBlock)(MyWebView *);

@property(nonatomic, strong) NSMutableArray *windows;

- (instancetype)initWithWebView:(MyWebView *)webView;

@end
