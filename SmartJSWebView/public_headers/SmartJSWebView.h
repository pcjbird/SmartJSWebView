//
//  SmartJSWebView.h
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//
//  框架名称:SmartJSWebView
//  框架功能:支持 H5 页面通过 JavaScript 与 Native App 交互的 WebView，兼容 UIWebView 和 WKWebView。
//  修改记录:
//     pcjbird    2017-12-16  Version:1.0.0 Build:201712160001
//                            1.首次发布SDK版本

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

//! Project version number for SmartJSWebView.
FOUNDATION_EXPORT double SmartJSWebViewVersionNumber;

//! Project version string for SmartJSWebView.
FOUNDATION_EXPORT const unsigned char SmartJSWebViewVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SmartJSWebView/PublicHeader.h>
#import <SmartJSWebView/SmartJSWebViewProgressDelegate.h>
#import <SmartJSWebView/SmartJSBridgeProtocol.h>
#import <SmartJSWebView/SmartJSDataFunction.h>
#import <SmartJSWebView/SmartJSWebProgressView.h>

@interface SmartJSWebView : UIView

/*!
 * The webview unique secret id
 */
@property(nonnull, nonatomic, strong, readonly)NSString* secretId;

/*!
 *  The real webview object.
 */
@property(nonnull, nonatomic, strong) id webView;

/*!
 *  The scrollview of the real webview.
 */
@property(nullable, nonatomic, readonly, weak) UIScrollView* scrollView;

/*!
 *  A Boolean val indicate whether prefer to user WKWebView when it is available.
 */
@property(nonatomic, assign) BOOL preferWKWebView;

@property (nullable, nonatomic, assign) id<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> delegate;
@property (nullable, nonatomic, assign) id<SmartJSWebViewProgressDelegate> progressDelegate;


-(void)loadPage:(nonnull NSString *)pageURL;

-(void)loadRequest:(nonnull NSURLRequest*)request;

- (void)loadHTMLString:(nullable NSString *)string baseURL:(nullable NSURL *)baseURL;


- (void)goBack;

- (void)goForward;

- (void)reload;

- (void)stopLoading;

- (BOOL) canGoBack;

- (BOOL) canGoForward;

- (BOOL) isLoading;


/*!
 * Inject javascript model to webview.
 */
- (void) addJavascriptInterfaces:(nonnull NSObject*) interface WithName:(nonnull NSString*) name;

/*!
 * Return the webview title.
 */
- (nullable NSString*) title;

/*!
 * Return current url.
 */
- (nullable NSURL*) url;

- (void)evaluateJavaScript:(nonnull NSString *)javaScriptString completionHandler:(void (^_Nullable)(id _Nullable result, NSError * _Nullable error))completionHandler;

@end
