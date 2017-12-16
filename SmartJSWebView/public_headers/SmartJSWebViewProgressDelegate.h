//
//  SmartJSWebViewProgressDelegate.h
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#ifndef SmartJSWebViewProgressDelegate_h
#define SmartJSWebViewProgressDelegate_h

@protocol SmartJSWebViewProgressDelegate<NSObject>

@required
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end

#endif /* SmartJSWebViewProgressDelegate_h */
