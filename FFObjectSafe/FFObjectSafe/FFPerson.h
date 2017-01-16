//
//  FFPerson.h
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/16.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "FFObject.h"

@interface FFPerson : FFObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)int *age;

//+ (void)classMethod;
- (void)instanceMethod;

@end
