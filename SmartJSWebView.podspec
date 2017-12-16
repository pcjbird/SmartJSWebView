Pod::Spec.new do |s|
    s.name         = 'SmartJSWebView'
    s.summary      = '支持 H5 页面通过 JavaScript 与 Native App 交互的 WebView，兼容 UIWebView 和 WKWebView。'
    s.version      = '1.0.0'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.authors      = { 'pcjbird' => 'pcjbird@hotmail.com' }
    s.social_media_url = 'http://www.lessney.com'
    s.homepage     = 'https://github.com/pcjbird/SmartJSWebView'
    s.platform     = :ios, '8.0'
    s.ios.deployment_target = '8.0'
    s.source       = { :git => 'https://github.com/pcjbird/SmartJSWebView.git', :tag => s.version.to_s }

    s.requires_arc = true
    s.source_files = 'SmartJSWebView/**/*.{h,m}'
    s.public_header_files = 'SmartJSWebView/public_headers/*.{h}'
    s.frameworks = 'Foundation','UIKit','WebKit','JavaScriptCore','QuartzCore'

    s.resource_bundles = {
    'SmartJSWebView' => ['SmartJSWebView/resource/*.*'],
    }

    #s.dependency ''

    s.requires_arc = true
    s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }

end
