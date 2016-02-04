//  ABPMatcher.h
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//


#import <Foundation/Foundation.h>

@class ABPFilter;
@class RegExpFilter;


@interface ABPMatcher : NSObject

//@property(nonatomic, strong) NSMutableDictionary <NSString *, ABPFilter *> *easyListLilters;

//Lookup table for easyListLilters by their associated keyword
@property(nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<ABPFilter *> *> *filterByKeyword;

//Lookup table for keywords by the filter text
@property(nonatomic, strong) NSMutableDictionary<NSString*,NSString*> *keywordByFilter;


+ (ABPMatcher *)sharedInstance;

#pragma mark - 解析adb规则


//解析EasyList拦截规则
//-(NSMutableDictionary <NSString *,ABPFilter *> *)parseLinesToFilters;
-(void)parseFiltersWithLines:(NSArray *)lines;

//把一行text解析成一个filter
-(ABPFilter *)parseFilter:(NSString *)line;

//从规则文件解析adb拦截规则
- (NSArray *)adBRuleLines;
//从规则文件解析Ex拦截规则
- (NSArray *)exRuleLines;
//从规则文件解析白名单规则
- (NSArray *)whiteListLines;


//获得EasyList字符串数据
- (NSArray *)easyListLines;

#pragma mark - Matcher相关操作

- (void)clear;
- (void)add:(RegExpFilter *)filter;
- (void)remove:(ABPFilter *)filter;
- (NSString *)findKeyword:(ABPFilter *)filter;
- (BOOL)hasFilter:(ABPFilter *)filter;
- (NSString *)getKeywordForFilter:(ABPFilter *)filter;

/**
 * Tests whether the URL matches any of the known easyListLilters
 * @param {String} location URL to be tested
 * @param {String} typeMask bitmask of content / request types to match
 * @param {String} docDomain domain name of the document that loads the URL
 * @param {Boolean} thirdParty should be true if the URL is a third-party request
 * @param {String} sitekey public key provided by the document
 * @param {Boolean} specificOnly should be true if generic matches should be ignored
 * @return {RegExpFilter} matching filter or null
 */
-(ABPFilter *)matchesAny:(NSString *)location typeMask:(NSString *)typeMask docDomain:(NSString *)docDomain
              thirdParty:(BOOL)thirdParty sitekey:(NSString *)sitekey specificOnly:(BOOL)specificOnly;

@end



@interface CombinedMatcher : NSObject


@property(nonatomic, strong) ABPMatcher *blacklist;
@property(nonatomic, strong) ABPMatcher *whitelist;
@property(nonatomic, strong) NSMutableDictionary *resultCache;
@property(nonatomic) int cacheEntries;


+ (CombinedMatcher *)sharedInstance;

- (void)clear;
- (void)add:(ABPFilter *)filter;
- (void)remove:(ABPFilter *)filter;
- (void)findKeyword:(ABPFilter *)filter;
- (BOOL)hasFilter:(ABPFilter *)filter;
- (NSString *)getKeywordForFilter:(ABPFilter *)filter;
- (BOOL)isSlowFilter:(ABPFilter *)filter;

- (ABPFilter *)matchesAny:(NSString *)location typeMask:(NSString *)typeMask docDomain:(NSString *)docDomain
               thirdParty:(BOOL)thirdParty sitekey:(NSString *)sitekey specificOnly:(BOOL)specificOnly;

@end



