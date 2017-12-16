//
//  SmartJSDataFunction.m
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import "SmartJSDataFunction.h"
#import "SmartJSWebView.h"

@implementation SmartJSDataFunction
@synthesize funcID;
@synthesize smartWebView;
@synthesize removeAfterExecute;

- (id) initWithSmartWebView:(SmartJSWebView*) webView{
    self = [super init];
    if (self) {
        self.smartWebView = webView;
    }
    return self;
}

- (void) executeWithCompleteHandler:(CompleteHandler)handler{
    [self executeWithParams:nil completeHandler:handler];
}

- (void) executeWithParam: (NSString*) param completeHandler:(CompleteHandler)handler{
    NSMutableArray* params = [[NSMutableArray alloc] initWithObjects:param, nil];
    [self executeWithParams:params completeHandler:handler];
}

- (void) executeWithParams: (NSArray*) params completeHandler:(CompleteHandler)handler{
    NSMutableString* injection = [[NSMutableString alloc] init];
    
    [injection appendFormat:@"SmartJS.invokeCallback(\"%@\", %@", self.funcID, self.removeAfterExecute ? @"true" : @"false"];
    
    if (params){
        for (int i = 0, l = (int)params.count; i < l; i++){
            NSString* arg = [params objectAtIndex:i];
            NSString* encodedArg = (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)arg, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
            
            [injection appendFormat:@", \"%@\"", encodedArg];
        }
    }
    
    [injection appendString:@");"];
    
    [self.smartWebView evaluateJavaScript:injection completionHandler:^(id result, NSError *error) {
        if(handler) handler(result, error);
    }];
}
@end
