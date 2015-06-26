//
//  MyWebView.m
//  Webkit-Demo
//
//  Created by luowei on 15/6/25.
//  Copyright (c) 2015 rootls. All rights reserved.
//

#import "MyWebView.h"


@interface NSString (BSEncoding)

+ (NSString *)encodedString:(NSString *)string;

@end

@implementation NSString (BSEncoding)

+ (NSString *)encodedString:(NSString *)string {
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) string, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

@end



@interface MyWebView()

@property(nonatomic, strong) WKWebViewConfiguration *webViewConfiguration;

@end

@implementation MyWebView


- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.navigationDelegate = self;
        self.UIDelegate = self;
        self.allowsBackForwardNavigationGestures = YES;
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        //webview configuration
        self.webViewConfiguration = configuration;

        //加载用户js文件,修改加载网页内容
        [self addUserScriptsToWeb];
    }

    return self;
}

//加载用户js文件
- (void)addUserScriptsToWeb {

    NSString *userScriptString = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"userScript" withExtension:@"js"]
                                                                encoding:NSUTF8StringEncoding error:NULL];
//    NSString *scriptString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"postingMsg" ofType:@"js"]
//                                                       encoding:NSUTF8StringEncoding error:NULL];

//    NSString *path = [[NSBundle mainBundle] pathsForResourcesOfType:@"js" inDirectory:@"Resource"][0];
//    NSString *scriptString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

//    //在document加载前执行注入js脚本
//    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:scriptString injectionTime:WKUserScriptInjectionTimeAtDocumentStart
//                                                   forMainFrameOnly:YES];

    //在document加载完成后执行注入js脚本
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:userScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
    [self.webViewConfiguration.userContentController addUserScript:userScript];

    //添加js脚本到处理器中
    [self.webViewConfiguration.userContentController addScriptMessageHandler:self name:@"myName"];
}

#pragma mark WKNavigationDelegate Implementation

//当加载页面发生错误
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {

//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
//                                                                   message:error.localizedDescription
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
//    [self presentViewController:alert animated:YES completion:nil];

    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

//当页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.finishNavigationProgressBlock();
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    //处理特殊网址
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && navigationAction.request.URL.host != nil
            && [navigationAction.request.URL.host.lowercaseString hasPrefix:@"www.youku.com"]) {
        //用用户默认浏览器safari打开
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }


/*
    if ([[[navigationAction.request URL] absoluteString] rangeOfString:@"affiliate_id="].location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:[navigationAction.request URL]];
    }
    // Check URL for special prefix, which marks where we overrode JS. If caught, return NO.
    if ([[[navigationAction.request URL] absoluteString] hasPrefix:@"hdwebview"]) {

        // The injected JS window override separates the method (i.e. "jswindowopenoverride") and the
        // suffix (i.e. a URL to open in the overridden window.open method) with double pipes ("||")
        // Here we strip out the prefix and break apart the method so we know how to handle it.
        NSString *suffix = [[[navigationAction.request URL] absoluteString] stringByReplacingOccurrencesOfString:@"hdwebview://" withString:@""];
        NSArray *methodAsArray = [suffix componentsSeparatedByString:[NSString encodedString:@"||"]];
        NSString *method = methodAsArray[0];

        if ([method isEqualToString:@"jswindowopenoverride"]) {

            NSLog(@"window.open caught");
            NSURL *url = [NSURL URLWithString:[NSString stringWithString:methodAsArray[1]]];
            self.addWebViewBlock(nil,url);

        } else if ([method isEqualToString:@"jswindowcloseoverride"] || [method isEqualToString:@"jswindowopenerfocusoverride"]) {

            // Only close the active web view if it's not the base web view. We don't want to close
            // the last web view, only ones added to the top of the original one.
            NSLog(@"window.close caught");
            self.closeActiveWebViewBlock();

        }

    }

    // If the web view isn't the active window, we don't want it to do any more requests.
    // This fixes the issue with popup window overrides, where the underlying window was still
    // trying to redirect to the original anchor tag location in addition to the new window
    // going to the same location, which resulted in the "back" button needing to be pressed twice.
//    if (![webView isEqual:self.activeWindow]) {
//    }
*/


}



#pragma mark WKMessageHandle Implementation

//处理当接收到html页面脚本发来的消息
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//    [userContentController addScriptMessageHandler:self name:@"myName"];
    if ([message.name isEqualToString:@"myName"]) {
        //处理消息内容
//        [[[UIAlertView alloc] initWithTitle:@"message" message:message.body delegate:self
//                          cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark WKUIDelegate Implementation

//let link has arget=”_blank” work
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

    //
    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView loadRequest:navigationAction.request];
        MyWebView *wb = nil;
        self.addWebViewBlock(&wb,navigationAction.request.mainDocumentURL);
        return wb;
    }
    return nil;
}

//处理页面的alert弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    self.presentViewControllerBlock(alertController);
}

//处理页面的confirm弹窗
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

    // TODO We have to think message to confirm "YES"
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    self.presentViewControllerBlock(alertController);
}

//处理页面的promt弹窗
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:webView.URL.host preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    self.presentViewControllerBlock(alertController);
}


@end
