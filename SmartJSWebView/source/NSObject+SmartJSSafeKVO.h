//
//  NSObject+SmartJSSafeKVO.h
//  SmartJSWebView
//
//  Created by pcjbird on 2020/3/11.
//  Copyright © 2020 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SmartJSSafeKVO)

- (void)wvsafe_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void * _Nullable)context;

- (void)wvsafe_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  context:(void * _Nullable)context;

- (void)wvsafe_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
