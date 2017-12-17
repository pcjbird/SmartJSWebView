//
//  WebBridge.m
//  SmartJSWebViewDemo
//
//  Created by pcjbird on 2017/12/17.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import "WebBridge.h"

static WebBridge *_sharedBridge = nil;

@interface WebBridge()
{
    
}

@property(nonatomic, strong) NSMutableDictionary *webViewMap;

@end

@implementation WebBridge

+ (WebBridge *)sharedBridge {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedBridge) {
            _sharedBridge = [[WebBridge alloc] init];
            _sharedBridge.webViewMap = [NSMutableDictionary dictionary];
            
        }
    });
    return _sharedBridge;
}

-(instancetype)init
{
    if(self = [super init])
    {
        _webViewMap = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark SmartJSBridgeProtocol



-(void) registerWebView:(SmartJSWebView*)webView
{
    if([webView isKindOfClass:[SmartJSWebView class]] && [webView.secretId isKindOfClass:[NSString class]] && [webView.secretId length] > 0)
    {
        [_webViewMap setObject:webView forKey:webView.secretId];
    }
}

-(id) getSmartJSWebViewBySecretId:(NSString *)secretId
{
    if([secretId isKindOfClass:[NSString class]] && [secretId length] > 0)
    {
        SmartJSWebView *item = [_webViewMap objectForKey:secretId];
        return [item isKindOfClass:[SmartJSWebView class]] ? item : nil;
    }
    return nil;
}

- (NSString*) copyToClipboard:(NSString*) text
{
    [[UIPasteboard generalPasteboard] setString:text];
    [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:[UIPasteboard generalPasteboard].string duration:3.0f position:CSToastPositionCenter];
    return @"TRUE";
}

@end
