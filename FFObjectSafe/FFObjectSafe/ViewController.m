//
//  ViewController.m
//  FFObjectSafe
//
//  Created by 张玲玉 on 2017/1/9.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "ViewController.h"
#import "FFPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testNSObject];
    
    [self testNSArray];
    [self testNSMutableArray];
    
    [self testNSDictionary];
    [self testNSMutableDictionary];
}

- (void)testNSObject
{
    FFPerson *per=[[FFPerson alloc]init];
    
    [per valueForKey:nil];
    
    [per setValue:nil forKey:@"age"];
    
    [per addObserver:nil forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [per removeObserver:self forKeyPath:@"name" context:nil];
    
//    [FFObject classMethod];
    [per instanceMethod];
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
    
    id value=arrayI[4]; //字面量写法
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

- (void)testNSDictionary
{
    //__NSDictionaryI
    NSDictionary *dictI = [[NSDictionary alloc] initWithObjectsAndKeys:@0, @"0", @1, @"1",nil];
    [dictI objectForKey:nil];

    //__NSDictionary0
    NSDictionary *dict0 = [NSDictionary dictionaryWithObject:nil forKey:@"0"];
    [dictI objectForKey:nil];
    
    //__NSArraySingleEntryDictionaryI
    NSDictionary *singleDictI = [[NSDictionary alloc] initWithObjectsAndKeys:@0, @"0", nil];
    [dictI objectForKey:nil];
}

- (void)testNSMutableDictionary
{
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@0, @"0", @1, @"1",nil];
    
    [mDict objectForKey:nil];
    
    [mDict setValue:nil forKey:@"0"];
    [mDict setObject:nil forKey:@"0"];
    
    [mDict removeObjectForKey:nil];
    
    mDict[@"1"]=nil; //字面量写法
}

- (void)testUserDefaults
{
    NSUserDefaults *obj = [[NSUserDefaults alloc] init];
    
    [obj objectForKey:nil];
    
    [obj setObject:nil forKey:@"setting"];
    
    [obj removeObjectForKey:nil];
}

@end
