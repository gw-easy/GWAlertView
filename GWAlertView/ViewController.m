//
//  ViewController.m
//  GWAlertView
//
//  Created by gw on 2017/2/6.
//  Copyright © 2017年 gw. All rights reserved.
//

#import "ViewController.h"
#import "GWAlertView.h"
@interface ViewController ()<GWAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    GWAlertView *alert = [[GWAlertView alloc] initWithIcon:[UIImage imageNamed:@"111"] message:@"lihaile" delegate:self buttonTitles:@"queding",@"quxiao",nil];
//    [alert showInView:self.view];
//    
//    
//    GWAlertView *alert1 = [[GWAlertView alloc] initWithIcon:[UIImage imageNamed:@"111"] title:@"lllll" subtitle:@"hhhhh" delegate:self buttonTitles:@"queding",@"quxiao",nil];
//    [alert1 showInView:self.view];
//    
//    GWAlertView *alert2 = [[GWAlertView alloc] initWithImage:[UIImage imageNamed:@"111"] delegate:self buttonTitles:@"qu",@"shi",nil];
//    [alert2 showInView:self.view];
//    
//    GWAlertView *alert3 = [[GWAlertView alloc] initWithIcon:[UIImage imageNamed:@"111"] message:@"333" subtitle:@"5555" delegate:self buttonTitles:@"qu",@"shi",nil];
//    [alert3 showInView:self.view];
//    
//    GWAlertView *alert4 = [[GWAlertView alloc] initWithMessage1:@"23445" message2:@"66677" subtitle:@"44455" delegate:self buttonTitles:@"qu",@"shi",nil];
//    [alert4 showInView:self.view];
    
    GWAlertView *alert5 = [[GWAlertView alloc] initTextFieldAlertWithMessage:@"lihaile" ImageUrl:@"https://m.baidu.com/from=1000252h/bd_pa" CertainBtnClickBlock:^(NSString *text) {
        NSLog(@"lihaile");
    }];
    [alert5 showInView:self.view];
}

- (void)alertView:(GWAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"0");
    }
    else{
        NSLog(@"1");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
