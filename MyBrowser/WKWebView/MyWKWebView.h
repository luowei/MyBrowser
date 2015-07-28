//
//  MyWKWebView.h
//  Webkit-Demo
//
//  Created by luowei on 15/6/25.
//  Copyright (c) 2015 rootls. All rights reserved.
//



#import <WebKit/WebKit.h>

@class MyWKWebView;

@protocol MyWebViewDelegate<NSObject>

@property(nonatomic, copy) void (^finishNavigationProgressBlock)();
@property(nonatomic, copy) void (^addWebViewBlock)(MyWKWebView **wb, NSURL *);
@property(nonatomic, copy) void (^closeActiveWebViewBlock)();
@property(nonatomic, copy) void (^presentViewControllerBlock)(UIViewController *);

@end

@interface MyWKWebView : WKWebView<WKNavigationDelegate, WKScriptMessageHandler,WKUIDelegate>

@property(nonatomic, copy) void (^finishNavigationProgressBlock)();
@property(nonatomic, copy) void (^addWKWebViewBlock)(MyWKWebView **wb, NSURL *);
@property(nonatomic, copy) void (^closeActiveWebViewBlock)();
@property(nonatomic, copy) void (^presentViewControllerBlock)(UIViewController *);


@property(nonatomic, copy) void (^updateSearchBarTextBlock)(NSString *);

@property(nonatomic, copy) void (^removeProgressObserverBlock)();

@property(nonatomic, strong) UIImage *screenImage;

@property(nonatomic, strong) UILabel *netStatusLabel;

//Sync JavaScript in WKWebView
//evaluateJavaScript is callback type. result should be handled by callback so, it is async.
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javascript;

//判断网络连接状态
- (BOOL)connected;

@end

