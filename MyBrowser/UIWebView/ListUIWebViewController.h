//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyUIWebView;


@interface ListUIWebViewController : UIViewController

@property(nonatomic, copy) void (^addUIWebViewBlock)(MyUIWebView **, NSURL *);

@property(nonatomic, copy) void (^updateUIActiveWindowBlock)(MyUIWebView *);


@property(nonatomic, strong) NSMutableArray *windows;

@property(nonatomic, copy) void (^updateUIDatasourceBlock)(MyUIWebView *);

- (id)initWithUIWebView:(MyUIWebView *)webView;

@end