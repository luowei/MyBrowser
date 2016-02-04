//  ABPUrl.h
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;


@interface ABPUrl : NSURL


+ (BOOL)isDomain:(NSString *)hostName;

//+ (NSString *)getBaseDomain:(NSString *)hostName;

+(BOOL)isThirdPart:(NSString *)url documentHost:(NSString *)documentHost;

+ (NSString *)typeMaskOfUrl:(NSString *)urlString;

+ (NSDictionary<NSString *, NSNumber *> *)publicSuffixes;

@end