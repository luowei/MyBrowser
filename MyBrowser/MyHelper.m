//
//  MyHelper.m
//  MyBrowser
//
//  Created by luowei on 15/6/27.
//  Copyright (c) 2015 wodedata. All rights reserved.
//

#import "MyHelper.h"

@implementation MyHelper


//显示提示窗
+ (void)showToastAlert:(NSString *)message {
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

@end
