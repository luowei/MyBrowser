//
//  MyWebView.h
//  Webkit-Demo
//
//  Created by luowei on 15/6/25.
//  Copyright (c) 2015 rootls. All rights reserved.
//



#import <WebKit/WebKit.h>

@interface MyWebView : WKWebView<WKNavigationDelegate, WKScriptMessageHandler,WKUIDelegate>

@property(nonatomic, copy) void (^finishNavigationProgressBlock)();
@property(nonatomic, copy) void (^addWebViewBlock)(MyWebView **wb, NSURL *);
@property(nonatomic, copy) void (^closeActiveWebViewBlock)();
@property(nonatomic, copy) void (^presentViewControllerBlock)(UIViewController *);
@end
