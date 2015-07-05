//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyURLProtocol : NSURLProtocol

@property(nonatomic, strong) NSURLConnection *connection;

@property(nonatomic, strong) NSMutableData *mutableData;
@property(nonatomic, strong) NSURLResponse *response;

@end