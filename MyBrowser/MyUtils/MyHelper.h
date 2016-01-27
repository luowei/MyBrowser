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

@interface NSString(IO)

//把self写入文件,fileName以'/'开头,可带路径
+(void) writeString:(NSString *)text ToFile:(NSString *)fileName;

//读取文件,fileName以'/'开头,可带路径
+(NSString *)readStringFromFile:(NSString *)fileName;

@end


@interface NSString (BSEncoding)

+ (NSString *)encodedString:(NSString *)string;

+ (NSString *)base64Encoding:(NSString *)string;

+ (NSString *)base64Decoding:(NSString *)base64String;

@end

@interface NSString(Match)

- (BOOL)isMatchString:(NSString *)pattern;

- (BOOL)isiTunesURL;

- (BOOL)isDomain;

- (BOOL)isHttpURL;

@end


@interface UIView(Capture)

- (UIImage *)screenCapture;

- (UIImage *)screenCapture:(CGSize)size;

@end

@interface UIImage(Color)

+ (UIImage *)imageWithColor:(UIColor *)color;
//获得图片的alpha通道值
- (CGFloat)getImageAlphaValue;

@end


//#pragma mark Priavte API Define
//
//@interface WKBackForwardList (WKPrivate)
//
//- (void)_clear;
//
//@end