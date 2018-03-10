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
//     pcjbird    2018-03-10  Version:1.0.7 Build:201803100002
//                            1.修改白名单域名匹配规则
//
//     pcjbird    2018-03-10  Version:1.0.6 Build:201803100001
//                            1.调整命名
//                            2.修改白名单提供方式
//
//     pcjbird    2018-03-09  Version:1.0.5 Build:201803090001
//                            1.新增白名单功能
//
//     pcjbird    2018-02-08  Version:1.0.4 Build:201802080001
//                            1.修复野指针导致crash的问题
//
//     pcjbird    2018-02-07  Version:1.0.3 Build:201802070001
//                            1.优化webViewDidStartLoad获取不到url值的情况
//
//     pcjbird    2018-02-04  Version:1.0.2 Build:201802040001
//                            1.默认注入"createSecretId"方法
//
//     pcjbird    2017-12-16  Version:1.0.1 Build:201712170001
//                            1.恢复 Pod 编译选项，弃用静态库编译
//                            2.新增 Demo 项目
//
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
#import <SmartJSWebView/SmartJSWebSecurityProxy.h>
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


@property (nullable, nonatomic, weak) id<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> delegate;
@property (nullable, nonatomic, weak) id<SmartJSWebViewProgressDelegate> progressDelegate;
@property (nullable, nonatomic, weak) id<SmartJSWebSecurityProxy> securityProxy;

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
