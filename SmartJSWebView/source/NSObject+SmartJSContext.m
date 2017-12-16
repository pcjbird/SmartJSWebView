//
//  NSObject+SmartJSContext.m
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import "NSObject+SmartJSContext.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation NSObject (SmartJSContext)

- (void)webView:(id)unused didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)alsoUnused
{
    if (![ctx isKindOfClass:[JSContext class]]) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SmartJSWebViewCreateJavascriptContextNotification" object:ctx];
}

@end
