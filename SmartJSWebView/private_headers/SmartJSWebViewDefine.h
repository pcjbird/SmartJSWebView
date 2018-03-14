//
//  SmartJSWebViewDefine.h
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#ifndef SmartJSWebViewDefine_h
#define SmartJSWebViewDefine_h

//SDK Bundle
#define SDK_BUNDLE [NSBundle bundleWithPath:[[NSBundle bundleForClass:[SmartJSWebView class]] pathForResource:@"SmartJSWebView" ofType:@"bundle"]]

#define APP_NAME ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] ? [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"])
#define APP_VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define APP_BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

#define APP_LOG_FORMAT(format, ...) [NSString stringWithFormat:@"[🐥 %@] %s (line %d) " format, APP_NAME, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]

#ifdef DEBUG
#   define SDK_LOG(fmt, ...) NSLog((@"[🐣 SmartJSWebView] %s (line %d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define SDK_LOG(fmt, ...) (nil)
#endif

#endif /* SmartJSWebViewDefine_h */
