//
// Created by luowei on 16/1/27.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserSetting : NSObject

+ (void)setAdblockerStatus:(id)status;
+ (BOOL)adblockerStatus;

+ (void)setImageBlockerStatus:(id)status;
+ (BOOL)imageBlockerStatus;

//获得EasyList字符串数据
+ (NSString *)getEasyListText;


//UA标识
+ (NSInteger)UASign;
+(BOOL)UASignIsChanged;
+(void)SetUASign:(NSInteger)sign;
+(NSString *)UserAgent;
+(void)SetUserAgent:(NSString *)userAgent;

@end