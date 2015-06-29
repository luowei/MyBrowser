//
//  ViewController.h
//  MyBrowser
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyWebView;
@class ListWebViewController;
@class AWActionSheet;
@class MyPopupView;

@interface ViewController : UIViewController

@property(nonatomic, strong) ListWebViewController *listWebViewController;

@property(nonatomic, strong) MyWebView *activeWindow;


@property(nonatomic, strong) NSMutableArray *favoriteArray;
@property(nonatomic, strong) CALayer *webmaskLayer;
@end


@interface NSString (Match)

- (BOOL)isMatch:(NSString *)pattern;

- (BOOL)isiTunesURL;

- (BOOL)isDomain;

- (BOOL)isHttpURL;

@end


@interface Favorite : NSObject<NSCoding>

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSURL *URL;
@property(nonatomic, strong) NSDate *createtime;


- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithCreateAt:(NSDate *)createtime content:(NSString *)title url:(NSURL *)URL;

- (BOOL)isEqualToFavorite:(Favorite *)fav;

@end