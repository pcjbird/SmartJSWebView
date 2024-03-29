//
//  SmartJSWebViewProxy.h
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "SmartJSContextDelegate.h"
#import "SmartJSWebViewProgressDelegate.h"
#import "SmartJSWebSecurityProxy.h"
#import "SmartJSWebView.h"

@interface SmartJSWebViewProxy : NSObject<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate,SmartJSContextDelegate, SmartJSWebViewDelegate>

@property (nonatomic, strong) NSMutableDictionary* _Nullable javascriptInterfaces;
@property (nullable, nonatomic, weak) id<WKNavigationDelegate, WKUIDelegate,SmartJSContextDelegate, SmartJSWebViewDelegate> realDelegate;
@property (nullable, nonatomic, weak) id<SmartJSWebViewProgressDelegate> progressDelegate;
@property (nullable, nonatomic, weak) id<SmartJSWebSecurityProxy> securityProxy;


- (void) injectUserScript:(WKWebView*_Nonnull)webView;
- (void) addJavascriptInterfaces:(NSObject*_Nonnull) interface WithName:(NSString*_Nonnull) name;

- (void)setProgress:(float)progress;
@end
