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
    
    [(WKWebView*)self.webView loadRequest:request];
    
    _loadurl = pageURL;
}

-(void)loadRequest:(NSURLRequest*)request
{
    [(WKWebView*)self.webView loadRequest:request];
    
    if(![[self class] isStringBlank:[request URL].absoluteString])
    {
        _loadurl = [request URL].absoluteString;
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
   [(WKWebView*)self.webView loadHTMLString:string baseURL:baseURL];
}


- (void)goBack
{
    [(WKWebView*)self.webView goBack];
}

- (void)goForward
{
    [(WKWebView*)self.webView goForward];
}

- (void)reload
{
    [(WKWebView*)self.webView reload];
}

- (void)stopLoading
{
    [(WKWebView*)self.webView stopLoading];
}

- (BOOL) canGoBack
{
    return [(WKWebView*)self.webView canGoBack];
}

- (BOOL) canGoForward
{
    return [(WKWebView*)self.webView canGoForward];
}

- (BOOL) isLoading
{
    return [(WKWebView*)self.webView isLoading];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    return [(WKWebView*)self.webView setBackgroundColor:backgroundColor];
}

-(void)setOpaque:(BOOL)opaque
{
    [super setOpaque:opaque];
    return [(WKWebView*)self.webView setOpaque:opaque];
}

- (void) initSmartJS{
    self.proxy = [SmartJSWebViewProxy new];
    self.delegate = self.proxy;
}

-(void)setDelegate:(id<WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate,SmartJSContextDelegate>)delegate
{
    if(_delegate == delegate) return;
    if (delegate != self.proxy)
    {
        self.proxy.realDelegate = delegate;
    }
    
    [(WKWebView*)self.webView setNavigationDelegate:self.proxy];
    [(WKWebView*)self.webView setUIDelegate:self.proxy];
    [((WKWebView*)self.webView).configuration.userContentController removeScriptMessageHandlerForName:@"SmartJS"];
    [((WKWebView*)self.webView).configuration.userContentController addScriptMessageHandler:self.proxy name:@"SmartJS"];
    [self.proxy injectUserScript:self.webView];
    [((WKWebView*)self.webView) addObserver:self.proxy forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

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
    return [self.webView title];
}


- (NSURL*) url
{
    NSURL *url = [self.webView URL];
    NSString *urlString = [url absoluteString];
    if(urlString && [urlString isEqualToString:@"about:blank"] && _loadurl)
    {
        return [NSURL URLWithString:_loadurl];
    }
    return url;
}

-(UIScrollView *)scrollView
{
    return nil;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        if(strongSelf)[(WKWebView*)strongSelf.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
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
