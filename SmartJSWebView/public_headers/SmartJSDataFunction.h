//
//  SmartJSDataFunction.h
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SmartJSWebView;
typedef void (^CompleteHandler)(id result, NSError * error);

@interface SmartJSDataFunction : NSObject

@property (nonatomic, strong) NSString* funcID;
@property (nonatomic, strong) SmartJSWebView* smartWebView;
@property (nonatomic, assign) BOOL removeAfterExecute;

- (id) initWithSmartWebView:(SmartJSWebView*) webView;

- (void) executeWithCompleteHandler:(CompleteHandler)handler;
- (void) executeWithParam: (NSString*) param completeHandler:(CompleteHandler)handler;
- (void) executeWithParams: (NSArray*) params completeHandler:(CompleteHandler)handler;

@end
