//
//  SmartJSWebSecurityProxy.h
//  SmartJSWebView
//
//  Created by pcjbird on 2018/3/9.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#ifndef SmartJSWebSecurityProxy_h
#define SmartJSWebSecurityProxy_h

@class SmartJSWebView;
@protocol SmartJSWebSecurityProxy <NSObject>

@required
-(BOOL) shouldSmartJSWebViewUseSecurityWhitelist:(nullable SmartJSWebView*)webView;

@optional
-(nullable NSArray<NSString*>*)securityWhitelistForWebView:(nullable SmartJSWebView*)webView;
@end

#endif /* SmartJSWebSecurityProxy_h */
