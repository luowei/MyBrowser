//
// Created by luowei on 16/1/27.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "UserSetting.h"
#import "Defines.h"
#import "MyHelper.h"


static NSString *const AdblockStatus = @"AdblockStatus";

static NSString *const NoImageMode = @"NoImageMode";

@implementation UserSetting {

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
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UASignIsChanged"];
    [[NSUserDefaults standardUserDefaults] setInteger:sign forKey:@"UASign"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)UserAgent {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"];
}

+(void)SetUserAgent:(NSString *)userAgent {
    [[NSUserDefaults standardUserDefaults] setObject:userAgent forKey:@"UserAgent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end