//
//  SmartJSBridgeProtocol.h
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#ifndef SmartJSBridgeProtocol_h
#define SmartJSBridgeProtocol_h

@class SmartJSWebView;
@protocol SmartJSBridgeProtocol <NSObject>
@optional
-(void) registerWebView:(SmartJSWebView*)webView;
-(id) getSmartJSWebViewBySecretId:(NSString *)secretId;
@end

#endif /* SmartJSBridgeProtocol_h */
