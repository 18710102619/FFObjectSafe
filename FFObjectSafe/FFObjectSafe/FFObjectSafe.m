//
//  FFObjectSafe.m
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/9.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "FFObjectSafe.h"
#import <objc/runtime.h>

#define FFAssert(condition, ...) \
if (!(condition)) { \
    FFLog(__FILE__, __FUNCTION__, __LINE__, __VA_ARGS__); \
} \
NSAssert(condition, @"%@", __VA_ARGS__);

void FFLog(const char* file, const char* func, int line, NSString* fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    NSLog(@"%s|%s|%d|%@", file, func, line, [[NSString alloc] initWithFormat:fmt arguments:args]);
    va_end(args);
}

@implementation NSObject (Swizzle)

/**
 类方法替换

 @param origSelector 原方法
 @param newSelector 替换方法
 */
+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class class=[self class];
    Class meta_class=objc_getMetaClass(NSStringFromClass(class).UTF8String);
    
    Method originalMethod=class_getClassMethod(class, origSelector);
    Method swizzledMethod=class_getClassMethod(class, newSelector);
    
    BOOL addMethod=class_addMethod(meta_class,
                                   origSelector,
                                   method_getImplementation(swizzledMethod),
                                   method_getTypeEncoding(swizzledMethod));
    
    if (addMethod) {
        class_replaceMethod(meta_class,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

/**
 实例方法替换

 @param origSelector 原方法
 @param newSelector 替换方法
 */
- (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class class = [self class];

    Method originalMethod = class_getInstanceMethod(class, origSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);

    BOOL addMethod=class_addMethod(class,
                                   origSelector,
                                   method_getImplementation(swizzledMethod),
                                   method_getTypeEncoding(swizzledMethod));
    if (addMethod) {
        class_replaceMethod(class,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        class_replaceMethod(class,
                            newSelector,
                            class_replaceMethod(class,
                                                origSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

@end

@implementation NSArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //类方法
        [NSArray swizzleClassMethod:@selector(arrayWithObject:) withMethod:@selector(hookArrayWithObject:)];
        
        //__NSArrayI
        NSArray *arrayI = [[NSArray alloc] initWithObjects:@0, @1, nil];
        [arrayI swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(hookObjectAtIndex:)];
        
        //__NSArray0
        NSArray *array0 = [[NSArray alloc] init];
        [array0 swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(hookObjectAtIndex0:)];
        
        //__NSSingleObjectArrayI
        NSArray *singleObjectArrayI = [[NSArray alloc] initWithObjects:@0, nil];
        [singleObjectArrayI swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(hookObjectAtIndex:)];
        
    });
}

+ (instancetype)hookArrayWithObject:(id)anObject
{
    if (anObject) {
        return [self hookArrayWithObject:anObject];
    }
    return nil;
}

- (id) hookObjectAtIndex0:(NSUInteger)index
{
    return nil;
}

- (id)hookObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self hookObjectAtIndex:index];
    }
    return nil;
}

@end

@implementation NSMutableArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array swizzleInstanceMethod:@selector(addObject:) withMethod:@selector(hookAddObject:)];
        [array swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(hookObjectAtIndex:)];
        [array swizzleInstanceMethod:@selector(removeObjectAtIndex:) withMethod:@selector(hookRemoveObjectAtIndex:)];
        [array swizzleInstanceMethod:@selector(insertObject:atIndex:) withMethod:@selector(hookInsertObject:atIndex:)];
        [array swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:) withMethod:@selector(hookReplaceObjectAtIndex:withObject:)];
    });
}

- (void)hookAddObject:(id)anObject
{
    if (anObject) {
        [self hookAddObject:anObject];
    }
}

- (id)hookObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self hookObjectAtIndex:index];
    }
    return nil;
}

- (void)hookRemoveObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        [self hookRemoveObjectAtIndex:index];
    }
}

- (void)hookInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject && index <= self.count) {
        [self hookInsertObject:anObject atIndex:index];
    }
}

- (void)hookReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index < self.count && anObject) {
        [self hookReplaceObjectAtIndex:index withObject:anObject];
    }
}

@end

