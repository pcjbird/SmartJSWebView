//
//  SmartJSWebViewProxy.m
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import "SmartJSWebViewProxy.h"
#import <objc/runtime.h>
#import "SmartJSWebView.h"
#import "SmartJSWebViewDefine.h"
#import "SmartJSDataFunction.h"

#define completeRPCURLPath @"/smartjswebviewprogressproxy/complete"

static const float SmartJSWebViewProgressInitialValue = 0.7f;
static const float SmartJSWebViewProgressInteractiveValue = 0.9f;
static const float SmartJSWebViewProgressFinalProgressValue = 0.9f;

@interface SmartJSWebViewProxy()
{
    int _loadingCount;
    int _maxLoadCount;
    NSURL *_currentURL;
    BOOL _interactive;
    float _progress;
}
@end

@implementation SmartJSWebViewProxy

@synthesize realDelegate;
@synthesize javascriptInterfaces;
@synthesize progressDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        [self initVariables];
    }
    return self;
}

-(void)initVariables
{
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
}

- (void)startProgress
{
    if (_progress < SmartJSWebViewProgressInitialValue) {
        [self setProgress:SmartJSWebViewProgressInitialValue];
    }
}

- (void)incrementProgress
{
    float progress = _progress;
    float maxProgress = _interactive ? SmartJSWebViewProgressFinalProgressValue : SmartJSWebViewProgressInteractiveValue;
    float remainPercent = (float)_loadingCount/_maxLoadCount;
    float increment = (maxProgress-progress) * remainPercent;
    progress += increment;
    progress = fminf(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress
{
    [self setProgress:1.f];
}

- (void)setProgress:(float)progress
{
    if (progress > _progress || progress == 0)
    {
        _progress = progress;
        
        if (self.progressDelegate)
        {
            [self.progressDelegate setProgress:progress animated:YES];
        }
    }
}

- (void)reset
{
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.f];
}

- (BOOL)checkIfRPCURL:(NSURLRequest *)request
{
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return YES;
    }
    
    return NO;
}


- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name{
    if (! self.javascriptInterfaces){
        self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
    }
    
    [self.javascriptInterfaces setValue:interface forKey:name];
}

- (void) injectUserScript:(WKWebView*)webView
{
    NSString * functionjs = [NSString stringWithContentsOfFile:[SDK_BUNDLE pathForResource:@"function-inject" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *functionScript = [[WKUserScript alloc] initWithSource:functionjs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [webView.configuration.userContentController addUserScript:functionScript];
    
    NSString * deferredjs = [NSString stringWithContentsOfFile:[SDK_BUNDLE pathForResource:@"deferredjs-inject" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *deferredScript = [[WKUserScript alloc] initWithSource:deferredjs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [webView.configuration.userContentController addUserScript:deferredScript];
    
    NSString * smartjs = [NSString stringWithContentsOfFile:[SDK_BUNDLE pathForResource:@"smartjs-inject" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:smartjs injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [webView.configuration.userContentController addUserScript:userScript];
}

#pragma mark - 判断域名是否在白名单中
-(BOOL) isHost:(NSString*)host inWhitelist:(NSArray<NSString*>*)whitelist
{
    __block BOOL result = NO;
    if([host isKindOfClass:[NSString class]] && [whitelist isKindOfClass:[NSArray<NSString*> class]])
    {
        [whitelist enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)
            {
                if([host containsString:obj])
                {
                    result = YES;
                    *stop = YES;
                }
            }
            else
            {
                NSRange range = [host rangeOfString:obj];
                if(range.location != NSNotFound && range.length > 0)
                {
                    result = YES;
                    *stop = YES;
                }
            }
            
        }];
    }
    return result;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //所传过来的参数message.body，只支持NSNumber, NSString, NSDate, NSArray, NSDictionary, and NSNull类型
    
    SmartJSWebView *jsWebView = (SmartJSWebView*)[message.webView superview];
    if(![jsWebView isKindOfClass:[SmartJSWebView class]]) return;
    
    if ([message.name isEqualToString:@"SmartJS"])
    {
        BOOL isSafe = YES;
        if(self.securityProxy && [self.securityProxy conformsToProtocol:@protocol(SmartJSWebSecurityProxy)])
        {
            BOOL useWhiteList = [self.securityProxy shouldSmartJSWebViewUseSecurityWhitelist:(SmartJSWebView*)[message.webView superview]];
            if(useWhiteList)
            {
                NSArray<NSString*> *whitelist = nil;
                if([self.securityProxy respondsToSelector:@selector(securityWhitelistForWebView:)])
                {
                    whitelist = [self.securityProxy securityWhitelistForWebView:(SmartJSWebView*)[message.webView superview]];
                }
                if(![whitelist isKindOfClass:[NSArray<NSString *> class]])
                {
                    whitelist = [NSArray<NSString *> array];
                }
                NSString *host = message.webView.URL.host;
                if([host isKindOfClass:[NSString class]])
                {
                    if(![self isHost:host inWhitelist:whitelist])
                    {
                        isSafe = NO;
                    }
                }
            }
        }
        if(!isSafe)
        {
            NSString *log = [NSString stringWithFormat:@"当前已启用安全策略，域名 %@ 无法通过 JavaScript 与 Native App 交互，请向管理员申请权限。", message.webView.URL.host];
            [jsWebView tracewarning:log];
            return;
        }
        NSDictionary *body = message.body;
        if([body isKindOfClass:[NSDictionary class]])
        {
            NSString* callbackID = [body objectForKey:@"callbackID"];
            NSString* obj = [body objectForKey:@"className"];
            if(![obj isKindOfClass:[NSString class]]) return;
            NSString* encodedfun = [body objectForKey:@"functionName"];
            if(![encodedfun isKindOfClass:[NSString class]]) return;
            NSString* method = [encodedfun stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSObject* interface = [self.javascriptInterfaces objectForKey:obj];
            if (![interface isKindOfClass:[NSObject class]])
            {
                NSString *errorString = [NSString stringWithFormat:@"当前并未提供Javascript Interface:%@ 的调用。", obj];
                [jsWebView traceerror:errorString];
                return;
            }
            
            if([method isEqualToString:@"createSecretId"])
            {
                NSString *secretId = jsWebView.secretId;
                [jsWebView evaluateJavaScript:[NSString stringWithFormat:@"SmartJS.retValue=%@;", secretId] completionHandler:nil];
                
                return;
            }
            // execute the interfacing method
            SEL selector = NSSelectorFromString(method);
            NSMethodSignature* sig = [[interface class] instanceMethodSignatureForSelector:selector];
            if (![sig isKindOfClass:[NSMethodSignature class]])
            {
                NSString *errorString = [NSString stringWithFormat:@"Javascript Interface:%@ 并未提供 %@ 的调用。", obj, method];
                [jsWebView traceerror:errorString];
                return;
            }
            NSInvocation* invoker = [NSInvocation invocationWithMethodSignature:sig];
            invoker.selector = selector;
            invoker.target = interface;
            
            NSMutableArray* args = [[NSMutableArray alloc] init];
            
            NSString *argStr = [body objectForKey:@"argument"];
            if([argStr isKindOfClass:[NSString class]] && [argStr length] > 0)
            {
                NSString *argsAsString = [[argStr substringFromIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSArray* formattedArgs = [argsAsString componentsSeparatedByString:@":"];
                for (int i = 0, j = 0, l = (int)[formattedArgs count]; i < l; i+=2, j++)
                {
                    NSString* type = ((NSString*) [formattedArgs objectAtIndex:i]);
                    NSString* argStr = ((NSString*) [formattedArgs objectAtIndex:i + 1]);
                    
                    if ([@"f" isEqualToString:type])
                    {
                        SmartJSDataFunction* func = [[SmartJSDataFunction alloc] initWithSmartWebView:(SmartJSWebView *)[message.webView superview]];
                        func.funcID = argStr;
                        [args addObject:func];
                        [invoker setArgument:&func atIndex:(j + 2)];
                    }
                    else if ([@"s" isEqualToString:type])
                    {
                        NSString* arg = [argStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        [args addObject:arg];
                        [invoker setArgument:&arg atIndex:(j + 2)];
                    }
                }
            }
            [invoker invoke];
            
            //return the value by using javascript
            if ([sig methodReturnLength] > 0){
                
                const char* returnType = sig.methodReturnType;
                if(!strcmp(returnType, @encode(id)))
                {
                    void* _retValue;
                    [invoker getReturnValue:&_retValue];
                    id retValue = (__bridge id)_retValue;
                    if (retValue == NULL || retValue== nil)
                    {
                        [message.webView evaluateJavaScript:[NSString stringWithFormat:@"SmartJS.asyncCallback(\"%@\", \"success\", [null]);", callbackID] completionHandler:nil];
                    }
                    else
                    {
                        if ([retValue isKindOfClass:[NSString class]])
                        {
                            retValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) retValue, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
                            [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"SmartJS.asyncCallback(\"%@\", \"success\",[\"%@\"]);", callbackID,retValue] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                                
                            }];
                        }
                        else
                        {
                            [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"SmartJS.asyncCallback(\"%@\", \"success\",[\"%@\"]);", callbackID,retValue] completionHandler:nil];
                        }
                    }
                    return;
                }
                NSUInteger length = [sig methodReturnLength];
                //根据长度申请内存
                void *_retValue = (void *)malloc(length);
                [invoker getReturnValue:_retValue];
                
                if(!strcmp(returnType, @encode(BOOL)))
                {
                    BOOL result = *((BOOL*)_retValue);
                    [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"SmartJS.asyncCallback(\"%@\", \"success\",[\"%@\"]);", callbackID, result ? @"true" : @"false"] completionHandler:nil];
                }
                else if(!strcmp(returnType, @encode(int)))
                {
                    int result = *((int*)_retValue);
                    [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"SmartJS.asyncCallback(\"%@\", \"success\", [%d]);", callbackID, result] completionHandler:nil];
                }
                else if(!strcmp(returnType, @encode(float)))
                {
                    float result = *((float*)_retValue);
                    [message.webView evaluateJavaScript:[@"" stringByAppendingFormat:@"SmartJS.asyncCallback(\"%@\", \"success\", [%f]);", callbackID, result] completionHandler:nil];
                }
                else
                {
                    [message.webView evaluateJavaScript:@"SmartJS.asyncCallback(\"%@\", \"success\", [\"notsupport\"]);" completionHandler:nil];
                }
                if(_retValue)free(_retValue);
            }
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)])
    {
        [self.realDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)])
    {
        [self.realDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)])
    {
        [self.realDelegate webView:webView didStartProvisionalNavigation:navigation];
        return;
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)])
    {
        [self.realDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)])
    {
        [self.realDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if (! self.javascriptInterfaces){
        self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableString* injection = [[NSMutableString alloc] init];
    
    //inject the javascript interface
    for(id key in self.javascriptInterfaces) {
        NSObject* interface = [self.javascriptInterfaces objectForKey:key];
        
        [injection appendString:@"SmartJS.inject(\""];
        [injection appendString:key];
        [injection appendString:@"\", ["];
        
        unsigned int mc = 0;
        Class cls = object_getClass(interface);
        Method * mlist = class_copyMethodList(cls, &mc);
        for (int i = 0; i < mc; i++){
            [injection appendString:@"\""];
            [injection appendString:[NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))]];
            [injection appendString:@"\""];
            
            if (i != mc - 1){
                [injection appendString:@", "];
            }
        }
        
        if(mlist)free(mlist);
        
        [injection appendString:@"]);"];
    }
    
    //inject the function interface
    [webView evaluateJavaScript:injection completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didCommitNavigation:)])
    {
        [self.realDelegate webView:webView didCommitNavigation:navigation];
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didFinishNavigation:)])
    {
        [self.realDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    if(self.realDelegate &&[self.realDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)])
    {
        [self.realDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)])
    {
        [self.realDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        return;
    }
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)])
    {
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
        {
            if (@available(iOS 9.0, *)) {
                [self.realDelegate webViewWebContentProcessDidTerminate:webView];
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webViewDidClose:)])
    {
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
        {
            if (@available(iOS 9.0, *)) {
                [self.realDelegate webViewDidClose:webView];
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"JS Alert Pannel Message:%@.", message);
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)])
    {
        [self.realDelegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    NSLog(@"JS Confirm Pannel Message:%@.", message);
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)])
    {
        [self.realDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"JS TextInput Pannel Prompt:%@, defaultText:%@.", prompt, defaultText);
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)])
    {
        [self.realDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler(@"");
}


@end
