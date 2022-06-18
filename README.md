![logo](logo.png)
[![Build Status](http://img.shields.io/travis/pcjbird/SmartJSWebView/master.svg?style=flat)](https://travis-ci.org/pcjbird/SmartJSWebView)
[![Pod Version](http://img.shields.io/cocoapods/v/SmartJSWebView.svg?style=flat)](http://cocoadocs.org/docsets/SmartJSWebView/)
[![Pod Platform](http://img.shields.io/cocoapods/p/SmartJSWebView.svg?style=flat)](http://cocoadocs.org/docsets/SmartJSWebView/)
[![Pod License](http://img.shields.io/cocoapods/l/SmartJSWebView.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![GitHub release](https://img.shields.io/github/release/pcjbird/SmartJSWebView.svg)](https://github.com/pcjbird/SmartJSWebView/releases)
[![GitHub release](https://img.shields.io/github/release-date/pcjbird/SmartJSWebView.svg)](https://github.com/pcjbird/SmartJSWebView/releases)
[![Website](https://img.shields.io/website-pcjbird-down-green-red/https/shields.io.svg?label=author)](https://pcjbird.github.io)

# SmartJSWebView
### 支持 H5 页面通过 JavaScript 与 Native App 交互的 WebView，支持白名单功能。从 2.0.0 开始不再支持 UIWebView。

## 特性 / Features

1. 支持 H5 页面通过 JavaScript 与 Native App 交互。      
2. 安全策略，支持设置白名单功能。    
3. 页面重定向后依然可以调用到 Native 方法，不含私有 API，实测通过 AppStore 审核。    
4. 在 [EasyJSWebView](https://github.com/dukeland/EasyJSWebView) 基础上编写，功能更强大。    
5. 更多可能，JS调用路由框架封装，详见 [QuickWebKit](https://github.com/pcjbird/QuickWebViewController) 的 QuickWebJSBridgePlugin 插件，已实现多个 proxies。    
6. 支持 CocoaPods 安装。

## 演示 / Demo

<p align="center"><img src="demo.png" title="demo"></p>

##  安装 / Installation

方法一：`SmartJSWebView` is available through CocoaPods. To install it, simply add the following line to your Podfile:

```
pod 'SmartJSWebView'
```

## 使用 / Usage
*  [Demo项目](https://github.com/pcjbird/SmartJSWebView/tree/master/SmartJSWebViewDemo)
*  [测试页面地址](https://pcjbird.github.io/SmartJSWebView/SmartJSWebViewDemo/SmartJSWebViewDemo/floatingconsole/index.html)

## 关注我们 / Follow us
  
<a href="https://itunes.apple.com/cn/app/iclock-一款满足-挑剔-的翻页时钟与任务闹钟/id1128196970?pt=117947806&ct=com.github.pcjbird.SmartJSWebView&mt=8"><img src="https://github.com/pcjbird/AssetsExtractor/raw/master/iClock.gif" width="400" title="iClock - 一款满足“挑剔”的翻页时钟与任务闹钟"></a>

[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/pcjbird/SmartJSWebView)
[![Twitter Follow](https://img.shields.io/twitter/follow/pcjbird.svg?style=social)](https://twitter.com/pcjbird)

