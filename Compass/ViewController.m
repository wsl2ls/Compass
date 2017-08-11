//
//  ViewController.m
//  Compass
//
//  Created by 王双龙 on 2017/8/10.
//  Copyright © 2017年 https://github.com/wslcmk All rights reserved.
//

#import "ViewController.h"
#import "CompassViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)buttonClicked:(id)sender {
    CompassViewController * vc = [[CompassViewController alloc] init];
    
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
