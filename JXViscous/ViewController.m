//
//  ViewController.m
//  JXViscous
//
//  Created by 王加祥 on 16/5/9.
//  Copyright © 2016年 Wangjiaxiang. All rights reserved.
//

#import "ViewController.h"
#import "JXViscous.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JXViscous * viscousBtn = [[JXViscous alloc] init];
    viscousBtn.bounds = CGRectMake(0, 0, 30, 30);
    viscousBtn.center = self.view.center;
    viscousBtn.viscousCount = 89;
    [self.view addSubview:viscousBtn];
    
}

@end
