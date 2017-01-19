//
//  ViewController.m
//  FFCALayer
//
//  Created by 张玲玉 on 2017/1/18.
//  Copyright © 2017年 bj.zly.com. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id blueLayer = CALayer()
    blueLayer.frame = CGRectMake(100, 100, 100, 100)
    blueLayer.backgroundColor = UIColor.blueColor().CGColor
    self.view.layer.addSublayer(blueLayer);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
