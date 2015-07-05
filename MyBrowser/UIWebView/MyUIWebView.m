//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import "MyUIWebView.h"
#import "MyHelper.h"

@interface MyUIWebView()<UIWebViewDelegate>

@end

@implementation MyUIWebView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scalesPageToFit = YES;
    }

    return self;
}

#pragma mark - Web View Delegate Methods

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //以下是通过重载页面的window.open,window.close方法来实现打开新窗口，关闭新窗口等逻辑
    if ([[[request URL] absoluteString] rangeOfString:@"affiliate_id="].location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:[request URL]];
    }
    // Check URL for special prefix, which marks where we overrode JS. If caught, return NO.
    if ([[[request URL] absoluteString] hasPrefix:@"hdwebview"]) {

        // The injected JS window override separates the method (i.e. "jswindowopenoverride") and the
        // suffix (i.e. a URL to open in the overridden window.open method) with double pipes ("||")
        // Here we strip out the prefix and break apart the method so we know how to handle it.
        NSString *suffix = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:@"hdwebview://" withString:@""];
        NSArray *methodAsArray = [suffix componentsSeparatedByString:[NSString encodedString:@"||"]];
        NSString *method = methodAsArray[0];

        if ([method isEqualToString:@"jswindowopenoverride"]) {

            NSLog(@"window.open caught");
            NSURL *url = [NSURL URLWithString:[NSString stringWithString:methodAsArray[1]]];
            self.addUIWebViewBlock(nil,url);

        } else if ([method isEqualToString:@"jswindowcloseoverride"] || [method isEqualToString:@"jswindowopenerfocusoverride"]) {

            // Only close the active web view if it's not the base web view. We don't want to close
            // the last web view, only ones added to the top of the original one.
            NSLog(@"window.close caught");
            self.closeActiveWebViewBlock();

        }
        return NO;

    }

    // If the web view isn't the active window, we don't want it to do any more requests.
    // This fixes the issue with popup window overrides, where the underlying window was still
    // trying to redirect to the original anchor tag location in addition to the new window
    // going to the same location, which resulted in the "back" button needing to be pressed twice.
//    if (![webView isEqual:self.activeWindow]) {
//        return NO;
//    }
    return YES;
}

@end