//
//  ViewController.m
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/9.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testNSArray];
    [self testNSMutableArray];
}

- (void)testNSArray
{
    //__NSArrayI
    NSArray *arrayI = [NSArray arrayWithObjects:@1, @2, nil];
    [arrayI objectAtIndex:4];
    
    //__NSArray0
    NSArray *array0 = [NSArray arrayWithArray:nil];
    [array0 objectAtIndex:4];
    
    //__NSSingleObjectArrayI
    NSArray *singleObjectArrayI = [NSArray arrayWithObjects:@1, nil];
    [singleObjectArrayI objectAtIndex:4];
}

- (void)testNSMutableArray
{
    NSMutableArray *mArray=[NSMutableArray arrayWithObjects:@1, @2, nil];
    
    [mArray addObject:nil];
    
    [mArray objectAtIndex:5];
    
    [mArray removeObjectAtIndex:5];
    
    [mArray insertObject:@6 atIndex:5];
    
    [mArray replaceObjectAtIndex:5 withObject:@6];
}


@end
