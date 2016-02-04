//  ABPMatcher.m
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//

#import "ABPMatcher.h"
#import "ABPFilter.h"
#import "ABPDefines.h"
#import "ABPCategroys.h"
#import "RegExCategories.h"

#pragma mark -


@implementation ABPMatcher {

}

+ (ABPMatcher *)sharedInstance {
    static ABPMatcher *shareInstance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        shareInstance = [[ABPMatcher alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.filterByKeyword = @{}.mutableCopy;
        self.keywordByFilter = @{}.mutableCopy;

        //解析原生的EasyListFilters
//        [self parseFiltersWithLines:[self easyListLines]];

        //todo: 待缺少
        //[[RCInterface sharedInstance] apiAdDefendWithDelegate:self
//                                                 successBlock:^(NSDictionary *resultSource) {}
//                                                    failBlock:^(NSString *error) {}];
        //解析自定义的EasyListFilters
        [self parseFiltersWithLines:[self adBRuleLines]];
        //解析自定义的白名单
        [self parseFiltersWithLines:[self whiteListLines]];
        //解析自定义的例外规则
        [self parseFiltersWithLines:[self exRuleLines]];


    }

    return self;
}

#pragma mark - 解析adb规则


//从规则文件解析adb拦截规则
- (NSArray *)adBRuleLines {
    //todo: 待缺少
//    NSCharacterSet *newlineCharSet = [NSCharacterSet newlineCharacterSet];
//    NSString *fileContents = [RCDocumentUtil getAdDefend:@"abp_rule"];
//    return [fileContents componentsSeparatedByCharactersInSet:newlineCharSet];
    return nil;
}


//从规则文件解析Ex拦截规则
- (NSArray *)exRuleLines {
    //todo: 待缺少
//    NSCharacterSet *newlineCharSet = [NSCharacterSet newlineCharacterSet];
//    NSString *fileContents = [RCDocumentUtil getAdDefend:@"ex_rule"];
//    return [fileContents componentsSeparatedByCharactersInSet:newlineCharSet];
    return nil;
}

//从规则文件解析白名单规则
- (NSArray *)whiteListLines {
    //todo: 待缺少
//    NSCharacterSet *newlineCharSet = [NSCharacterSet newlineCharacterSet];
//    NSString *fileContents = [RCDocumentUtil getAdDefend:@"white_list"];
//    return [fileContents componentsSeparatedByCharactersInSet:newlineCharSet];
    return nil;
}


//获得EasyList字符串数据
- (NSArray *)easyListLines {
    NSError *error;
    //从文件/网络中读取EasyList规则
    NSString *fileContents = [NSString readStringFromFile:EasyList_FileName];
    if (!fileContents) {
        fileContents = [NSString stringWithContentsOfURL:[NSURL URLWithString:EasyList_Url]
                                                encoding:NSUTF8StringEncoding error:&error];
        if (fileContents) {
            [NSString writeString:fileContents ToFile:EasyList_FileName];
        }
    }
    NSArray *allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return allLinedStrings;
}

//解析拦截规则
//-(NSMutableDictionary <NSString *,ABPFilter *> *)parseLinesToFilters {
- (void)parseFiltersWithLines:(NSArray *)lines {

    //解析
    for (NSString *line in lines) {
//        NSLog(@"%@", line);
        ABPFilter *filter = [self parseFilter:line];

        if (filter && filter.text /*&& !_easyListLilters[filter.text]*/) {
            //_easyListLilters[filter.text] = filter;

            //添加filter
            if ([filter isKindOfClass:[RegExpFilter class]]) {
                [self add:(RegExpFilter *) filter];
            }

        }
    }
}


//把一行text解析成一个filter
- (ABPFilter *)parseFilter:(NSString *)line {
    ABPFilter *filter = nil;
    line = [ABPFilter normalize:line];
    if (line && ![line isEqualToString:@""]) {
        if ([line characterAtIndex:0] == '[') {
            NSLog(@"======== unexpected filter list header");
            return nil;
        }
        filter = [ABPFilter fromText:line];

        if ([filter isKindOfClass:[InvalidFilter class]]) {
            NSLog(@"======== invalid filter");
            return nil;
        }
        if ([filter isKindOfClass:[ElemHideBase class]] && ![self isValidCSSSelector:((ElemHideBase *) filter).selecter]) {
//            NSLog(@"======== css selector");
//            NSLog(@"======== invalid css selector");
            return nil;
        }
    }
    return filter;
}

//检查CSS Selector规则是符合法
- (BOOL)isValidCSSSelector:(NSString *)selecter {
    //todo:检查CSS Selecter是否合法

    return NO;
}


#pragma mark - Matcher相关操作

- (void)clear {
    [_filterByKeyword removeAllObjects];
    [_keywordByFilter removeAllObjects];
}


- (void)add:(RegExpFilter *)filter {
    if (_keywordByFilter[filter.text]) {
        return;
    }

    //Look for a suitable keyword
    NSString *keyword = [self findKeyword:filter];
    NSMutableArray<ABPFilter *> *oldEntry = _filterByKeyword[keyword];
    if (!oldEntry || oldEntry.count <= 0) {
        _filterByKeyword[keyword] = @[filter].mutableCopy;
    }
//    else if(oldEntry.count == 1){
//        [oldEntry addObject:filter];
//        _filterByKeyword[keyword] = oldEntry;
//    }
    else {
        [oldEntry addObject:filter];
        _filterByKeyword[keyword] = oldEntry;
        _keywordByFilter[filter.text] = keyword;
    }

}


- (void)remove:(ABPFilter *)filter {
    if (!_keywordByFilter[filter.text]) {
        return;
    }
    NSString *keyword = _keywordByFilter[filter.text];
    NSMutableArray<ABPFilter *> *list = _filterByKeyword[keyword];
    if (list.count <= 1) {
        [_filterByKeyword removeObjectForKey:keyword];
    } else {
        [list removeLastObject];
    }
}


- (NSString *)findKeyword:(ABPFilter *)filter {
    NSString *result = @"";
    NSString *text = filter.text;
//    if ([text matchPattern:RegexpRegExp].range.length > 0) {
    if ([text isMatch:RX(RegexpRegExp)]) {
        return result;
    }

    // Remove options
//    NSArray<NSTextCheckingResult *> *execResult = [text execPattern:OptionsRegExp];
//    if (execResult && execResult.count > 1) {
//        text = [text substringWithRange:execResult[0].range];
////        text = [text substringWithRange:[text matchPattern:OptionsRegExp].range];
//    }
    text = [text isEqualToString:@""] ? @"" : [text componentsSeparatedByString:@"$"][0];

    // Remove whitelist marker
    if ([[text substringToIndex:2] isEqualToString:@"@@"]) {
        text = [text substringFromIndex:2];
    }

    NSString *pattern = @"[^a-z0-9%*][a-z0-9%]{3,}(?=[^a-z0-9%*])";
//    NSArray<NSTextCheckingResult *> *matches = [text.lowercaseString execPattern:pattern];
    NSArray<NSString *> *matches = [text.lowercaseString matches:RX(pattern)];
    if (!matches || matches.count <= 0) {
        return result;
    }

    NSUInteger resultLength = 0;
    NSUInteger resultCount = 0xFFFFFF;

    for (NSString *matchText in matches) {
        if ([matchText isEqualToString:@""]) {
            continue;
        }

        NSString *candidate = [matchText substringFromIndex:1];
        NSUInteger count = _filterByKeyword[candidate] != nil ? _filterByKeyword[candidate].count : 0;
        if (count < resultCount || (count == resultCount && candidate.length) > resultLength) {
            result = candidate;
            resultCount = count;
            resultLength = candidate.length;
        }
    }

    return result;
}

- (BOOL)hasFilter:(ABPFilter *)filter {
    return _keywordByFilter[filter.text] != nil;
}

- (NSString *)getKeywordForFilter:(ABPFilter *)filter {
    return _keywordByFilter[filter.text] ?: nil;
}

- (ABPFilter *)_checkEntryMatch:(NSString *)keyword location:(NSString *)location typeMask:(NSString *)typeMask
                      docDomain:(NSString *)docDomain thirdParty:(BOOL)thirdParty sitekey:(NSString *)sitekey specificOnly:(BOOL)specificOnly {
    NSMutableArray<ABPFilter *> *list = _filterByKeyword[keyword];
    for (RegExpFilter *filter in list) {
        if (specificOnly && filter.isGeneric && ![filter isKindOfClass:[WhitelistFilter class]]) {
//        if (filter.isGeneric && ![filter isKindOfClass:[WhitelistFilter class]]) {
            continue;
        }

        BOOL isMatch = [filter matches:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty sitekey:sitekey];
        if ([filter isKindOfClass:[RegExpFilter class]] && isMatch)
            return filter;
    }
    return nil;
}

/**
 * Tests whether the URL matches any of the known easyListFilters
 * @param {String} location URL to be tested
 * @param {String} typeMask bitmask of content / request types to match
 * @param {String} docDomain domain name of the document that loads the URL
 * @param {Boolean} thirdParty should be true if the URL is a third-party request
 * @param {String} sitekey public key provided by the document
 * @param {Boolean} specificOnly should be true if generic matches should be ignored
 * @return {RegExpFilter} matching filter or null
 */
- (ABPFilter *)matchesAny:(NSString *)location typeMask:(NSString *)typeMask docDomain:(NSString *)docDomain
               thirdParty:(BOOL)thirdParty sitekey:(NSString *)sitekey specificOnly:(BOOL)specificOnly {
    NSString *pattern = @"[a-z0-9%]{3,}";

    NSArray<NSString *> *matches = [location.lowercaseString matches:RX(pattern)];

    for (NSString *matchText in matches) {

        if (_filterByKeyword[matchText]) {
            ABPFilter *result = [self _checkEntryMatch:matchText location:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty
                                               sitekey:sitekey specificOnly:specificOnly];
            if (result){
                return result;
            }
            
        }

    }

    //处理没有匹配项目,keyword为空的情况下
    NSString *str = @"";
    if (!matches && _filterByKeyword[str]) {
        ABPFilter *result = [self _checkEntryMatch:str location:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty
                                           sitekey:sitekey specificOnly:specificOnly];
        if (result)
            return result;
    }

    return nil;
}

@end


#pragma mark -

static int const maxCacheEntries = 1000;

@implementation CombinedMatcher {

}

+ (CombinedMatcher *)sharedInstance {
    static CombinedMatcher *shareInstance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        shareInstance = [[CombinedMatcher alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.blacklist = [[ABPMatcher alloc] init];
        self.whitelist = [[ABPMatcher alloc] init];
        self.resultCache = @{}.mutableCopy;
        self.cacheEntries = 0;
    }

    return self;
}

- (void)clear {
    [_blacklist clear];
    [_whitelist clear];
    [_resultCache removeAllObjects];
    _cacheEntries = 0;
}

- (void)add:(ABPFilter *)filter {
    if ([filter isKindOfClass:[WhitelistFilter class]]) {
        [_whitelist add:(WhitelistFilter *) filter];
    } else {
        [_blacklist add:(BlockingFilter *) filter];
    }

    if (_cacheEntries > 0) {
        [_resultCache removeAllObjects];
        _cacheEntries = 0;
    }
}

- (void)remove:(ABPFilter *)filter {
    if ([filter isKindOfClass:[WhitelistFilter class]]) {
        [_whitelist remove:(WhitelistFilter *) filter];
    } else {
        [_blacklist remove:(BlockingFilter *) filter];
    }

    if (_cacheEntries > 0) {
        [_resultCache removeAllObjects];
        _cacheEntries = 0;
    }
}

- (void)findKeyword:(ABPFilter *)filter {
    if ([filter isKindOfClass:[WhitelistFilter class]]) {
        [_whitelist findKeyword:(WhitelistFilter *) filter];
    } else {
        [_blacklist findKeyword:(BlockingFilter *) filter];
    }
}

- (BOOL)hasFilter:(ABPFilter *)filter {
    if ([filter isKindOfClass:[WhitelistFilter class]]) {
        return [_whitelist hasFilter:(WhitelistFilter *) filter];
    } else {
        return [_blacklist hasFilter:(BlockingFilter *) filter];
    }
}

- (NSString *)getKeywordForFilter:(ABPFilter *)filter {
    if ([filter isKindOfClass:[WhitelistFilter class]]) {
        return [_whitelist getKeywordForFilter:(WhitelistFilter *) filter];
    } else {
        return [_blacklist getKeywordForFilter:(BlockingFilter *) filter];
    }
}

- (BOOL)isSlowFilter:(ABPFilter *)filter {
    ABPMatcher *matcher = [filter isKindOfClass:[WhitelistFilter class]] ? _whitelist : _blacklist;
    if ([matcher hasFilter:filter]) {
        return ![matcher getKeywordForFilter:filter];
    } else {
        return ![matcher findKeyword:filter];
    }
}

- (ABPFilter *)matchesAnyInternal:(NSString *)location typeMask:(NSString *)typeMask docDomain:(NSString *)docDomain
                       thirdParty:(BOOL)thirdParty sitekey:(NSString *)sitekey specificOnly:(BOOL)specificOnly {
    NSString *pattern = @"[a-z0-9%]{3,}";
//    NSArray<NSTextCheckingResult *> *matches = [location.lowercaseString execPattern:pattern];
    NSArray<NSString *> *matches = [location.lowercaseString matches:RX(pattern)];

    ABPFilter *blacklistHit = nil;
    for (NSString *matchText in matches) {

        if (_whitelist.filterByKeyword[matchText]) {
            ABPFilter *result = [_whitelist _checkEntryMatch:matchText location:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty sitekey:sitekey specificOnly:specificOnly];
            if (result)
                return result;
        }
        if (_blacklist.filterByKeyword[matchText] && blacklistHit == nil) {
            blacklistHit = [_blacklist _checkEntryMatch:matchText location:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty sitekey:sitekey specificOnly:specificOnly];
        }
    }

    //处理没有匹配项目,keyword为空的情况下
    NSString *str = @"";
    if (!matches) {
        if (_whitelist.filterByKeyword[str]) {
            ABPFilter *result = [_whitelist _checkEntryMatch:str location:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty sitekey:sitekey specificOnly:specificOnly];
            if (result)
                return result;
        }
        if (_blacklist.filterByKeyword[str] && blacklistHit == nil) {
            blacklistHit = [_blacklist _checkEntryMatch:str location:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty sitekey:sitekey specificOnly:specificOnly];
        }

    }

    return blacklistHit;;
}

- (ABPFilter *)matchesAny:(NSString *)location typeMask:(NSString *)typeMask docDomain:(NSString *)docDomain
               thirdParty:(BOOL)thirdParty sitekey:(NSString *)sitekey specificOnly:(BOOL)specificOnly {
    NSString *key = [NSString stringWithFormat:@"%@ %@ %@ %i %@ %i", location, typeMask, docDomain, thirdParty, sitekey, specificOnly];
    if (_resultCache[key])
        return _resultCache[key];
    ABPFilter *result = [self matchesAnyInternal:location typeMask:typeMask docDomain:docDomain thirdParty:thirdParty sitekey:sitekey specificOnly:specificOnly];
    if (_cacheEntries >= maxCacheEntries) {
        [_resultCache removeAllObjects];
        _cacheEntries = 0;
    }
    _resultCache[key] = result;
    _cacheEntries++;

    return result;
}


@end