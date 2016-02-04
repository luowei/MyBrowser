//  ABPCategroys.m
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//

#import "ABPCategroys.h"


@implementation ABPCategroys {

}
@end


@implementation NSString(IO)

//把self写入文件,fileName以'/'开头,可带路径
+(void) writeString:(NSString *)text ToFile:(NSString *)fileName{
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *fileAtPath = [filePath stringByAppendingString:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    [[text dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

//读取文件,fileName以'/'开头,可带路径
+(NSString *)readStringFromFile:(NSString *)fileName{
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *fileAtPath = [filePath stringByAppendingString:fileName];
    NSData *data = [NSData dataWithContentsOfFile:fileAtPath];
    if(!data){
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (int)indexOfString:(NSString *)text {
    NSRange range = [self rangeOfString:text];
    if (range.length > 0) {
        return (int) range.location;
    } else {
        return -1;
    }
}

@end


/*

#pragma mark -

@implementation NSString (RegExp)


//self转变成RegExpression
- (NSRegularExpression *)regExp {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self options:0 error:&error];
    if (error) {
        return nil;
    } else {
        return regex;
    }
}

//判断是否匹配正则式pattern
- (NSTextCheckingResult *)matchPattern:(NSString *)pattern {
    return [pattern.regExp firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
}

//对self执行pattern匹配,返回所有匹配项
- (NSArray<NSTextCheckingResult *> *)execPattern:(NSString *)pattern {
    NSRange searchedRange = NSMakeRange(0, [self length]);
    return [pattern.regExp matchesInString:self options:0 range:searchedRange];
}

//对self匹配项(match)进行分组取值,返回包含匹配项及所有分组项
- (NSArray<NSString *> *)matchGroupRex:(NSTextCheckingResult *)match {
    NSMutableArray<NSString *> *matchStrArr = @[].mutableCopy;
    for (NSUInteger i = 0; i < match.numberOfRanges; i++) {
        NSRange group = [match rangeAtIndex:i];
        if(group.length <=0 || group.location >= self.length){
            [matchStrArr addObject:@""];
            continue;
        }
        [matchStrArr addObject:[self substringWithRange:group]];
    }
    return matchStrArr;
}

//把匹配正则的都替换掉
- (NSString *)replaceAllMatch:(NSRegularExpression *)regex with:(NSString *)replacement {
    return [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

//把匹配origin的都替换掉
- (NSString *)replaceAllString:(NSString *)origin with:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:origin withString:replacement];
}

- (NSString *)replace:(NSRegularExpression *)rx with:(NSString *)replacement {
    return [rx stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:replacement];
}

- (NSArray *)split:(NSRegularExpression *)rx {
    return [rx split:self];
}

@end

@implementation NSRegularExpression (ext)

- (NSArray *)split:(NSString *)str {
    NSRange range = NSMakeRange(0, str.length);

    //get locations of matches
    NSMutableArray *matchingRanges = [NSMutableArray array];
    NSArray *matches = [self matchesInString:str options:0 range:range];
    for (NSTextCheckingResult *match in matches) {
        [matchingRanges addObject:[NSValue valueWithRange:match.range]];
    }

    //invert ranges - get ranges of non-matched pieces
    NSMutableArray *pieceRanges = [NSMutableArray array];

    //add first range
    [pieceRanges addObject:[NSValue valueWithRange:NSMakeRange(0,
            (matchingRanges.count == 0 ? str.length : [matchingRanges[0] rangeValue].location))]];

    //add between splits ranges and last range
    for (int i = 0; i < matchingRanges.count; i++) {
        BOOL isLast = i + 1 == matchingRanges.count;
        unsigned long startLoc = [matchingRanges[i] rangeValue].location + [matchingRanges[i] rangeValue].length;
        unsigned long endLoc = isLast ? str.length : [matchingRanges[i + 1] rangeValue].location;
        [pieceRanges addObject:[NSValue valueWithRange:NSMakeRange(startLoc, endLoc - startLoc)]];
    }

    //use split ranges to select pieces
    NSMutableArray *pieces = [NSMutableArray array];
    for (NSValue *val in pieceRanges) {
        NSString *piece = [str substringWithRange:[val rangeValue]];
        [pieces addObject:piece];
    }

    return pieces;
}

@end
*/
