//
//  ViewController.m
//  SmartJSWebViewDemo
//
//  Created by pcjbird on 2017/12/17.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import "ViewController.h"
#import "WebBridge.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet SmartJSWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.webView addJavascriptInterfaces:[WebBridge sharedBridge] WithName:@"SmartJSDemoInterface"];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"floatingconsole"]]];
    [self.webView loadRequest:request];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
