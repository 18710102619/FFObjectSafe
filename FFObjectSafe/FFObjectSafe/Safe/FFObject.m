//
//  FFObject.m
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/10.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "FFObject.h"
#import <objc/runtime.h>

void fun (id self, SEL sel);

@implementation FFObject

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    Class class=[self class];
    Method method=class_getClassMethod(class, sel);
    
    IMP imp=method_getImplementation(method);
    if(imp==nil) {
        class_addMethod(self, sel, (IMP)fun, "v@:");
        NSLog(@"resolveInstanceMethod：%s %s",class_getName(class),sel_getName(sel));
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

void fun (id self , SEL sel)
{
    NSLog(@"resolveInstanceMethod...............");
}

@end
