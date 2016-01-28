//
//  MyWKWebView.m
//  Webkit-Demo
//
//  Created by luowei on 15/6/25.
//  Copyright (c) 2015 rootls. All rights reserved.
//

#import "MyWKWebView.h"
#import "MyWKWebViewController.h"
#import "MyHelper.h"
#import "Reachability.h"
#import "Defines.h"
#import "UserSetting.h"
#import "RegExCategories.h"
#import <objc/message.h>


@implementation MyWKUserContentController

//获得MyWKUserContentController单例
+ (instancetype)shareInstance {
    static MyWKUserContentController *myContentController = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        myContentController = [[self alloc] init];
    });

    return myContentController;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        //-----修改百度logo图片------

        //文档开始加载时
        NSString *docStartInjectionJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DocStartInjection" ofType:@"js"]
                                                                  encoding:NSUTF8StringEncoding error:NULL];

        //在document加载前执行注入js脚本
        WKUserScript *docStartScript = [[WKUserScript alloc] initWithSource:docStartInjectionJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                           forMainFrameOnly:NO];
        [self addUserScript:docStartScript];


        //文档完成加载时
        NSString *docEndInjectionJS = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"DocEndInjection" withExtension:@"js"]
                                                               encoding:NSUTF8StringEncoding error:NULL];

        //在document加载完成后执行注入js脚本
        WKUserScript *docEndScript = [[WKUserScript alloc] initWithSource:docEndInjectionJS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                         forMainFrameOnly:YES];
        [self addUserScript:docEndScript];


        //-------无图模式--------

        //无图模式注入js
        NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"imageBlocker" ofType:@"js"];
        NSString *source = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
        WKUserScript *blockImageUserScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:blockImageUserScript];

        WKUserScript *blockBackgroundImageUserScript = [[WKUserScript alloc] initWithSource:@"ImageBlocker.removeBackgroundImages();" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [self addUserScript:blockBackgroundImageUserScript];


        //-------广告拦截-------
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"abp" ofType:@ "bundle"];
        NSBundle *abpBundle = [NSBundle bundleWithPath:bundlePath];

        NSString *publicSuffixListSource = [[NSString stringWithContentsOfFile:[abpBundle pathForResource:@"publicSuffixList" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        WKUserScript *publicSuffixListUserScript = [[WKUserScript alloc] initWithSource:publicSuffixListSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:publicSuffixListUserScript];

        NSString *basedomainSource = [NSString stringWithContentsOfFile:[abpBundle pathForResource:@"basedomain" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
        WKUserScript *basedomainUserScript = [[WKUserScript alloc] initWithSource:basedomainSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:basedomainUserScript];

        NSString *filterClassesSource = [NSString stringWithContentsOfFile:[abpBundle pathForResource:@"filterClasses" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
        WKUserScript *filterClassesUserScript = [[WKUserScript alloc] initWithSource:filterClassesSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:filterClassesUserScript];

        NSString *matcherSource = [NSString stringWithContentsOfFile:[abpBundle pathForResource:@"matcher" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
        WKUserScript *matcherUserScript = [[WKUserScript alloc] initWithSource:matcherSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:matcherUserScript];

        NSString *elemHidePath = [abpBundle pathForResource:@"elemHide" ofType:@"js"];
        WKUserScript *elemHideUserScript = [[WKUserScript alloc] initWithSource:[NSString stringWithContentsOfFile:elemHidePath encoding:NSUTF8StringEncoding error:nil] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:elemHideUserScript];

        NSString *adBlockerPath = [[NSBundle mainBundle] pathForResource:@"adBlocker" ofType:@"js"];
        WKUserScript *adBlockerUserScript = [[WKUserScript alloc] initWithSource:[NSString stringWithContentsOfFile:adBlockerPath encoding:NSUTF8StringEncoding error:nil] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:adBlockerUserScript];

        NSString *adElemHidePath = [[NSBundle mainBundle] pathForResource:@"adElemHide" ofType:@"js"];
        WKUserScript *adElemHideUserScript = [[WKUserScript alloc] initWithSource:[NSString stringWithContentsOfFile:adElemHidePath encoding:NSUTF8StringEncoding error:nil] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:adElemHideUserScript];

        NSString *adRequestBlockerPath = [[NSBundle mainBundle] pathForResource:@"adRequestBlocker" ofType:@"js"];
        WKUserScript *adRequestBlockerUserScript = [[WKUserScript alloc] initWithSource:[NSString stringWithContentsOfFile:adRequestBlockerPath encoding:NSUTF8StringEncoding error:nil] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:adRequestBlockerUserScript];

        NSString *blockRules = [UserSetting getEasyListText];
        blockRules = [blockRules stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
        blockRules = [blockRules stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        blockRules = [blockRules stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        blockRules = [blockRules stringByReplacingOccurrencesOfString:@"\r" withString:@""];

        NSString *compileFiltersSource = [NSString stringWithFormat:@"AdBlocker.compileABPRules('%@');AdBlocker.enable=%@;", blockRules, @"true"];

        WKUserScript *compileFiltersUserScript = [[WKUserScript alloc] initWithSource:compileFiltersSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:compileFiltersUserScript];

    }

    return self;
}


@end


@interface MyWKWebView () {

}

@property(nonatomic, strong) NSError *error;
@end

@implementation MyWKWebView

static WKProcessPool *_pool;

+ (WKProcessPool *)pool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pool = [[WKProcessPool alloc] init];
    });
    return _pool;
}


- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {

    //设置多窗口cookie共享
    configuration.processPool = [MyWKWebView pool];
//    self.backForwardList

    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.navigationDelegate = self;
        self.UIDelegate = self;
        self.allowsBackForwardNavigationGestures = YES;
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        //加载用户js文件,修改加载网页内容
        [self addUserScriptsToWeb:configuration.userContentController];

        //网络连接状态标示
        _netStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //_netStatusLabel.text = NSLocalizedString(@"Unable Open Web Page With NetWork Disconnected", nil);
        _netStatusLabel.font = [UIFont systemFontOfSize:20.0];
        _netStatusLabel.textColor = [UIColor grayColor];
        [_netStatusLabel sizeToFit];
        _netStatusLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self addSubview:_netStatusLabel];
        _netStatusLabel.hidden = YES;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _netStatusLabel.text = NSLocalizedString(@"Unable Open Web Page With NetWork Disconnected", nil);
    [_netStatusLabel sizeToFit];
    _netStatusLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}


- (void)dealloc {
    self.removeProgressObserverBlock();
}

//加载用户js文件
- (void)addUserScriptsToWeb:(WKUserContentController *)userContentController {

    //添加脚本消息处理器根据消息名称
    [userContentController addScriptMessageHandler:self name:@"docStartInjection"];
    [userContentController addScriptMessageHandler:self name:@"docEndInjection"];

//    [userContentController addScriptMessageHandler:self name:@"decideImageBlockStatus"];
//    [userContentController addScriptMessageHandler:self name:@"decideAdBlockStatus"];
//    [userContentController addScriptMessageHandler:self name:@"increaseAdBlockCount"];

//        //js注入，用于改变网页字体的大小
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webFontjs" ofType:@"js"];
//        NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//        [self evaluateJavaScript:jsString completionHandler:nil];

    //添加ScriptMessageHandler
//    [userContentController addScriptMessageHandler:self name:@"getBeans"];
//    [userContentController addScriptMessageHandler:self name:@"webViewBack"];
}


//Sync JavaScript in WKWebView(同步版的javascript执行器)
//evaluateJavaScript is callback type. result should be handled by callback so, it is async.
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javascript {
    __block NSString *res = nil;
    __block BOOL finish = NO;
    [self evaluateJavaScript:javascript completionHandler:^(NSString *result, NSError *error) {
        res = result;
        finish = YES;
    }];

    while (!finish) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    return res;
}


//加载请求
- (WKNavigation *)loadRequest:(NSURLRequest *)request {

    NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:request.URL];

    //Add cookies to a request
//    [mutableURLRequest addValue:@"TeskCookieKey1=TeskCookieValue1;TeskCookieKey2=TeskCookieValue2;" forHTTPHeaderField:@"Cookie"];
//    // use stringWithFormat: in the above line to inject your values programmatically

    //set user-agent
//    [mutableURLRequest setValue:@"YourUserAgent/1.0" forHTTPHeaderField:@"User-Agent"];
    NSString *urlText = nil;
    if (request && request.URL) {
        urlText = request.URL.absoluteString;
    }
    self.updateSearchBarTextBlock(urlText);
    
    _netStatusLabel.hidden = [self connected];

    return [super loadRequest:request];
}


#pragma mark WKNavigationDelegate Implementation

//决定是否请允许打开
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

/*
    NSURL *url = navigationAction.request.URL;
    //处理App一类的特殊网址
    if (![url.absoluteString isHttpURL] && ![url.absoluteString isDomain]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
*/

    NSURL *url = navigationAction.request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    // iTunes: App Store link跳转不了问题
    if ([urlString isMatch:RX(@"\\/\\/itunes\\.apple\\.com\\/")]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    //蒲公英安装不了问题
    if ([urlString hasPrefix:@"itms-services://?action=download-manifest"]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:@"tel"]) {
        NSString *phoneNumber = url.resourceSpecifier.stringByRemovingPercentEncoding;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:phoneNumber message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Call", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

        }]];
        self.presentViewControllerBlock(alertController);
    }
    //决定是否新窗口打开
    if (!navigationAction.targetFrame) {
        if ([urlString hasSuffix:@".apk"]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        [webView loadRequest:navigationAction.request];
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
/*
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];

    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
*/

//    if(navigationResponse.canShowMIMEType){
//        NSString *mimeType = navigationResponse.response.MIMEType.lowercaseString;
//        if([mimeType isEqualToString:@"image/jpeg"] || [mimeType isEqualToString:@"image/png"] || [mimeType isEqualToString:@"image/gif"]){
//            decisionHandler(WKNavigationResponsePolicyCancel);
//            return;
//        }
//    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}


//处理当接收到验证窗口时
- (void)  webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSString *hostName = webView.URL.host;

    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]
            || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
            || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {

        NSString *title = @"Authentication Challenge";
        NSString *message = [NSString stringWithFormat:@"%@ requires user name and password", hostName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"User";
            //textField.secureTextEntry = YES;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Password";
            textField.secureTextEntry = YES;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            NSString *userName = ((UITextField *) alertController.textFields[0]).text;
            NSString *password = ((UITextField *) alertController.textFields[1]).text;

            NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];

            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);

        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.presentViewControllerBlock(alertController);
        });

    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }

}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    if ([UserSetting UASignIsChanged]) {
        [self switchUAMode:@([UserSetting UASign])];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"UASignIsChanged"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //修改浏览器UA设置
    if ([UserSetting UserAgent] == nil) {
        __weak typeof(self) weadSelf = self;
        [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            NSString *userAgent = result;
            if (userAgent && userAgent.length > 0) {
                [UserSetting SetUserAgent:userAgent];
                [weadSelf switchUAMode:@([UserSetting UASign])];
            }
        }];
    }

    //todo:清除当前广告拦截数据记录
    //[AdblockManager cleanCurrentBlockCount];

    //todo:更新返回按钮及进度条(didStartLoadingWebView)
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error = %@", error);
    self.error = error;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    //todo:更新进度条(didFailLoadWebView)

    switch ([error code]) {
        case kCFURLErrorServerCertificateUntrusted: {
            //解决12306不能买票问题
            NSRange range = [[webView.URL host] rangeOfString:@"12306.cn"];
            
            if (range.location != NSNotFound && range.location) {
                NSArray *chain = error.userInfo[@"NSErrorPeerCertificateChainKey"];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
                [webView loadRequest:[NSURLRequest requestWithURL:failingURL]];
            } else {
                // 网站证书不被信任，给出提示
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:
                                [NSString stringWithFormat:NSLocalizedString(@"HTTPS Certifcate Not Trust", nil), webView.URL.host]
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                     destructiveButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles:nil, nil];
                [sheet showInView:self];
            }
            break;
        }
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorNotConnectedToInternet:
        case kCFSOCKS5ErrorNoAcceptableMethod:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPConnectionLost:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFURLErrorBadURL:
        case kCFURLErrorTimedOut:
        case kCFURLErrorCannotFindHost:
        case kCFURLErrorCannotConnectToHost:
        case kCFURLErrorNetworkConnectionLost:
        case kCFNetServiceErrorTimeout:
        case kCFNetServiceErrorNotFound:
//            NSLog(@"errorCode:%ld",(long)[error code]);
            //error webView
            if (self.estimatedProgress < 0.3) {
                NSString *path = [[NSBundle mainBundle] pathForResource:@"failedPage" ofType:@"htm"];
                NSError *error2;
                NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error2];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [webView loadHTMLString:htmlString baseURL:failingURL];
            }
            break;
        default: {
            break;
        }
    }
}

//当加载页面发生错误
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {

//    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"Error"
//                                                                                 message:error.localizedDescription
//                                                                          preferredStyle:UIAlertControllerStyleAlert];
//    [alertViewController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
//    self.presentViewControllerBlock(alertViewController);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //todo:更新进度条(didFailLoadWebView)

    switch ([error code]) {
        case kCFURLErrorServerCertificateUntrusted: {
            //解决12306不能买票问题
            NSRange range = [[webView.URL host] rangeOfString:@"12306.cn"];
            if (range.location != NSNotFound) {
                NSArray *chain = error.userInfo[@"NSErrorPeerCertificateChainKey"];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
                [webView loadRequest:[NSURLRequest requestWithURL:failingURL]];
            }
            break;
        }
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorNotConnectedToInternet:
        case kCFSOCKS5ErrorNoAcceptableMethod:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPConnectionLost:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFURLErrorBadURL:
        case kCFURLErrorTimedOut:
        case kCFURLErrorCannotFindHost:
        case kCFURLErrorCannotConnectToHost:
        case kCFURLErrorNetworkConnectionLost:
        case kCFNetServiceErrorTimeout:
        case kCFNetServiceErrorNotFound:
            NSLog(@"errorCode:%ld", (long) [error code]);
            //error webView
            if (self.estimatedProgress < 0.3) {
                NSString *path = [[NSBundle mainBundle] pathForResource:@"failedPage" ofType:@"htm"];
                NSError *error2;
                NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error2];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [webView loadHTMLString:htmlString baseURL:failingURL];
            }
            break;
        default: {
            break;
        }
    }

}

//当页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.finishNavigationProgressBlock();

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

//    //获得网站的icon
//    [self evaluateJavaScript:[self JSToolCode] completionHandler:nil];
//    __weak typeof(self) weadSelf = self;
//    [self evaluateJavaScript:@"getAppIcon();" completionHandler:^(NSString *result, NSError *error) {
//        [self.delegate mainView:weadSelf updateFavIcon:result];
//    }];

}

//允许HTTPS验证钥匙中证书
- (void)setAllowsHTTPSCertifcateWithCertChain:(NSArray *)certChain ForHost:(NSString *)host {
    ((void (*)(id, SEL, id, id)) objc_msgSend)(self.configuration.processPool,
            //- (void)_setAllowsSpecificHTTPSCertificate:(id)arg1 forHost:(id)arg2;
            NSSelectorFromString([NSString base64Decoding:@"X3NldEFsbG93c1NwZWNpZmljSFRUUFNDZXJ0aWZpY2F0ZTpmb3JIb3N0Og=="]),
            certChain, host);
}

//切换用户代理模式
- (void)switchUAMode:(NSNumber *)modeNumber {
    if ([UserSetting UserAgent] != nil) {
        NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        NSString *UAString = nil;
        switch ([modeNumber intValue]) {
            case 0:
                if ([UserSetting UserAgent] != nil) {
                    UAString = [NSString stringWithFormat:@"%@ MyBrowser/%@", [UserSetting UserAgent], appVersion];
                }
                break;
            case 1:
                if ([UserSetting UserAgent] != nil) {
                    UAString = [NSString stringWithFormat:@"%@ MyBrowser Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/600.3.18 (KHTML, like Gecko) Version/8.0.3 Safari/600.3.18", [UserSetting UserAgent]];
                }
                break;

            default:
                break;
        }

        //- (void)_setCustomUserAgent:(id)arg1;
        ((void (*)(id, SEL, id)) objc_msgSend)(self, NSSelectorFromString([NSString base64Decoding:@"X3NldEN1c3RvbVVzZXJBZ2VudDo="]), UAString);
    }
}


#pragma mark WKMessageHandle Implementation

//处理当接收到html页面脚本发来的消息
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //返回
    if ([message.name isEqualToString:@"webViewBack"]) {
        [self goBack];

        //重新加载
    } else if ([message.name isEqualToString:@"webViewReload"]) {
        [self reload];

        //开启广告拦截
    } else if ([message.name isEqualToString:@"decideAdBlockStatus"]) {
        if ([UserSetting adblockerStatus]) {
            [self evaluateJavaScript:@"AdBlocker.enable=true;" completionHandler:nil];
        } else {
            [self evaluateJavaScript:@"AdBlocker.enable=false;" completionHandler:nil];
        }

        //记录拦截数
    } else if ([message.name isEqualToString:@"increaseAdBlockCount"]) {
        //记录拦截了多少条广告

        //开启无图模式
    } else if ([message.name isEqualToString:@"decideImageBlockStatus"]) {
        if ([UserSetting imageBlockerStatus]) {
            [self evaluateJavaScript:@"ImageBlocker.enable=true;" completionHandler:nil];
        } else {
            [self evaluateJavaScript:@"ImageBlocker.enable=false;" completionHandler:nil];
        }
    }
}


#pragma mark WKUIDelegate Implementation

//let link has arget=”_blank” work
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

    //
//    if (!navigationAction.targetFrame.isMainFrame) {
////        NSURL *url = navigationAction.request.URL;
////        UIApplication *app = [UIApplication sharedApplication];
////        if ([app canOpenURL:url]) {
////            [app openURL:url];
////        }
//        MyWKWebView *wb = nil;
//        self.addWKWebViewBlock(&wb,navigationAction.request.mainDocumentURL);
//        [webView loadRequest:navigationAction.request];
//        return wb;
//    }
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }

    return nil;
}

//处理页面的alert弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    self.presentViewControllerBlock(alertController);
}

//处理页面的confirm弹窗
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

    // TODO We have to think message to confirm "YES"
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    self.presentViewControllerBlock(alertController);
}

//处理页面的promt弹窗
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:webView.URL.host preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *) alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    self.presentViewControllerBlock(alertController);
}


#pragma mark - UIActionSheetDelegate

// 网站证书不被信任的情况
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            NSArray *chain = _error.userInfo[@"NSErrorPeerCertificateChainKey"];
            NSURL *failingURL = _error.userInfo[@"NSErrorFailingURLKey"];
            [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
            [self loadRequest:[NSURLRequest requestWithURL:failingURL]];
            break;
        }
        default:
            break;
    }
}


//判断网络连接状态
- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}


//显示类的私有方法
- (void)showAllPrivateMethod:(Class)clazz {
    u_int count;
    Method *methods = class_copyMethodList(clazz, &count);
    NSLog(@"----------------显示类的私有方法-----------");
    for (int i = 0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"%@", strName);
    }
}

#pragma mark - snapshot(快照截图)

//截图快照
- (void)snapshot {
    __weak typeof(self) weakSelf = self;
    [self snapshotWithHandler:^(CGImageRef imgRef) {
        UIImage *image = [UIImage imageWithCGImage:imgRef];
        UIImageWriteToSavedPhotosAlbum(image, weakSelf, NULL, NULL);
    }];
}

//快照截图Handler
- (void)snapshotWithHandler:(void (^)(CGImageRef imgRef))completionHandler {

    CGRect bounds = self.bounds;
    CGFloat imageWidth = self.frame.size.width * [UIScreen mainScreen].scale;

    //- (void)_snapshotRect:(CGRect)rectInViewCoordinates intoImageOfWidth:(CGFloat)imageWidth completionHandler:(void(^)(CGImageRef))completionHandler;
    SEL snapShotSel = NSSelectorFromString([NSString base64Decoding:@"X3NuYXBzaG90UmVjdDppbnRvSW1hZ2VPZldpZHRoOmNvbXBsZXRpb25IYW5kbGVyOg=="]);

    if ([self respondsToSelector:snapShotSel]) {
        ((void (*)(id, SEL, CGRect, CGFloat, id)) objc_msgSend)(self, snapShotSel, bounds, imageWidth, completionHandler);

    }

}


@end
