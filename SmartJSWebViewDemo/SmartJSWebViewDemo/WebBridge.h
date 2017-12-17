//
//  WebBridge.h
//  SmartJSWebViewDemo
//
//  Created by pcjbird on 2017/12/17.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebBridge : NSObject<SmartJSBridgeProtocol>

+ (WebBridge *) sharedBridge;

- (NSString*) copyToClipboard:(NSString*) text;

@end
