//
//  ViewController.m
//  WebViewDebug
//
//  Created by luowei on 16/2/3.
//  Copyright © 2016年 2345. All rights reserved.
//

#import "ViewController.h"
#import "MyWebView.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MyWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *url;
@property (nonatomic, strong) JSContext  *jsContext;

@end

@implementation ViewController
- (IBAction)go:(id)sender {

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url.text]]];
    [self injectJS];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.2345.com"]]];
//    [self injectJS];
    
    
}

- (void)injectJS {
    // 1.
    _jsContext = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 2. 关联打印异常
    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    // 3. log打印
    _jsContext[@"console"][@"log"] = ^(JSValue *msg) {
        NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    };
    
    //-------------------广告标签拦截-----------------------
    //广告拦截注入js
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"abp" ofType :@ "bundle"];
    NSBundle *abpBundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *publicSuffixListSource = [[NSString stringWithContentsOfFile:[abpBundle pathForResource:@"publicSuffixList" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *basedomainSource = [NSString stringWithContentsOfFile:[abpBundle pathForResource:@"basedomain" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *filterClassesSource = [NSString stringWithContentsOfFile:[abpBundle pathForResource:@"filterClasses" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *matcherSource = [NSString stringWithContentsOfFile:[abpBundle pathForResource:@"matcher" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *elemHide = [NSString stringWithContentsOfFile:[abpBundle pathForResource:@"elemHide" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *adBlocker = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"adBlocker" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *adElemHide = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"adElemHide" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *adRequestBlocker = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iOS7ElemBlocker" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    
    //http://app.2345.com/browser/api/androidWebsite6.2.php/?appname=androidbrowser&channel=Internal&abprules_version=1453797649&exrules_version=1453797632&whitelist_version=1453797807
    //    NSString *whiteList = [NSString stringWithContentsOfURL:<#(NSURL *)url#> encoding:<#(NSStringEncoding)enc#> error:<#(NSError **)error#>];
    NSString *whiteList = @"";
    whiteList = [whiteList stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    
    NSString *exRules = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"css_rule" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];    exRules = [exRules stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    exRules = [exRules stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    exRules = [exRules stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    exRules = [exRules stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSString *compileFiltersSource = [NSString stringWithFormat:@"AdBlocker.compileWhiteList('%@');AdBlocker.compileABPRules('%@');AdBlocker.enable=%@;", whiteList, exRules, @"true"];
    
    NSMutableString *injectionJS = @"".mutableCopy;
    [injectionJS appendString:publicSuffixListSource];
    [injectionJS appendString:basedomainSource];
    [injectionJS appendString:filterClassesSource];
    [injectionJS appendString:matcherSource];
    [injectionJS appendString:elemHide];
    [injectionJS appendString:adBlocker];
    [injectionJS appendString:adElemHide];
    [injectionJS appendString:adRequestBlocker];
    [injectionJS appendString:compileFiltersSource];
    
    [_webView stringByEvaluatingJavaScriptFromString:injectionJS];
    //    [_jsContext evaluateScript:injectionJS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)webViewDidFinishLoad:(MyWebView *)webView {
//    [self injectJS];
    if (!_webView.isLoading) {
        [self injectJS];
    }
}

@end
