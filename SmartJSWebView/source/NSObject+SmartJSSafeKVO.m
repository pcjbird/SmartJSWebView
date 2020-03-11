//
//  NSObject+SmartJSSafeKVO.m
//  SmartJSWebView
//
//  Created by pcjbird on 2020/3/11.
//  Copyright © 2020 Zero Status. All rights reserved.
//

#import "NSObject+SmartJSSafeKVO.h"
#import <objc/runtime.h>

@interface WVObserverProxy : NSObject {
    __weak id _observer;
    __weak id _observeredObj;
    NSMutableSet *_keypaths;
    dispatch_semaphore_t _semaphoreForKeyPath;
}

- (instancetype)initWithObserver:(id)obj observeredObj:(id)observeredObj;

- (void)proxy_addKeyPath:(NSString *)keyPath
                 options:(NSKeyValueObservingOptions)options
                 context:(void *)context;

- (void)proxy_removeObserver:(NSObject *)observer
                  forKeyPath:(NSString *)keyPath
                     context:(void *)context;

@end


@interface WVObserveredDeallocListener : NSObject

- (instancetype)initWithObserveredObject:(id)obj;
- (void)addProxy:(WVObserverProxy *)proxy;

@end

static dispatch_semaphore_t sKVOProxySemaphore;

@implementation NSObject (SmartJSSafeKVO)

- (void)wvsafe_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context {
    if (!observer || !keyPath.length ||
        ![observer respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sKVOProxySemaphore = dispatch_semaphore_create(1);
    });
    
    // Using lock to prevent error of calling in multithread
    dispatch_semaphore_wait(sKVOProxySemaphore, DISPATCH_TIME_FOREVER);
    WVObserverProxy *proxy = [observer wvsafe_observerProxyWithKey:(__bridge const void *)(self)];
    if (!proxy) {
        proxy = [[WVObserverProxy alloc] initWithObserver:observer observeredObj:self];
        [observer setWvsafe_observerProxy:proxy key:(__bridge const void *)(self)];
    }
    WVObserveredDeallocListener *listener = [self wvsafe_observeredDeallocLinstener];
    if (!listener) {
        listener = [[WVObserveredDeallocListener alloc] initWithObserveredObject:self];
        [self setWvsafe_observeredDeallocLinstener:listener];
    }
    dispatch_semaphore_signal(sKVOProxySemaphore);
    
    [listener addProxy:proxy];
    [proxy proxy_addKeyPath:keyPath
                    options:options
                    context:context];
}

- (void)wvsafe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:( void * _Nullable )context {
    if (!observer || !keyPath.length) {
        return;
    }
    WVObserverProxy *proxy = [observer wvsafe_observerProxyWithKey:(__bridge const void *)(self)];
    [proxy proxy_removeObserver:observer forKeyPath:keyPath context:context];
}

- (void)wvsafe_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [self wvsafe_removeObserver:observer forKeyPath:keyPath context:nil];
}

- (WVObserverProxy *)wvsafe_observerProxyWithKey:(const void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)setWvsafe_observerProxy:(WVObserverProxy *)proxy key:(const void *)key {
    objc_setAssociatedObject(self, key, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WVObserveredDeallocListener *)wvsafe_observeredDeallocLinstener {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWvsafe_observeredDeallocLinstener:(WVObserveredDeallocListener *)obj {
    objc_setAssociatedObject(self, @selector(wvsafe_observeredDeallocLinstener), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation WVObserverProxy

- (instancetype)initWithObserver:(id)obj observeredObj:(id)observeredObj {
    self = [super init];
    if (self) {
        _observer = obj;
        _observeredObj = observeredObj;
        _keypaths = [NSMutableSet set];
        _semaphoreForKeyPath = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)dealloc {
    [self removeSelfOberseringWhenSelfDealloc];
}

- (void)removeSelfOberseringWhenSelfDealloc {
    [self removeSelfObserveringInfoWithObserveredObject:_observeredObj];
}

- (void)removeSelfObserveringInfoWithObserveredObject:(id)observeredObj {
    dispatch_semaphore_wait(_semaphoreForKeyPath, DISPATCH_TIME_FOREVER);
    if (!observeredObj) {
        dispatch_semaphore_signal(_semaphoreForKeyPath);
        return;
    }
    id obj = observeredObj;
    for (NSString *keypath in _keypaths) {
        [obj removeObserver:self forKeyPath:keypath];
    }
    [_keypaths removeAllObjects];
    [_observer setWvsafe_observerProxy:nil key:(__bridge const void *)obj];
    dispatch_semaphore_signal(_semaphoreForKeyPath);
}

#pragma mark - KVO transmit
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([_keypaths containsObject:keyPath]) {
        if (_observer && [_observer respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
            [_observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

#pragma mark - Public methods
- (void)proxy_addKeyPath:(NSString *)keyPath
                 options:(NSKeyValueObservingOptions)options
                 context:(void *)context {
    dispatch_semaphore_wait(_semaphoreForKeyPath, DISPATCH_TIME_FOREVER);
    if (![_keypaths containsObject:keyPath]) {
        [_keypaths addObject:keyPath];
        [_observeredObj addObserver:self forKeyPath:keyPath options:options context:context];
    }
    dispatch_semaphore_signal(_semaphoreForKeyPath);
}

- (void)proxy_removeObserver:(NSObject *)observer
                  forKeyPath:(NSString *)keyPath
                     context:(void *)context {
    dispatch_semaphore_wait(_semaphoreForKeyPath, DISPATCH_TIME_FOREVER);
    if (_observeredObj && [_keypaths containsObject:keyPath]) {
        [_observeredObj removeObserver:self forKeyPath:keyPath context:context];
        [_keypaths removeObject:keyPath];
    }
    if (_keypaths.count <= 0 && _observer && _observeredObj) {
        [_observer setWvsafe_observerProxy:nil key:(__bridge const void *)(_observeredObj)];
    }
    dispatch_semaphore_signal(_semaphoreForKeyPath);
}

- (void)proxy_removeObersersWhenObserveredObjectDealloc:(id)observeredObj {
    [self removeSelfObserveringInfoWithObserveredObject:observeredObj];
}

@end

@implementation WVObserveredDeallocListener {
    __unsafe_unretained id _observeredObj;
    // Save proxy in weak way
    NSHashTable *_proxyHashTable;
}

- (instancetype)initWithObserveredObject:(id)obj {
    self = [super init];
    if (self) {
        _observeredObj = obj;
        _proxyHashTable = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)dealloc {
    NSArray *array = [_proxyHashTable allObjects];
    for (WVObserverProxy *proxy in array) {
        [proxy proxy_removeObersersWhenObserveredObjectDealloc:_observeredObj];
    }
    _observeredObj = nil;
}

- (void)addProxy:(WVObserverProxy *)proxy {
    if (![_proxyHashTable containsObject:proxy]) {
        [_proxyHashTable addObject:proxy];
    }
}

@end
