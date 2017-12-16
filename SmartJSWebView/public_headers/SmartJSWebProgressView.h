//
//  SmartJSWebProgressView.h
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/17.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SmartJSWebView/SmartJSWebViewProgressDelegate.h>

@interface SmartJSWebProgressView : UIView<SmartJSWebViewProgressDelegate,CAAnimationDelegate>

@property (nonatomic,assign) float progress;
@property (readonly, nonatomic) UIView *progressBarView;
@property (nonatomic) NSTimeInterval barAnimationDuration;// default 0.5
@property (nonatomic) NSTimeInterval fadeAnimationDuration;// default 0.27
@property (copy, nonatomic) UIColor *progressBarColor; //进度条的颜色

@end
