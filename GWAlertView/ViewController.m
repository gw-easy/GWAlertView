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
@property (weak, nonatomic) IBOutlet UIButton *iconAndOneMessage;
@property (weak, nonatomic) IBOutlet UIButton *iconAndTwoMessage2;
@property (weak, nonatomic) IBOutlet UIButton *onlyIcon;
@property (weak, nonatomic) IBOutlet UIButton *threeMessage;
@property (weak, nonatomic) IBOutlet UIButton *textAlert;

@end

@implementation ViewController
- (IBAction)iconAndOneMessageAction:(id)sender {
    GWAlertView *alert = [[GWAlertView alloc] initWithIcon:@"111" message:@"lihaile" delegate:self buttonTitles:@"queding",@"quxiao",nil];
    [alert showInView:self.view];
}

- (IBAction)iconAndTwoMessage2Action:(id)sender {
    GWAlertView *alert3 = [[GWAlertView alloc] initWithIcon:@"小太阳.gif" message:@"333" subtitle:@"5555" delegate:self buttonTitles:@"qu",@"shi",nil];
    [alert3 showInView:self.view];
}

- (IBAction)onlyIconAction:(id)sender {
    GWAlertView *alert2 = [[GWAlertView alloc] initWithImage:@"111" delegate:self buttonTitles:@"qu",@"shi",nil];
    [alert2 showInView:self.view];
}

- (IBAction)threeMessageAction:(id)sender {
    GWAlertView *alert4 = [[GWAlertView alloc] initWithMessage1:@"23445" message2:@"66677" subtitle:@"44455" delegate:self buttonTitles:@"qu",@"shi",nil];
    [alert4 showInView:self.view];
}

- (IBAction)textAlertAction:(id)sender {
    GWAlertView *alert5 = [[GWAlertView alloc] initTextFieldAlertWithMessage:@"lihaile" ImageUrl:@"https://m.baidu.com/from=1000252h/bd_pa" CertainBtnClickBlock:^(NSString *text) {
        NSLog(@"lihaile");
    }];
    [alert5 showInView:self.view];
}


- (void)viewDidLoad {
    [super viewDidLoad];
  

    
    
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
