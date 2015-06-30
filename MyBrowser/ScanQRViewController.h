//
//  ScanQRViewController.h
//  MyBrowser
//
//  Created by luowei on 15/6/30.
//  Copyright (c) 2015 wodedata. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ScanQRViewController : UIViewController

@property(nonatomic, copy) void (^openURLBlock)(NSURL *);
@end
