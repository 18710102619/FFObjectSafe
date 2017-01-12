//
//  FFObjectSafe.m
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/9.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "FFObjectSafe.h"
#import <objc/runtime.h>

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

#pragma mark - NSObject

@implementation NSObject (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSObject *obj = [[NSObject alloc] init];
        //KVC
        [obj swizzleInstanceMethod:@selector(valueForKey:) withMethod:@selector(hookValueForKey:)];
        [obj swizzleInstanceMethod:@selector(setValue:forKey:) withMethod:@selector(hookSetValue:forKey:)];
        //KVO
        [obj swizzleInstanceMethod:@selector(addObserver:forKeyPath:options:context:) withMethod:@selector(hookAddObserver:forKeyPath:options:context:)];
        [obj swizzleInstanceMethod:@selector(removeObserver:forKeyPath:) withMethod:@selector(hookRemoveObserver:forKeyPath:)];
   
    });
}

- (id)hookValueForKey:(NSString *)key
{
    if (key) {
        return [self hookValueForKey:key];
    }
    return nil;
}

- (void)hookSetValue:(id)value forKey:(NSString *)key
{
    if (value && key) {
        [self hookSetValue:value forKey:key];
    }
}

- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if (observer || keyPath) {
        return;
    }
    @try {
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    }
    @catch (NSException *exception) {
        NSLog(@"hookAddObserver ex: %@", [exception callStackSymbols]);
    }
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    if (!observer || !keyPath.length) {
        return;
    }
    @try {
        [self hookRemoveObserver:observer forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        NSLog(@"hookRemoveObserver ex: %@", [exception callStackSymbols]);
    }
}

@end

#pragma mark - NSString

@implementation NSString (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSString swizzleClassMethod:@selector(stringWithUTF8String:) withMethod:@selector(hookStringWithUTF8String:)];
        
        NSString *str = [[NSString alloc] init];
        [str swizzleInstanceMethod:@selector(stringByAppendingString:) withMethod:@selector(hookStringByAppendingString:)];
        [str swizzleInstanceMethod:@selector(substringFromIndex:) withMethod:@selector(hookSubstringFromIndex:)];
        [str swizzleInstanceMethod:@selector(substringToIndex:) withMethod:@selector(hookSubstringToIndex:)];
        [str swizzleInstanceMethod:@selector(substringWithRange:) withMethod:@selector(hookSubstringWithRange:)];
    });
}

+ (NSString *)hookStringWithUTF8String:(const char *)nullTerminatedCString
{
    if (nullTerminatedCString) {
        return [self hookStringWithUTF8String:nullTerminatedCString];
    }
    return nil;
}

- (NSString *)hookStringByAppendingString:(NSString *)aString
{
    if (aString){
        return [self hookStringByAppendingString:aString];
    }
    return self;
}

- (NSString *)hookSubstringFromIndex:(NSUInteger)from
{
    if (from <= self.length) {
        return [self hookSubstringFromIndex:from];
    }
    return nil;
}

- (NSString *)hookSubstringToIndex:(NSUInteger)to
{
    if (to <= self.length) {
        return [self hookSubstringToIndex:to];
    }
    return self;
}

- (NSString *)hookSubstringWithRange:(NSRange)range
{
    if (range.location + range.length <= self.length) {
        return [self hookSubstringWithRange:range];
    }
    else if (range.location < self.length) {
        return [self hookSubstringWithRange:NSMakeRange(range.location, self.length-range.location)];
    }
    return nil;
}

@end

@implementation NSMutableString (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableString *str = [[NSMutableString alloc] init];
        [str swizzleInstanceMethod:@selector(appendString:) withMethod:@selector(hookAppendString:)];
        [str swizzleInstanceMethod:@selector(insertString:atIndex:) withMethod:@selector(hookInsertString:atIndex:)];
        [str swizzleInstanceMethod:@selector(deleteCharactersInRange:) withMethod:@selector(hookDeleteCharactersInRange:)];
        [str swizzleInstanceMethod:@selector(stringByAppendingString:) withMethod:@selector(hookStringByAppendingString:)];
        [str swizzleInstanceMethod:@selector(substringFromIndex:) withMethod:@selector(hookSubstringFromIndex:)];
        [str swizzleInstanceMethod:@selector(substringToIndex:) withMethod:@selector(hookSubstringToIndex:)];
        [str swizzleInstanceMethod:@selector(substringWithRange:) withMethod:@selector(hookSubstringWithRange:)];
    });
}

- (void)hookAppendString:(NSString *)aString
{
    if (aString) {
        [self hookAppendString:aString];
    }
}

- (void)hookInsertString:(NSString *)aString atIndex:(NSUInteger)loc
{
    if (aString && loc <= self.length) {
        [self hookInsertString:aString atIndex:loc];
    }
}

- (void)hookDeleteCharactersInRange:(NSRange)range
{
    if (range.location + range.length <= self.length) {
        [self hookDeleteCharactersInRange:range];
    }
}

- (NSString *)hookStringByAppendingString:(NSString *)aString
{
    if (aString){
        return [self hookStringByAppendingString:aString];
    }
    return self;
}

- (NSString *)hookSubstringFromIndex:(NSUInteger)from
{
    if (from <= self.length) {
        return [self hookSubstringFromIndex:from];
    }
    return nil;
}

- (NSString *)hookSubstringToIndex:(NSUInteger)to
{
    if (to <= self.length) {
        return [self hookSubstringToIndex:to];
    }
    return self;
}

- (NSString *)hookSubstringWithRange:(NSRange)range
{
    if (range.location + range.length <= self.length) {
        return [self hookSubstringWithRange:range];
    }
    else if (range.location < self.length) {
        return [self hookSubstringWithRange:NSMakeRange(range.location, self.length-range.location)];
    }
    return nil;
}

@end

#pragma mark - NSArray

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

#pragma mark - NSMutableArray

@implementation NSMutableArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        [mArray swizzleInstanceMethod:@selector(addObject:) withMethod:@selector(hookAddObject:)];
        [mArray swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(hookObjectAtIndex:)];
        [mArray swizzleInstanceMethod:@selector(removeObjectAtIndex:) withMethod:@selector(hookRemoveObjectAtIndex:)];
        [mArray swizzleInstanceMethod:@selector(insertObject:atIndex:) withMethod:@selector(hookInsertObject:atIndex:)];
        [mArray swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:) withMethod:@selector(hookReplaceObjectAtIndex:withObject:)];
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

#pragma mark - NSDictionary

@implementation NSDictionary (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 类方法
        [NSDictionary swizzleClassMethod:@selector(dictionaryWithObject:forKey:) withMethod:@selector(hookDictionaryWithObject:forKey:)];
        
        //__NSDictionaryI
        NSDictionary *dictI = [[NSDictionary alloc] initWithObjectsAndKeys:@0, @"0", @1, @"1",nil];
        [dictI swizzleInstanceMethod:@selector(objectForKey:) withMethod:@selector(hookObjectForKey:)];
        
        //__NSDictionary0
        NSDictionary *dict0 = [[NSDictionary alloc] init];
        [dict0 swizzleInstanceMethod:@selector(objectForKey:) withMethod:@selector(hookObjectForKey:)];
        
        //__NSArraySingleEntryDictionaryI
        NSDictionary *singleDictI = [[NSDictionary alloc] initWithObjectsAndKeys:@0, @"0", nil];
        [singleDictI swizzleInstanceMethod:@selector(objectForKey:) withMethod:@selector(hookObjectForKey:)];
        
    });
}

+ (instancetype) hookDictionaryWithObject:(id)object forKey:(id)key
{
    if (object && key) {
        return [self hookDictionaryWithObject:object forKey:key];
    }
    return nil;
}

- (id)hookObjectForKey:(id)aKey
{
    if (aKey) {
        return [self hookObjectForKey:aKey];
    }
    return nil;
}

@end

#pragma mark - NSMutableDictionary

@implementation NSMutableDictionary (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *mDict=[[NSMutableDictionary alloc] init];
        [mDict swizzleInstanceMethod:@selector(objectForKey:) withMethod:@selector(hookObjectForKey:)];
        [mDict swizzleInstanceMethod:@selector(setObject:forKey:) withMethod:@selector(hookSetObject:forKey:)];
        [mDict swizzleInstanceMethod:@selector(removeObjectForKey:) withMethod:@selector(hookRemoveObjectForKey:)];

    });
}

- (id)hookObjectForKey:(id)aKey
{
    if (aKey) {
        return [self hookObjectForKey:aKey];
    }
    return nil;
}

- (void)hookSetObject:(id)anObject forKey:(id)aKey
{
    if (anObject && aKey) {
        [self hookSetObject:anObject forKey:aKey];
    }
}

- (void)hookRemoveObjectForKey:(id)aKey
{
    if (aKey) {
        [self hookRemoveObjectForKey:aKey];
    }
}

@end

#pragma mark - NSUserDefaults

@implementation NSUserDefaults (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *obj = [[NSUserDefaults alloc] init];
        [obj swizzleInstanceMethod:@selector(objectForKey:) withMethod:@selector(hookObjectForKey:)];
        [obj swizzleInstanceMethod:@selector(setObject:forKey:) withMethod:@selector(hookSetObject:forKey:)];
        [obj swizzleInstanceMethod:@selector(removeObjectForKey:) withMethod:@selector(hookRemoveObjectForKey:)];
    });
}

- (id)hookObjectForKey:(NSString *)defaultName
{
    if (defaultName) {
        return [self hookObjectForKey:defaultName];
    }
    return nil;
}

- (void)hookSetObject:(id)value forKey:(NSString *)defaultName
{
    if (value && defaultName) {
        [self hookSetValue:value forKey:defaultName];
    }
}

- (void)hookRemoveObjectForKey:(NSString *)defaultName
{
    if (defaultName) {
        [self hookRemoveObjectForKey:defaultName];
    }
}

@end

