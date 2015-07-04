//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import "TOTWebView.h"


@interface TOTWebView() {
    WKWebView* _wkWebView;
    UIWebView* _uiWebView;
}

@end


@implementation TOTWebView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if ([WKWebView class]) {
        _wkWebView = [[WKWebView alloc] initWithFrame:frame];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [self addSubview:_wkWebView];

    } else {
        _uiWebView = [[UIWebView alloc] init];
        _uiWebView.delegate = self;
        [self addSubview:_uiWebView];
    }

    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_wkWebView setFrame:frame];
    [_uiWebView setFrame:frame];
}


- (void)loadRequest:(NSURLRequest *)request {
    if (_wkWebView) {
        [_wkWebView loadRequest:request];
    }
    if (_uiWebView) {
        [_uiWebView loadRequest:request];
    }
}


#pragma mark - UIWebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    return [self.delegate shouldStartLoadWithURL:request.URL];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (self.delegate != nil) {
        [self.delegate didStartLoading];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.delegate != nil) {
        [self.delegate didFinishLoading];
    }
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.delegate != nil) {
        [self.delegate didFailLoadingWithError:error];
    }
}



#pragma mark - WKWebView

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.delegate != nil) {
        [self.delegate didStartLoading];
    }
}


- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {

}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.delegate != nil) {
        [self.delegate didFinishLoading];
    }
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if (self.delegate != nil) {
        [self.delegate didFailLoadingWithError:error];
    }
}



- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //自定义策略的处理
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;

    if (self.delegate != nil) {
        NSURL *url = navigationAction.request.URL;
        if (![self.delegate shouldStartLoadWithURL:url]) {
            //取消执行策略
            policy = WKNavigationActionPolicyCancel;
        }
    }
    decisionHandler(policy);
}

@end