//
//  FFPerson.m
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/16.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "FFPerson.h"
#import "FFCar.h"
#import <objc/runtime.h>

void fun (id self, SEL sel);

@implementation FFPerson

#pragma mark - 方案一

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    Class class=[self class];
    Method method=class_getClassMethod(class, sel);
    IMP imp=method_getImplementation(method);
    if(imp==nil) {
        class_addMethod(self, sel, (IMP)fun, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

void fun (id self , SEL sel)
{
    NSLog(@"%@:%@",NSStringFromClass([self class]),NSStringFromSelector(sel));
}

#pragma mark - 方案二

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *fun=NSStringFromSelector(aSelector);
    if ([fun isEqualToString:@"run"]) {
        return [[FFCar alloc]init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - 方案三

/**
 生成方法签名，给forwardInvocation的参数NSInvocation调用的
 当返回了一个空的方法签名时，会导致程序报错崩溃
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    Class class=[self class];
    Method method=class_getClassMethod(class, aSelector);
    IMP imp=method_getImplementation(method);
    if(imp==nil) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL sel=[anInvocation selector];
    if ([self respondsToSelector:sel]) {
        [super forwardInvocation:anInvocation];
    }
}

@end
