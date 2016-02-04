//
//  ABPCategroys.h
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface ABPCategroys : NSObject
@end

@interface NSString(IO)

//把self写入文件,fileName以'/'开头,可带路径
+(void) writeString:(NSString *)text ToFile:(NSString *)fileName;

//读取文件,fileName以'/'开头,可带路径
+(NSString *)readStringFromFile:(NSString *)fileName;

- (int) indexOfString:(NSString *)text;

@end;


/*
#pragma mark -

@interface NSString (RegExp)

//self转变成RegExpression
-(NSRegularExpression *)regExp;

//判断是否匹配正则式pattern
- (NSTextCheckingResult *)matchPattern:(NSString *)pattern;

//对self执行pattern匹配,返回匹配项
- (NSArray<NSTextCheckingResult *> *)execPattern:(NSString *)pattern;

//对self匹配项(match)进行分组取值,返回包含匹配项及所有分组项
- (NSArray<NSString *> *)matchGroupRex:(NSTextCheckingResult *)match;

//把匹配正则的都替换掉
-(NSString *)replaceAllMatch:(NSRegularExpression *)regex with:(NSString *)replacement;

//把匹配origin的都替换掉
-(NSString *)replaceAllString:(NSString *)origin with:(NSString *)replacement;

- (NSString *)replace:(NSRegularExpression *)rx with:(NSString *)replacement;

- (NSArray *)split:(NSRegularExpression *)rx;

@end

@interface NSRegularExpression (ext)

- (NSArray *)split:(NSString *)str;

@end
*/

