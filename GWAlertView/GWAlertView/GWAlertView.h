//
//  GWAlertView.h
//  AlertView
//
//  Created by gw on 2017/2/6.
//  Copyright © 2017年 gw. All rights reserved.
//

//根据@fergus_ding的demo改写
//http://code.cocoachina.com/detail/303371/自定义的AlertView/

#import <UIKit/UIKit.h>

@class GWAlertView;

@protocol GWAlertViewDelegate <NSObject>

- (void)alertView:(GWAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end


@interface GWAlertView : UIView

@property (strong, nonatomic) UILabel *subtitleLabel;
@property (weak, nonatomic)id<GWAlertViewDelegate>delegate;

@property (assign, nonatomic) int taag;
//头像下加入一条信息
- (instancetype)initWithIcon:(UIImage *)icon message:(NSString *)message delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...;
//头像下加入两条信息
- (instancetype)initWithIcon:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...;

- (instancetype)initWithIcon:(UIImage *)icon message:(NSString *)message subtitle:(NSString *)subtitle delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...;

//仅仅是图片背景的alert
- (instancetype)initWithImage:(UIImage *)image delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...;

//中间文字大，上下文字小
- (instancetype)initWithMessage1:(NSString *)message1 message2:(NSString *)message2 subtitle:(NSString *)subtitle delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...;

//带有textField的block，分享得红包成功后弹出输入验证码时所用
-(instancetype)initTextFieldAlertWithMessage:(NSString *)message ImageUrl:(NSString *)imgUrl CertainBtnClickBlock:(void (^)(NSString *text))certainBtnClickBlock;

- (void)show;
-(void)showInView:(UIView *)view;
@end
