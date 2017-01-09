//
//  ViewController.m
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/9.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "ViewController.h"
#import "FFObjectSafe.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *array=[NSArray arrayWithArray:nil];
    
    //__NSArrayI
    NSArray *arrayI = [NSArray arrayWithObjects:@1, @2, nil];
    [arrayI objectAtIndex:4];
    
    //__NSArray0
    NSArray *array0 = [NSArray array];
    [array0 objectAtIndex:4];
    
    //__NSSingleObjectArrayI
    NSArray *singleObjectArrayI = [NSArray arrayWithObjects:@1, nil];
    [singleObjectArrayI objectAtIndex:4];
}

@end
