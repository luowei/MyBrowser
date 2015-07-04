//
//  MyHelper.h
//  MyBrowser
//
//  Created by luowei on 15/6/27.
//  Copyright (c) 2015 wodedata. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MyHelper : NSObject

//显示提示窗
+ (void)showToastAlert:(NSString *)message;

//获得屏幕大小
+ (CGSize)fixedScreenSize;

@end


@interface NSString (BSEncoding)

+ (NSString *)encodedString:(NSString *)string;

@end

@interface NSString(Match)

- (BOOL)isMatch:(NSString *)pattern;

- (BOOL)isiTunesURL;

- (BOOL)isDomain;

- (BOOL)isHttpURL;

@end


@interface UIView(Capture)

- (UIImage *)screenCapture;

- (UIImage *)screenCapture:(CGSize)size;

@end

@interface WKBackForwardList (WKPrivate)

- (void)_clear;

@end