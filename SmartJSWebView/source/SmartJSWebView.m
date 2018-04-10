//
//  SmartJSWebView.m
//  SmartJSWebView
//
//  Created by pcjbird on 2017/12/16.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import "SmartJSWebView.h"
#import "SmartJSWebViewProxy.h"
#import "SmartJSWebViewDefine.h"

@interface SmartJSWebView()
{
    NSString*   _loadurl;
}
@property (nonatomic, strong) SmartJSWebViewProxy* proxy;

@end

@implementation SmartJSWebView

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initVariables];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initVariables];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initVariables];
    }
    
    return self;
}

-(void) initVariables
{
    _loadurl = nil;
    _preferWKWebView = NO;
    self.webView = [self createRealWebView];
    [self initSmartJS];
}

-(void)dealloc
{
    if([self.webView isKindOfClass:[WKWebView class]] && self.proxy)
    {
        [((WKWebView*)self.webView) removeObserver:self.proxy forKeyPath:@"estimatedProgress"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)createRealWebView
{
    _secretId = [self createSecretId];
    Class wkwebviewClass = NSClassFromString(@"WKWebView");
    if(wkwebviewClass&&self.preferWKWebView)
    {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 设置偏好设置
        config.preferences = [[WKPreferences alloc] init];
        // 默认为0
        config.preferences.minimumFontSize = 10;
        // 默认认为YES
        config.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        // web内容处理池
        config.processPool = [[WKProcessPool alloc] init];
        
        // 通过JS与webview内容交互
        config.userContentController = [[WKUserContentController alloc] init];
        
        WKWebView* webview = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
        [webview setBackgroundColor:[UIColor clearColor]];
        webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:webview];
        return webview;
    }
    else
    {
        UIWebView* webview = [[UIWebView alloc] initWithFrame:self.bounds];
        [webview setBackgroundColor:[UIColor clearColor]];
        webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [webview setScalesPageToFit:YES];
        [self addSubview:webview];
        
        return webview;
    }
}

-(void)setPreferWKWebView:(BOOL)preferWKWebView
{
    if(_preferWKWebView != preferWKWebView)
    {
        _preferWKWebView = preferWKWebView;
        if(self.webView)
        {
            [self.webView removeFromSuperview];
        }
        self.webView = [self createRealWebView];
        [self initSmartJS];
    }
}

- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name
{
    if(self.proxy)
    {
        [self.proxy addJavascriptInterfaces:interface WithName:name];
        if([interface conformsToProtocol:@protocol(SmartJSBridgeProtocol)])
        {
            id<SmartJSBridgeProtocol> interfaceProtocol = (id<SmartJSBridgeProtocol>)interface;
            __weak typeof (self) weakSelf = self;
            [interfaceProtocol registerWebView:weakSelf];
        }
    }
}

-(void)loadPage:(NSString *)pageURL
{
    if([[self class] isStringBlank:pageURL]) return;
    if([[self class] isStringHasChineseCharacter:pageURL])
    {
        pageURL = [pageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSURL *url = [NSURL URLWithString:pageURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView loadRequest:request];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView loadRequest:request];
    }
    _loadurl = pageURL;
}

-(void)loadRequest:(NSURLRequest*)request
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView loadRequest:request];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView loadRequest:request];
    }
    
    if(![[self class] isStringBlank:[request URL].absoluteString])
    {
        _loadurl = [request URL].absoluteString;
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView loadHTMLString:string baseURL:baseURL];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView loadHTMLString:string baseURL:baseURL];
    }
}


- (void)goBack
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView goBack];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView goBack];
    }
}

- (void)goForward
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView goForward];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView goForward];
    }
}

- (void)reload
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView reload];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView reload];
    }
}

- (void)stopLoading
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView stopLoading];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView stopLoading];
    }
}

- (BOOL) canGoBack
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView canGoBack];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView canGoBack];
    }
    return NO;
}

- (BOOL) canGoForward
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView canGoForward];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView canGoForward];
    }
    return NO;
}

- (BOOL) isLoading
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView isLoading];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView isLoading];
    }
    return NO;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView setBackgroundColor:backgroundColor];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView setBackgroundColor:backgroundColor];
    }
    
}

-(void)setOpaque:(BOOL)opaque
{
    [super setOpaque:opaque];
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        return [(UIWebView*)self.webView setOpaque:opaque];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        return [(WKWebView*)self.webView setOpaque:opaque];
    }
}

- (void) initSmartJS{
    self.proxy = [SmartJSWebViewProxy new];
    self.delegate = self.proxy;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateJavaScriptContext:) name:@"SmartJSWebViewCreateJavascriptContextNotification" object:nil];
}

- (void)didCreateJavaScriptContext:(NSNotification *)notification
{
    JSContext *jsContext = notification.object;
    if([jsContext isKindOfClass:[JSContext class]])
    {
        if([self.webView isKindOfClass:[UIWebView class]])
        {
            JSContext *mainFrameCtx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
            if(jsContext == mainFrameCtx)
            {
                if(self.proxy && [self.proxy respondsToSelector: @selector(webView:didCreateJavaScriptContext:)] )
                {
                    [(id<SmartJSContextDelegate>)self.proxy webView:self.webView didCreateJavaScriptContext:jsContext];
                }
            }
#if DEBUG
            else
            {
                NSLog(@"JavaScript contexts are different");
            }
#endif
        }
    }
}

-(void)setDelegate:(id<UIWebViewDelegate,WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate,SmartJSContextDelegate>)delegate
{
    if (delegate != self.proxy)
    {
        self.proxy.realDelegate = delegate;
    }
    
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        [(UIWebView*)self.webView setDelegate:self.proxy];
    }
    else if([self.webView isKindOfClass:[WKWebView class]])
    {
        [(WKWebView*)self.webView setNavigationDelegate:self.proxy];
        [(WKWebView*)self.webView setUIDelegate:self.proxy];
        [((WKWebView*)self.webView).configuration.userContentController addScriptMessageHandler:self.proxy name:@"SmartJS"];
        [self.proxy injectUserScript:self.webView];
        [((WKWebView*)self.webView) addObserver:self.proxy forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    _delegate = delegate;
}

-(void)setProgressDelegate:(id<SmartJSWebViewProgressDelegate>)progressDelegate
{
    if(self.proxy)
    {
        [self.proxy setProgressDelegate:progressDelegate];
    }
    _progressDelegate = progressDelegate;
}

-(void)setSecurityProxy:(id<SmartJSWebSecurityProxy>)securityProxy
{
    if(self.proxy)
    {
        [self.proxy setSecurityProxy:securityProxy];
    }
}



- (NSString*) title
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        
        return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    else
    {
        return [self.webView title];
    }
}


- (NSURL*) url
{
    if([self.webView isKindOfClass:[UIWebView class]])
    {
        NSString *urlString = [self.webView stringByEvaluatingJavaScriptFromString:@"location.href"];
        if (urlString)
        {
            if([urlString isEqualToString:@"about:blank"] && _loadurl)
            {
                return [NSURL URLWithString:_loadurl];
            }
            return [NSURL URLWithString:urlString];
        }
        return nil;
    }
    else
    {
        NSURL *url = [self.webView URL];
        NSString *urlString = [url absoluteString];
        if(urlString && [urlString isEqualToString:@"about:blank"] && _loadurl)
        {
            return [NSURL URLWithString:_loadurl];
        }
        return url;
    }
}

-(UIScrollView *)scrollView
{
    if([self.webView isKindOfClass:[UIView class]])
    {
        return [self.webView scrollView];
    }
    return nil;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([weakSelf.webView isKindOfClass:[UIWebView class]])
        {
            NSString* res = [(UIWebView*)weakSelf.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
            if(completionHandler) completionHandler(res, nil);
        }
        else if([weakSelf.webView isKindOfClass:[WKWebView class]])
        {
            [(WKWebView*)weakSelf.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
        }
    });
}

- (void)tracelog:(nonnull NSString*) log
{
    NSString *javascript = [NSString stringWithFormat:@"console.log('%%c %@','%@');", APP_LOG_FORMAT(@"%@", log), @"color:#000000"];
    [self evaluateJavaScript:javascript completionHandler:nil];
    SDK_LOG(@"%@",log);
}

- (void)tracewarning:(nonnull NSString*) log
{
    NSString *javascript = [NSString stringWithFormat:@"console.log('%%c %@','%@');", APP_LOG_FORMAT(@"%@", log), @"color:#FFC645"];
    [self evaluateJavaScript:javascript completionHandler:nil];
    SDK_LOG(@"%@",log);
}

- (void)traceerror:(nonnull NSString*) log
{
    NSString *javascript = [NSString stringWithFormat:@"console.log('%%c %@','%@');", APP_LOG_FORMAT(@"%@", log), @"color:#FF0000"];
    [self evaluateJavaScript:javascript completionHandler:nil];
    SDK_LOG(@"%@",log);
}

-(NSString*)createSecretId
{
    NSDate *localDate = [NSDate date]; //获取当前时间
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]];
    return [NSString stringWithFormat:@"WebViewSecret%@",timeSp];
}


+(BOOL) isStringBlank:(NSString*)val
{
    if(!val) return YES;
    if(![val isKindOfClass:[NSString class]]) return YES;
    val = [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([val isEqualToString:@""]) return YES;
    if([val isEqualToString:@"(null)"]) return YES;
    if([val isEqualToString:@"<null>"]) return YES;
    return NO;
}


+(BOOL) isStringHasChineseCharacter:(NSString*)val
{
    if([[self class] isStringBlank:val]) return NO;
    for(int i=0; i< [val length];i++)
    {
        int a = [val characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

@end
