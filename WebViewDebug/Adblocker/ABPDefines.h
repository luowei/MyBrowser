//
//  ABPDefines.h
//  WebViewDebug
//
//  Created by luowei on 16/1/5.
//  Copyright (c) 2016 hardy. All rights reserved.
//

#ifndef ABPDefines_h
#define ABPDefines_h

#define NSStringFromBOOL(aBOOL)    aBOOL? @"YES" : @"NO"

//键盘类型
typedef NS_OPTIONS(NSUInteger, FilterTypeMap) {
    OTHER = 1,
    SCRIPT = 2,
    IMAGE = 4,
    STYLESHEET = 8,
    OBJECT = 16,
    SUBDOCUMENT = 32,
    DOCUMENT = 64,
    XBL = 1,
    PING = 1024,
    XMLHTTPREQUEST = 2048,
    OBJECT_SUBREQUEST = 4096,
    DTD = 1,
    MEDIA = 16384,
    FONT = 32768,
    
    BACKGROUND = 4,    // Backwards compat, same as IMAGE
    
    POPUP = 0x10000000,
    GENERICBLOCK = 0x20000000,
    ELEMHIDE = 0x40000000,
    GENERICHIDE = 0x80000000
};

static NSString *const EasyList_Url = @"https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt";
static NSString *const EasyList_FileName = @"/Adblock_EasyListCN.txt";

#endif /* ABPDefines_h */
