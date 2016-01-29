//
// Created by luowei on 16/1/27.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <objc/runtime.h>
#import "UserSetting.h"
#import "Defines.h"
#import "MyHelper.h"


static NSString *const AdblockStatus = @"AdblockStatus";

static NSString *const NoImageMode = @"NoImageMode";

@implementation UserSetting {

}

//显示类的私有方法
+ (void)showAllPrivateMethod:(Class)clazz {
    u_int count;
    Method *methods = class_copyMethodList(clazz, &count);
    NSLog(@"----------------显示类的私有方法-----------");
    for (int i = 0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"*****Private Method:%@", strName);
    }
}

+ (void)setAdblockerStatus:(id)status {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:status forKey:AdblockStatus];
    [userDefaults synchronize];
}

+ (BOOL)adblockerStatus {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id value = [userDefaults valueForKey:AdblockStatus];
    if(value && [value isKindOfClass:[NSNumber class]]){
        return ((NSNumber *)value).boolValue;
    }else{
        //默认无广告模式
        [userDefaults setValue:@(YES) forKey:AdblockStatus];
        return YES;
    }
}


+ (void)setImageBlockerStatus:(id)status {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:status forKey:NoImageMode];
    [userDefaults synchronize];
}

+ (BOOL)imageBlockerStatus {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id value = [userDefaults valueForKey:NoImageMode];
    if(value && [value isKindOfClass:[NSNumber class]]){
        return ((NSNumber *)value).boolValue;
    }else{
        //默认有图模式
        [userDefaults setValue:@(NO) forKey:NoImageMode];
        return NO;
    }
}


//获得EasyList字符串数据
+ (NSString *)getEasyListText {
//- (NSArray *)easyListLines {
    NSError *error;
    //读取EasyList规则

    //从应用沙盒目录读取
    NSString *fileContents = [NSString readStringFromFile:EasyList_NamePath];
    if (!fileContents) {

        //从应用的bundle中读取
        NSString *filePath = [[NSBundle mainBundle] pathForResource:EasyList_FileName ofType:@"txt"];
        fileContents =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if(!fileContents){

            //从网页读取
            fileContents = [NSString stringWithContentsOfURL:[NSURL URLWithString:EasyList_Url]
                                                    encoding:NSUTF8StringEncoding error:&error];
            if (fileContents) { //写入本地
                [NSString writeString:fileContents ToFile:EasyList_NamePath];
            }
        }else{
            //写入本地
            [NSString writeString:fileContents ToFile:EasyList_NamePath];
        }

    }
//    NSArray *allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//    return allLinedStrings;
    return fileContents;
}


//UA标识
+ (NSInteger)UASign {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"UASign"];
}
+(BOOL)UASignIsChanged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UASignIsChanged"];
}
+(void)SetUASign:(NSInteger)sign {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"UASignIsChanged"];
    [userDefaults setInteger:sign forKey:@"UASign"];
    [userDefaults synchronize];
}

+(NSString *)UserAgent {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"];
}

+(void)SetUserAgent:(NSString *)userAgent {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userAgent forKey:@"UserAgent"];
    [userDefaults synchronize];
}


//夜间模式
+ (void)setNighttime:(BOOL)isNightMode {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isNightMode forKey:@"IsNightMode"];
    [userDefaults synchronize];
}

+ (BOOL)nighttime {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"IsNightMode"];
}


@end