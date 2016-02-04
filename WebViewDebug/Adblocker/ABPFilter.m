//  ABPFilter.m
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//

#import "ABPFilter.h"
#import "ABPDefines.h"
#import "ABPCategroys.h"
#import "RegExCategories.h"

#pragma mark -

static NSMutableDictionary *KnownFilters;

@interface ABPFilter ()


@end

@implementation ABPFilter {

}

//从text初始化
- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.text = text;
        self.subscriptions = @[].mutableCopy;
        KnownFilters = KnownFilters ?: @{}.mutableCopy;
    }
    
    return self;
}

//从text得到一个filter
+ (ABPFilter *)fromText:(NSString *)text {
    if (!KnownFilters) {
        KnownFilters = @{}.mutableCopy;
    }
    if (KnownFilters[text]) {
        return KnownFilters[text];
    }

    ABPFilter *ret = nil;
//    NSTextCheckingResult *match = [text indexOfString:@"#"] >= 0 ? [text matchPattern:ElemhideRegExp] : nil;
//    //隐藏标签
//    if (match && match.numberOfRanges >= 6) {
//        NSArray<NSString *> *matchArr = [text matchGroupRex:match];
    RxMatch *match = [text indexOfString:@"#"] >= 0 ? [text firstMatchWithDetails:RX(ElemhideRegExp)] : nil;
    if(match && match.groups.count >= 6){
        NSArray<RxMatchGroup *> *matchArr = match.groups;

        NSString *domain = matchArr[1].value;
        BOOL isException = matchArr[2].value && ![matchArr[2].value isEqualToString:@""] ? matchArr[2].value.boolValue : NO;
        NSString *tagName = matchArr[3].value;
        NSString *attrRules = matchArr[4].value;
        NSString *selecter = matchArr[5].value;
        ret = [ElemHideBase fromText:text domain:domain isException:isException tagName:tagName attrRules:attrRules selecter:selecter];

    } else if ([text characterAtIndex:0] == '!') {
        ret = [[CommentFilter alloc] initWithText:text];
    } else {
        ret = [RegExpFilter fromText:text];
    }

    return ret;
}

//从一个字典得到Filter
+ (ABPFilter *)fromObject:(NSDictionary<NSString *, NSString *> *)dict {
    ABPFilter *ret = [ABPFilter fromText:dict[@"text"]];
    if ([ret isKindOfClass:[ActiveFilter class]]) {
        ActiveFilter *activeFilter = (ActiveFilter *) ret;
        if (dict[@"disabled"]) {
            activeFilter->_disabled = [dict[@"disabled"] isEqualToString:@"YES"];
        }
        if (dict[@"hitCount"]) {
            activeFilter->_hitCount = dict[@"hitCount"].intValue;
        }
        if (dict[@"lastHit"]) {
            activeFilter->_lastHit = dict[@"lastHit"].doubleValue;
        }
    }
    return ret;
}

//把text标准化,删除没用的空格
+ (NSString *)normalize:(NSString *)text {
    if (!text) {
        return text;
    }

    text = [text replace:RX(@"[^\\S ]") with:@""];


    if ([text isMatch:RX(@"^\\s*!")]) {
        return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    } else if ([text isMatch:RX(ElemhideRegExp)]) {
//        NSTextCheckingResult *match = [text matchPattern:@"^(.*?)(#\\@?#?)(.*)$"];
        RxMatch *match = [text firstMatchWithDetails:RX(@"^(.*?)(#\\@?#?)(.*)$")];
        if (match && match.groups.count >= 4 /*&& match.numberOfRanges >= 4*/) {
//            NSArray<NSString *> *matchArr = [text matchGroupRex:match];
            NSArray<RxMatchGroup *> *matchArr = match.groups;
            NSString *domain = matchArr[1].value;
            NSString *separator = matchArr[2].value;
            NSString *selecter = matchArr[3].value;

            return [NSString stringWithFormat:@"%@%@%@", [domain replace:RX(@"\\s") with:@""], separator,
                                              [selecter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        } else {
            return nil;
        }

    } else {
        return [text replace:RX(@"\\s") with:@""];
    }
}

//把filter text转换成正则表达式字符串
+ (NSString *)toRegExp:(NSString *)text {
    //http://blog.csdn.net/goodshot/article/details/7948265
    text = [text replace:RX(@"\\u002A+") with:@"*"]; // remove multiple wildcards
    text = [text replace:RX(@"\\u005E\\u007C$") with:@"^"]; // remove anchors following separator placeholder
    text = [text replace:RX(@"\\W") withDetailsBlock:^NSString *(RxMatch *match) {
        return [NSString stringWithFormat:@"\\%@",match.value];// escape special symbols
    }];
    text = [text replace:RX(@"\\u005C\\u002A") with:@".*"];// replace wildcards by .*
    text = [text replace:RX(@"\\u005C\\u005E") with:@"(?:[\\\\x00-\\\\x24\\\\x26-\\\\x2C\\\\x2F\\\\x3A-\\\\x40\\\\x5B-\\\\x5E\\\\x60\\\\x7B-\\\\x7F]|$)"];// process separator placeholders (all ANSI characters but alphanumeric characters and _%.-)
    text = [text replace:RX(@"^\\u005C\\u007C\\u005C\\u007C") with:@"^[\\\\w\\\\-]+:\\\\/+(?!\\\\/)(?:[^\\\\/]+\\\\.)?"];// process extended anchor at expression start
    text = [text replace:RX(@"\\u005C\\u007C") with:@"^"];// process anchor at expression start
    text = [text replace:RX(@"\\u005C\\u007C$") with:@"$"];// process anchor at expression end
    text = [text replace:RX(@"^(\\u002E\\u002A)") with:@""];// remove leading wildcards
    text = [text replace:RX(@"(\\u002E\\u002A)$") with:@""];// remove trailing wildcards

    return text;

}

@end


#pragma mark - 注释的Filter

@implementation CommentFilter {

}
- (instancetype)initWithText:(NSString *)text {
    self = [super initWithText:text];
    if (self) {
        self.text = text;
        self.type = @"comment";
    }
    
    return self;
}


@end

#pragma mark - 失效的Filter

@implementation InvalidFilter {

}

- (instancetype)initWithText:(NSString *)text reason:(NSString *)reason {
    self = [super initWithText:text];
    if (self) {
        self.text = text;
        self.type = @"invalid";
        self.reason = reason;
        
    }
    
    return self;
}


@end

#pragma mark - 有效的Filter

@implementation ActiveFilter {

}
- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains {
    self = [super initWithText:text];
    if (self) {

        self.domainSource = domains;
        self.domainSeparator = @"|";
        self.ignoreTrailingDot = YES;
        self.domainSourceIsUpperCase = NO;
        _sitekeys = @[].mutableCopy;
    }

    return self;
}

- (BOOL)disabled {
    return _disabled;
}

- (BOOL)setDisabled:(BOOL)value {
    if (_disabled != value) {
        BOOL oldValue = _disabled;
        _disabled = value;
        //todo: triggerListeners
    }
    return _disabled;
}

- (int)hitCount {
    return _hitCount;
}

- (int)setHitCount:(BOOL)value {
    if (_hitCount != value) {
        int oldValue = _hitCount;
        _hitCount = value;
        //todo: triggerListeners
    }
    return _hitCount;
}

- (double)lastHit {
    return _lastHit;
}

- (double)setLastHit:(BOOL)value {
    if (_lastHit != value) {
        double oldValue = _lastHit;
        _lastHit = value;
        //todo: triggerListeners
    }
    return _lastHit;
}

//取domains,返回以domain为key(NSString),include值为value(BOOL)
- (NSDictionary<NSString *, NSNumber *> *)domains {
    if (_domains) {
        return _domains;
    }
    if (self.domainSource) {
        NSString *source = self.domainSource;
        if (!_domainSourceIsUpperCase) {
            // RegExpFilter already have uppercase domains
            source = [source uppercaseString];
        }

        NSMutableArray <NSString *> *list = [source componentsSeparatedByString:_domainSeparator].mutableCopy;
        if (list.count == 1 && ([list[0] isEqualToString:@""] || (list[0].length > 0 && [list[0] characterAtIndex:0] != '~') )) {
            // Fast track for the common one-domain scenario
            _domains = @{@"" : @(NO)}.mutableCopy;
            if (_ignoreTrailingDot) {
                list[0] = [list[0] replace:RX(@"\\.+$") with:@""];
            }
            _domains[list[0]] = @(YES);

        } else {
            BOOL hasIncludes = NO;
            for (NSUInteger i = 0; i < list.count; i++) {
                NSString *domain = list[i];
                if (_ignoreTrailingDot) {
                    domain = [domain replace:RX(@"\\.+$") with:@""];
                }
                if ([domain isEqualToString:@""]) {
                    continue;
                }

                BOOL include;
                if ([domain characterAtIndex:0] == '~') {
                    include = NO;
                    domain = [domain substringFromIndex:1];
                } else {
                    include = YES;
                    hasIncludes = YES;
                }

                if (!_domains) {
                    _domains = @{}.mutableCopy;
                }
                _domains[domain] = @(include);
            }
            _domains[@""] = @(!hasIncludes);
        }
        self.domainSource = nil;

    }
    return _domains;
}

/**
 * Checks whether this filter is active on a domain.
 * @param {String} docDomain domain name of the document that loads the URL
 * @param {String} [sitekey] public key provided by the document
 * @return {Boolean} true in case of the filter being active
 */
- (BOOL)isActiveOnDomain:(NSString *)docDomain sitekey:(NSString *)sitekey {
    // Sitekeys are case-sensitive so we shouldn't convert them to upper-case to avoid false
    // positives here. Instead we need to change the way filter options are parsed.
    if (_sitekeys && _sitekeys.count > 0 && (!sitekey || [_sitekeys containsObject:sitekey.uppercaseString])) {
        return NO;
    }

    // If no domains are set the rule matches everywhere
    if (!self.domains) {
        return YES;
    }

    // If the document has no host name, match only if the filter isn't restricted to specific domains
    if (!docDomain) {
        return self.domains[@""].boolValue;
    }

    if (_ignoreTrailingDot) {
        docDomain = [docDomain replace:RX(@"\\.+$") with:@""];
    }

    docDomain = docDomain.uppercaseString;

    while (true) {
        if (self.domains[docDomain]) {
            return self.domains[docDomain].boolValue;
        }

        int nextDot = [docDomain indexOfString:@"."];
        if (nextDot < 0) {break;}
        docDomain = [docDomain substringFromIndex:(NSUInteger) (nextDot + 1)];
    }
    return self.domains[@""].boolValue;

}

//Checks whether this filter is active only on a domain and its subdomains.
- (BOOL)isActiveOnlyDomain:(NSString *)docDomain {
    if (!docDomain || !_domains || _domains[@""]) {
        return NO;
    }

    if (_ignoreTrailingDot) {
        docDomain = [docDomain replace:RX(@"") with:@""];
    }
    docDomain = docDomain.uppercaseString;

    for (NSString *domain in _domains) {
        if (_domains[domain] && domain != docDomain && (domain.length <= docDomain.length
                || [domain indexOfString:[NSString stringWithFormat:@".%@", docDomain]] != domain.length - docDomain.length - 1)) {
            return NO;
        }
    }
    return YES;
}

//Checks whether this filter is generic or specific
- (BOOL)isGeneric {
//    return !(_sitekeys && _sitekeys.count > 0) &&
//            (!_domains || _domains[@""]);
    return (!_domains || _domains[@""]);
}


@end

static NSDictionary<NSString *, NSNumber *> *typeMap;

//正则的Filter
@implementation RegExpFilter {

}

//得到typeMap
+ (NSDictionary<NSString *, NSNumber *> *)typeMap {
    return @{
            @"OTHER" : @(OTHER),
            @"SCRIPT" : @(SCRIPT),
            @"IMAGE" : @(IMAGE),
            @"STYLESHEET" : @(STYLESHEET),
            @"OBJECT" : @(OBJECT),
            @"SUBDOCUMENT" : @(SUBDOCUMENT),
            @"DOCUMENT" : @(DOCUMENT),
            @"XBL" : @(XBL),
            @"PING" : @(PING),
            @"XMLHTTPREQUEST" : @(XMLHTTPREQUEST),
            @"OBJECT_SUBREQUEST" : @(OBJECT_SUBREQUEST),
            @"DTD" : @(DTD),
            @"MEDIA" : @(MEDIA),
            @"FONT" : @(FONT),
            @"BACKGROUND" : @(BACKGROUND),
            @"POPUP" : @(POPUP),
            @"GENERICBLOCK" : @(GENERICBLOCK),
            @"ELEMHIDE" : @(ELEMHIDE),
            @"GENERICHIDE" : @(GENERICHIDE)
    };
}

- (instancetype)initWithText:(NSString *)text regexpSource:(NSString *)regexpSource contentType:(NSInteger)contentType
                   matchCase:(BOOL)matchCase domains:(NSString *)domains thirdParty:(BOOL)thirdParty sitekeys:(NSString *)sitekeys {
    self = [super initWithText:text domains:domains];

    if (self) {
        self.regexpSource = regexpSource;
        if (contentType != 0) {
            _contentType = contentType;
        } else {
            _contentType &= ~(DOCUMENT | ELEMHIDE | POPUP | GENERICHIDE | GENERICBLOCK);
        }

        if (matchCase)
            self.matchCase = matchCase;
        if (sitekeys)
            self.sitekeySource = sitekeys;
        self.thirdParty = thirdParty;
        self.length = 1;
        
        self.domainSourceIsUpperCase = YES;
        self.domainSeparator = @"|";
        self.matchCase = NO;
    }

    return self;
}

-(NSString *)regexString:(NSString *)text{
        return [ABPFilter toRegExp:text];
}

//Regular expression to be used when testing against this filter
- (NSRegularExpression *)regexp {
    if (_regexp) {
        return _regexp;
    }

    if(!self.regexpSource){
        return nil;
    }

    NSString *source = [ABPFilter toRegExp:self.regexpSource];
    _regexp = [NSRegularExpression regularExpressionWithPattern:source options:0 error:nil];
    if (!_matchCase) {    //对大小写不敏感
        _regexp = [NSRegularExpression regularExpressionWithPattern:source options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return _regexp;
}

//Array containing public keys of websites that this filter should apply to
- (NSMutableArray *)sitekeys {
    if (_sitekeys) {
        return _sitekeys;
    }

    if (_sitekeySource) {
        _sitekeys = [_sitekeySource componentsSeparatedByString:@"|"].mutableCopy;
        _sitekeySource = nil;
    }
    return _sitekeys;
}

- (void)setSitekeys:(NSMutableArray *)sitekeys {
    _sitekeys = sitekeys;
}

- (BOOL)matches:(NSString *)location typeMask:(NSString *)typeMask docDomain:(NSString *)docDomain thirdParty:(BOOL)thirdParty sitekey:(NSString *)sitekey {
    NSInteger typeMs = [RegExpFilter typeMap][typeMask] ? [RegExpFilter typeMap][typeMask].intValue : ContentTypeCnst;
    BOOL isActiveOnDomain = [self isActiveOnDomain:docDomain sitekey:sitekey];
    NSString *regexText = [ABPFilter toRegExp:self.regexpSource];
//    NSString *parrten = [regexText replaceAllString:@"?" with:@"\\?"];
//    NSTextCheckingResult *checkingResult = [location matchPattern:regexText];
//    NSRange range = checkingResult.range;
//    NSLog(@"====%d--%d",range.location,range.length);
//    if(isActiveOnDomain){
//        NSLog(@"========:%d",isActiveOnDomain);
//    }
    ///^[\w\-]+:\/+(?!\/)(?:[^\/]+\.)?pos\.baidu\.com(?:[\x00-\x24\x26-\x2C\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x7F]|$)/i
    NSRegularExpression *regExp = RX(regexText);
    BOOL isMatch = [location isMatch:regExp];
    return (self.contentType & typeMs) &&
            (!_thirdParty || _thirdParty == thirdParty) && isActiveOnDomain && isMatch;
    //checkingResult && checkingResult.range.length > 0;
}

//Creates a RegExp filter from its text representation
+ (ABPFilter *)fromText:(NSString *)text {
    BOOL blocking = YES;
    NSString *origText = text;
    if ([text indexOfString:@"@@"] == 0) {
        blocking = NO;
        text = [text substringFromIndex:2];
    }

    NSInteger contentType = ContentTypeCnst;
    BOOL matchCase = NO;
    NSString *domains = nil;
    NSString *sitekeys = nil;
    BOOL thirdParty = NO;
    BOOL collapse = NO;
    NSArray<NSString *> *options = nil;

//    NSTextCheckingResult *match = [text indexOfString:@"$"] >= 0 ? [text matchPattern:OptionsRegExp] : nil;
    RxMatch *match = [text indexOfString:@"$"] >= 0 ? [text firstMatchWithDetails:RX(OptionsRegExp)] : nil;
    if (match && match.groups.count >= 2 /*&& match.numberOfRanges >= 2*/) {
        //NSArray<NSString *> *matchArr = [text matchGroupRex:match];
        RxMatchGroup *group1 = match.groups[0];
        RxMatchGroup *group2 = match.groups[1];

        options = [group2.value.uppercaseString componentsSeparatedByString:@","];
        text = [text substringWithRange:NSMakeRange(0, match.range.location)];
//        text = match.value;
        for (NSUInteger i = 0; i < options.count; i++) {
            NSString *option = options[i];
            NSString *value = nil;

            NSInteger separatorIndex = [option indexOfString:@"="];
            if (separatorIndex >= 0) {
                value = [option substringFromIndex:(NSUInteger) (separatorIndex + 1)];
                option = [option substringWithRange:NSMakeRange(0, (NSUInteger) separatorIndex)];
            }

            option = [option replace:RX(@"-") with:@"_"];
            if ([RegExpFilter typeMap][option]) {
                contentType |= [RegExpFilter typeMap][option].intValue;
            } else if ([option characterAtIndex:0] == '~' && [RegExpFilter typeMap][[option substringFromIndex:1]]) {
                contentType &= ~[RegExpFilter typeMap][[option substringFromIndex:1]].intValue;
            }

            else if ([option isEqualToString:@"MATCH_CASE"])
                matchCase = YES;
            else if ([option isEqualToString:@"~MATCH_CASE"])
                matchCase = NO;
            else if ([option isEqualToString:@"DOMAIN"] && value)
                domains = value;
            else if ([option isEqualToString:@"THIRD_PARTY"])
                thirdParty = YES;
            else if ([option isEqualToString:@"~THIRD_PARTY"])
                thirdParty = NO;
            else if ([option isEqualToString:@"COLLAPSE"])
                collapse = YES;
            else if ([option isEqualToString:@"~COLLAPSE"])
                collapse = NO;
            else if ([option isEqualToString:@"SITEKEY"] && value)
                sitekeys = value;
            else
                return [[InvalidFilter alloc] initWithText:origText reason:[NSString stringWithFormat:@"Unknown option %@", option.lowercaseString]];
        }
    }

    @try {
        if (blocking) {
            return [[BlockingFilter alloc] initWithText:origText regexpSource:text contentType:contentType matchCase:matchCase domains:domains thirdParty:thirdParty sitekeys:sitekeys collapse:collapse];
        } else {
            return [[WhitelistFilter alloc] initWithText:origText regexpSource:text contentType:contentType matchCase:matchCase domains:domains thirdParty:thirdParty sitekeys:sitekeys];
        }
    }
    @catch (NSException *exception) {
        return [[InvalidFilter alloc] initWithText:origText reason:exception.reason];
        NSLog(@"Exception occurred: %@, %@", exception, [exception userInfo]);
    }

}

@end

//要被拦截的Filter
@implementation BlockingFilter {

}
- (instancetype)initWithText:(NSString *)text regexpSource:(NSString *)regexpSource contentType:(NSInteger)contentType matchCase:(BOOL)matchCase
                     domains:(NSString *)domains thirdParty:(BOOL)thirdParty sitekeys:(NSString *)sitekeys collapse:(BOOL)collapse {
    self = [super initWithText:text regexpSource:regexpSource contentType:contentType matchCase:matchCase domains:domains
                    thirdParty:thirdParty sitekeys:sitekeys];
    if (self) {
        self.type = @"blocking";
        self.collapse = collapse;
    }

    return self;
}


@end

//白名单的Filter
@implementation WhitelistFilter {

}
- (instancetype)initWithText:(NSString *)text regexpSource:(NSString *)regexpSource contentType:(NSInteger)contentType
                   matchCase:(BOOL)matchCase domains:(NSString *)domains thirdParty:(BOOL)thirdParty sitekeys:(NSString *)sitekeys {
    self = [super initWithText:text regexpSource:regexpSource contentType:contentType matchCase:matchCase domains:domains
                    thirdParty:thirdParty sitekeys:sitekeys];
    if (self) {
        self.type = @"whitelist";
    }

    return self;
}


@end


#pragma mark - 元素隐藏Filter

@implementation ElemHideBase {

}
- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains selecter:(NSString *)selecter {
    self = [super initWithText:text domains:domains];
    if (self) {
        if (domains) {
            self.selectorDomain = [[domains replace:RX(@",~[^,]+") with:@""] replace:RX(@"^~[^,]+,?") with:@""].lowercaseString;
        }
        self.selecter = selecter;

        self.domainSeparator = @",";
        self.ignoreTrailingDot = NO;

    }

    return self;
}

+ (ABPFilter *)fromText:(NSString *)text domain:(NSString *)domain isException:(BOOL)isException tagName:(NSString *)tagName
              attrRules:(NSString *)attrRules selecter:(NSString *)selecter {
    if(!selecter){
        if([tagName isEqualToString:@"*"]){
            tagName = @"";
        }

        NSString *rId = nil;
        NSString *additional = @"";
        if(attrRules){

//            NSArray<NSTextCheckingResult *> *matches = [attrRules execPattern:@"\\([\\w\\-]+(?:[$^*]?=[^\\(\\)\"]*)?\\)"];
//            for (NSTextCheckingResult *match in matches) {
//                NSString *matchText = [text substringWithRange:match.range];

            NSArray<NSString *> *matches = [attrRules matches:RX(@"\\([\\w\\-]+(?:[$^*]?=[^\\(\\)\"]*)?\\)")];
            for (NSString *matchText in matches) {
                NSString *rule = [matchText substringWithRange:NSMakeRange(1, matchText.length - 2)];
                NSUInteger separatorPos = (NSUInteger) [matchText indexOfString:@"="];
                if(separatorPos > 0){
                    rule = [NSString stringWithFormat:@"%@\"",[rule replace:RX(@"/=/") with:@"=\""]];
                    additional  = [NSString stringWithFormat:@"%@[%@]",additional,rule];
                }else{
                    if(rId){
                        return [[InvalidFilter alloc] initWithText:text reason:@"filter elemhide duplicate id"];
                    }
                    rId = rule;
                }
            }
        }

        if(rId){
            selecter = [NSString stringWithFormat:@"%@.%@%@,%@#%@%@",tagName,rId,additional,tagName,rId,additional];
        }else if(tagName || additional){
            selecter = [NSString stringWithFormat:@"%@%@",tagName,additional];
        }else{
            return [[InvalidFilter alloc] initWithText:text reason:@"filter elemhide nocriteria"];
        }

    }

    if(isException){
        return [[ElemHideException alloc] initWithText:text domains:domain selecter:selecter];
    }

//    NSTextCheckingResult *match = [selecter matchPattern:CsspropertyRegExp];
    RxMatch *match = [selecter firstMatchWithDetails:RX(CsspropertyRegExp)];
    if(match){
        if(![[NSString stringWithFormat:@",%@",domain] isMatch:RX(@",[^~][^,.]*\\.[^,]")]){
            return [[InvalidFilter alloc] initWithText:text reason:@"filter cssproperty nodomain"];
        }

//        NSArray<NSString *> *matchArr = [text matchGroupRex:match];
        if(match.groups.count >= 3){
            NSArray<RxMatchGroup *> *matchArr = match.groups;
            return [[CSSPropertyFilter alloc] initWithText:text domains:domain selecter:selecter
                                              regexpSource:matchArr[2].value
                                            selectorPrefix:[selecter substringWithRange:NSMakeRange(0,match.range.location)]
                                            selectorSuffix:[selecter substringFromIndex:match.range.location + matchArr[0].value.length]];

        }
    }

    return [[ElemHideFilter alloc] initWithText:text domains:domain selecter:selecter];
}

@end


@implementation ElemHideFilter {

}
- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains selecter:(NSString *)selecter {
    self = [super initWithText:text domains:domains selecter:selecter];
    if (self) {
        self.type = @"elemhide";
    }

    return self;
}


@end


@implementation CSSPropertyFilter {

}
- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains selecter:(NSString *)selecter
                regexpSource:(NSString *)regexpSource selectorPrefix:(NSString *)selectorPrefix selectorSuffix:(NSString *)selectorSuffix {
    self = [super initWithText:text domains:domains selecter:selecter];
    if (self) {
        self.type = @"cssproperty";
        self.regexpSource = regexpSource;
        self.selectorPrefix = selectorPrefix;
        self.selectorSuffix = selectorSuffix;
    }

    return self;
}

//Raw regular expression string to be used when testing CSS properties
-(NSString *)regexpString{
    if(_regexpString){
        return _regexpString;
    }
    return [ABPFilter toRegExp:_regexpSource];
}

@end


@implementation ElemHideException {

}
- (instancetype)initWithText:(NSString *)text domains:(NSString *)domains selecter:(NSString *)selecter {
    self = [super initWithText:text domains:domains selecter:selecter];
    if (self) {
        self.type = @"elemhideexception";
    }
    
    return self;
}


@end



