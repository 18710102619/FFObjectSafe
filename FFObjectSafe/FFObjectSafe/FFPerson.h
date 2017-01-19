//
//  FFPerson.h
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/16.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFPerson : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)int *age;

- (void)eat;
- (void)run;

@end
