//
//  MyHelper.m
//  MyBrowser
//
//  Created by luowei on 15/6/27.
//  Copyright (c) 2015 wodedata. All rights reserved.
//

#import "MyHelper.h"

@implementation MyHelper


//显示提示窗
+ (void)showToastAlert:(NSString *)message {
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

//获得屏幕大小
+ (CGSize)fixedScreenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    } else {
        return screenSize;
    }
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

@end


@implementation NSString (BSEncoding)

+ (NSString *)encodedString:(NSString *)string {
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) string, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

+ (NSString *)base64Encoding:(NSString *)string {
    NSData *encodeData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
//    NSLog(@"Encode String Value: %@", base64String);
    return base64String;
}

+ (NSString *)base64Decoding:(NSString *)base64String {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
//    NSLog(@"Decode String Value: %@", decodedString);
    return decodedString;
}

@end


@implementation NSString (Match)


- (BOOL)isMatchString:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSTextCheckingResult *res = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return res != nil;
}

- (BOOL)isiTunesURL {
    return [self isMatchString:@"\\/\\/itunes\\.apple\\.com\\/"];
}

//是否是域名
- (BOOL)isDomain {
    return [self isMatchString:@"^([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,6}$"]
            || [self isMatchString:@"^(www.|[a-zA-Z].)[a-zA-Z0-9\\-\\.]+\\.(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\;\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"];
}

//是否是网址
- (BOOL)isHttpURL {
    return [self isMatchString:@"(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"]
            || [self isMatchString:@"^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)?((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.[a-zA-Z]{2,4})(\\:[0-9]+)?(/[^/][a-zA-Z0-9\\.\\,\\?\\'\\\\/\\+&amp;%\\$#\\=~_\\-@]*)*$"]
            || [self isMatchString:@"^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"];
}

@end


@implementation UIView (Capture)

- (UIImage *)screenCapture {
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [self drawViewHierarchyInRect:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, size.width, size.height) afterScreenUpdates:YES];
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
/*
    //方法二
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,YES, self.contentScaleFactor);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
*/
}

- (UIImage *)screenCapture:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat scale = size.width / self.layer.bounds.size.width;
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CGContextConcatCTM(ctx, transform);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

//获得图片的alpha通道值
- (CGFloat)getImageAlphaValue {
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 1, NULL, kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    [self drawAtPoint:CGPointMake(-1, -1)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0] / 255.0;
    return alpha;
}

@end