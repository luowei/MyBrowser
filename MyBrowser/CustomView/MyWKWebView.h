//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "MyWebView.h"

//todo:注意,WKWebView is impossible to intercept the URL Loading System.
//这就意味着：
// 1.无法用WKWebView加载本地文件；
// 2.无法处理自定义的URL协议,即无法URL Secheme/App Store的链接；(变相用[[UIApplication sharedApplication] openURL:url])
// 3.不能过滤页面内URL、不能使用NSURLCache/NSCachedURLResponse缓存website的数据；
// 4.


@interface MyWKWebView : WKWebView<MyWebViewDelegate,WKNavigationDelegate, WKScriptMessageHandler,WKUIDelegate>

//Sync JavaScript in WKWebView
//evaluateJavaScript is callback type. result should be handled by callback so, it is async.
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javascript;

@end