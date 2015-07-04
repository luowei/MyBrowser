//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

//参考自:
// A mechanism to switch the UIWebView and WKWebView we tried to prototype：
//  http://qiita.com/tototti/items/e5b33293da388d43e2b7

// let UIWebView as WKWebView：
// http://techblog.yahoo.co.jp/ios/let-uiwebview-as-wkwebview/


#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


@protocol TOTWebViewDelegate
- (BOOL)shouldStartLoadWithURL:(NSURL*)url;
- (void)didStartLoading;
- (void)didFinishLoading;
- (void)didFailLoadingWithError:(NSError*)error;
@end


@interface TOTWebView : UIView <UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate>

@property (assign) id<TOTWebViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)loadRequest:(NSURLRequest *)request;

@end