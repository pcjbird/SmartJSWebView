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

@interface SmartJSWebViewProxy : NSObject<UIWebViewDelegate,WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate,SmartJSContextDelegate>

@property (nonatomic, strong) NSMutableDictionary* _Nullable javascriptInterfaces;
@property (nullable, nonatomic, weak) id<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> realDelegate;
@property (nullable, nonatomic, weak) id<SmartJSWebViewProgressDelegate> progressDelegate;

-(void)setWhitelist:(NSArray<NSString*>*)hostlist active:(BOOL)active;
-(void)setUseWhitelist:(BOOL)useWhitelist;

- (void) injectUserScript:(WKWebView*_Nonnull)webView;
- (void) addJavascriptInterfaces:(NSObject*_Nonnull) interface WithName:(NSString*_Nonnull) name;

@end
