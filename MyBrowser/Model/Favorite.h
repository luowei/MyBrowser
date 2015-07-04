//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Favorite : NSObject<NSCoding>

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSURL *URL;
@property(nonatomic, strong) NSDate *createtime;


- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithCreateAt:(NSDate *)createtime content:(NSString *)title url:(NSURL *)URL;

- (BOOL)isEqualToFavorite:(Favorite *)fav;

@end