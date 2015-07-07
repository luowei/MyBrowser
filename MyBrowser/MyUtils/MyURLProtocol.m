//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import "MyURLProtocol.h"
#import "Defines.h"
#import "AppDelegate.h"

int requestCount = 0;

@interface MyURLProtocol () <NSURLConnectionDataDelegate>


@end

@implementation MyURLProtocol {

}

//缓存服务端响应过来的数据
- (void)saveCachedResponse {
    Log(@" Saving cached response");

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];

    NSManagedObject *cacheResponse = [NSEntityDescription insertNewObjectForEntityForName:@"CachedURLResponse" inManagedObjectContext:context];
    [cacheResponse setValue:self.mutableData forKey:@"data"];
    [cacheResponse setValue:self.request.URL.absoluteString forKey:@"url"];
    [cacheResponse setValue:[NSDate date] forKey:@"timestamp"];
    [cacheResponse setValue:self.response.MIMEType forKey:@"mimeType"];
    [cacheResponse setValue:self.response.textEncodingName forKey:@"encoding"];

    NSError *error;
    if (![context save:&error]) {
        Log(@"Could not cache the response:%@",error.description);
    }
}

//获取缓存数据
- (NSManagedObject *)cachedResponseForCurrentRequest {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;

    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"CachedURLResponse" inManagedObjectContext:context];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", self.request.URL.absoluteString];
    fetchRequest.predicate = predicate;

    NSError *error;
    NSArray *possibleResult = [context executeFetchRequest:fetchRequest error:&error];
    if (possibleResult && possibleResult.count > 0) {
        return possibleResult[0];
    }

    return nil;
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    Log(@"request %i :URL = %@", requestCount++, request.URL.absoluteString);

//    if ([request valueForHTTPHeaderField:@"MyURLProtocolHandledKey"] != nil) {
    if ([NSURLProtocol propertyForKey:@"MyURLProtocolHandledKey" inRequest:request] != nil) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSManagedObject *cachedResponse = [self cachedResponseForCurrentRequest];
    if (cachedResponse) {
        Log(@"Serving response from cache");

        NSData *data = [cachedResponse valueForKey:@"data"];
        NSString *mimeType = [cachedResponse valueForKey:@"mimeType"];
        NSString *encoding = [cachedResponse valueForKey:@"encoding"];

        NSURLResponse *resp = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                        MIMEType:mimeType
                                           expectedContentLength:data.length
                                                textEncodingName:encoding];

        //因为自定义了缓存,所以这里禁止client再缓存
        [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        Log(@"Serving response from NSURLConnection");

        NSMutableURLRequest *newRequest = [self.request mutableCopy];
//        [newRequest setValue:@"MyCache" forHTTPHeaderField:@"MyURLProtocolHandledKey"];
        [NSURLProtocol setProperty:@"MyCache" forKey:@"MyURLProtocolHandledKey" inRequest:newRequest];
        self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    }
}

- (void)stopLoading {
    if (self.connection != nil) {
        [self.connection cancel];
    }
    self.connection = nil;
}

#pragma mark NSURLConnectionDelegate Implementation

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return NO;
}

#pragma mark NSURLConnectionDataDelegate Implementation

- (NSURLConnection *)connection {
    return _connection;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    self.response = response;
    self.mutableData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];

    //把接收到的数据添加到mutableData
    [self.mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];

    //保存到CoreData缓存起来
    [self saveCachedResponse];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end