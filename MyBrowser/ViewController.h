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

@interface ViewController : UIViewController

@property(nonatomic, strong) ListWebViewController *listWebViewController;

@property (nonatomic,strong) MyWebView *activeWindow;


@end

