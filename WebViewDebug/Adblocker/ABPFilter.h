//  ABPFilter.h
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark -

static NSString *const ElemhideRegExp = @"^([^\\/\\*\\|\\@\"!]*?)#(\\@)?(?:([\\w\\-]+|\\*)((?:\\([\\w\\-]+(?:[$^*]?=[^\\(\\)\"]*)?\\))*)|#([^{}]+))$";
static NSString *const RegexpRegExp = @"^(@@)?\\/.*\\/(?:\\$~?[\\w\\-]+(?:=[^,\\s]+)?(?:,~?[\\w\\-]+(?:=[^,\\s]+)?)*)?$";
static NSString *const OptionsRegExp = @"\\$(~?[\\w\\-]+(?:=[^,\\s]+)?(?:,~?[\\w\\-]+(?:=[^,\\s]+)?)*)$";
static NSString *const CsspropertyRegExp = @"\\[\\-abp\\-properties=([\"'])([^\"']+)\\1\\]";


@interface ABPFilter : NSObject {

}
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) NSMutableArray *subscriptions;

//从text初始化
- (instancetype)initWithText:(NSString *)text;

//从text得到一个filter
+ (ABPFilter *)fromText:(NSString *)text;

//从一个字典得到Filter
+(ABPFilter *)fromObject:(NSDictionary<NSString *,NSString *> *)dict;

//把text标准化,删除没用的空格
+(NSString *)normalize:(NSString *)text;

//把filter text转换成正则表达式字符串
+(NSString *)toRegExp:(NSString *)text;

@end


#pragma mark - 注释的Filter

@interface CommentFilter : ABPFilter
@end

#pragma mark - 失效的Filter

@interface InvalidFilter : ABPFilter
@property(nonatomic) NSString *reason;

- (instancetype)initWithText:(NSString *)text reason:(NSString *)reason;
@end

#pragma mark - 有效的Filter

//抽象类
@interface ActiveFilter : ABPFilter {
@public
    BOOL _disabled;
    int _hitCount;
    double _lastHit;
    NSMutableDictionary<NSString *,NSNumber *> *_domains;
    NSRegularExpression *_regexp;
    NSMutableArray<NSString *> *_sitekeys;
}
@property(nonatomic, copy) NSString *domainSource;
@property(nonatomic, copy) NSString *domainSeparator;
@property(nonatomic) BOOL ignoreTrailingDot;
@property(nonatomic) BOOL domainSourceIsUpperCase;
//@property(nonatomic, strong) NSMutableArray<NSString *> *sitekeys;


- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains;
-(BOOL)disabled;
-(BOOL)setDisabled:(BOOL)value;
-(int)hitCount;
-(int)setHitCount:(BOOL)value;
-(double)lastHit;
-(double)setLastHit:(BOOL)value;
//取domains,返回以domain为key(NSString),include值为value(BOOL)
-(NSDictionary<NSString *,NSNumber *> *)domains;

- (BOOL)isActiveOnDomain:(NSString *)docDomain sitekey:(NSString *)sitekey;

//Checks whether this filter is active only on a domain and its subdomains.
- (BOOL)isActiveOnlyDomain:(NSString *)docDomain;

- (BOOL)isGeneric;

@end


static NSInteger ContentTypeCnst = 0x7FFFFFFF;
//正则的Filter
@interface RegExpFilter : ActiveFilter{
//    NSMutableArray<NSString *> *_sitekeys;
}
@property(nonatomic) BOOL matchCase;
@property(nonatomic, copy) NSString *sitekeySource;

@property(nonatomic) BOOL thirdParty;

@property(nonatomic) int length;

@property(nonatomic, copy) NSString *regexpSource;


@property(nonatomic) NSInteger contentType;

//得到typeMap
+(NSDictionary<NSString *,NSNumber *> *)typeMap;

- (instancetype)initWithText:(NSString *)text regexpSource:(NSString *)regexpSource contentType:(NSInteger)contentType
                   matchCase:(BOOL)matchCase domains:(NSString *)domains thirdParty:(BOOL)thirdParty sitekeys:(NSString *)sitekeys;

- (BOOL)matches:(NSString *)location typeMask:(NSString *)mask docDomain:(NSString *)domain thirdParty:(BOOL)party sitekey:(NSString *)sitekey;

-(NSString *)regexString:(NSString *)text;
//Regular expression to be used when testing against this filter
- (NSRegularExpression *)regexp;
//Array containing public keys of websites that this filter should apply to
- (NSMutableArray *)sitekeys;
- (void)setSitekeys:(NSMutableArray *)sitekeys;

@end

//要被拦截的Filter
@interface BlockingFilter : RegExpFilter
@property(nonatomic) BOOL collapse;

- (instancetype)initWithText:(NSString *)text regexpSource:(NSString *)regexpSource contentType:(NSInteger)contentType matchCase:(BOOL)matchCase
                     domains:(NSString *)domains thirdParty:(BOOL)thirdParty sitekeys:(NSString *)sitekeys collapse:(BOOL)collapse;

@end

//白名单的Filter
@interface WhitelistFilter : RegExpFilter

@end


#pragma mark - 元素隐藏Filter

//抽象类
@interface ElemHideBase : ActiveFilter
@property(nonatomic, copy) NSString *selectorDomain;
@property(nonatomic, copy) NSString *selecter;

- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains selecter:(NSString *)selecter;

+ (ABPFilter *)fromText:(NSString *)text domain:(NSString *)domain isException:(BOOL)exception tagName:(NSString *)name attrRules:(NSString *)rules selecter:(NSString *)selecter;
@end


@interface ElemHideFilter : ElemHideBase
@end


@interface CSSPropertyFilter : ElemHideBase{
    NSString *_regexpString;
}

@property(nonatomic, copy) NSString *regexpSource;

@property(nonatomic, copy) NSString *selectorPrefix;

@property(nonatomic, copy) NSString *selectorSuffix;

- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains selecter:(NSString *)selecter
                regexpSource:(NSString *)regexpSource
              selectorPrefix:(NSString *)selectorPrefix
              selectorSuffix:(NSString *)selectorSuffix;

-(NSString *)regexpString;

@end


@interface ElemHideException : ElemHideBase

@end