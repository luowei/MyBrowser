//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import "Favorite.h"


@implementation Favorite

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
        self.title = dic[@"title"];
        self.URL = dic[@"URL"];
        self.createtime = dic[@"createtime"] ?: [NSDate date];
    }
    return self;
}

- (instancetype)initWithCreateAt:(NSDate *)createtime content:(NSString *)title url:(NSURL *)URL {
    if (self = [super init]) {
        self.createtime = createtime ?: [NSDate date];
        self.title = title;
        self.URL = URL;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.URL = [coder decodeObjectForKey:@"URL"];
        self.createtime = [coder decodeObjectForKey:@"createtime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeObject:_URL forKey:@"URL"];
    [coder encodeObject:_createtime forKey:@"createtime"];
}

- (BOOL)isEqualToFavorite:(Favorite *)fav {
    return [_title isEqualToString:fav.title] && [_URL.absoluteString isEqualToString:fav.URL.absoluteString];
}

@end