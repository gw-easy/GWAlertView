//
//  GWAlertView.m
//  AlertView
//
//  Created by gw on 2017/2/6.
//  Copyright © 2017年 gw. All rights reserved.
//

#import "GWAlertView.h"
#import "UIImageView+WebCache.h"
//#define OrangeColor [UIColor colorWithRed:254/255.0 green:164/255.0 blue:28/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define MessageFont 17
#define Padding 60

#define SubTitleHeight 20

@interface GWAlertView()<UIWebViewDelegate>
{
    BOOL _ifTranslated;
}
@property (nonatomic, copy) NSString *transedHtmlStr;
@property (strong, nonatomic) UIView *mainView;


//@property (nonatomic, strong) UIImageView *verifyImgView;//验证码的图片
@property (nonatomic, strong) UIWebView *verifyWebView;
@property (nonatomic, strong) UITextField *verfyTextField;//验证码输入框
@property (nonatomic, strong) UIButton *refreshVerifyImgBtn;//刷新验证码图片的按钮
@property (nonatomic, copy) void (^CertainBtnClickBlock)(NSString *text);


@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) UIImageView *iconImageView;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (assign, nonatomic) NSString *message;
@property (strong, nonatomic) UILabel *messageLabel;
@property (assign, nonatomic) NSString *subtitle;


@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSMutableArray *buttonTitleArray;
@end

CGFloat mainViewWidth;
CGFloat mainViewHeight;

CGFloat SubTitleAllHeight;
CGFloat SubTitlePadding;

@implementation GWAlertView


#pragma mark - 原有的方法，未动过


- (instancetype)initWithIcon:(UIImage *)icon message:(NSString *)message delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self)
    {
        [self setBackgroundColor:RGBACOLOR(0, 0, 0, 0.3)];
        
        _icon               = icon;
        _message            = message;
        _delegate           = delegate;
        _buttonArray        = [NSMutableArray array];
        _buttonTitleArray   = [NSMutableArray array];
		
		SubTitleAllHeight = 0;
		SubTitlePadding = 0;
		
        va_list args;
        va_start(args, buttonTitles);
        if (buttonTitles)
        {
            [_buttonTitleArray addObject:buttonTitles];
            while (1)
            {
                NSString * otherButtonTitle = va_arg(args, NSString *);
                if(otherButtonTitle == nil)
				{
                    break;
                } else
				{
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
        }
        va_end(args);
        
        [self initMainView];
        [self startAnimation];
    }
    
    return self;
}

- (instancetype)initWithIcon:(UIImage *)icon message:(NSString *)message subtitle:(NSString *)subtitle delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...
{
	self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
	if (self)
	{
		[self setBackgroundColor:RGBACOLOR(0, 0, 0, 0.3)];
		
		_icon               = icon;
		_message            = message;
		_delegate           = delegate;
		_buttonArray        = [NSMutableArray array];
		_buttonTitleArray   = [NSMutableArray array];
		if (subtitle != nil) _subtitle = subtitle;
		
		SubTitlePadding = 10;
		SubTitleAllHeight = SubTitleHeight + SubTitlePadding;

		va_list args;
		va_start(args, buttonTitles);
		if (buttonTitles)
		{
			[_buttonTitleArray addObject:buttonTitles];
			while (1)
			{
				NSString *  otherButtonTitle = va_arg(args, NSString *);
				if(otherButtonTitle == nil)
				{
					break;
				} else
				{
					[_buttonTitleArray addObject:otherButtonTitle];
				}
			}
		}
		va_end(args);
		
		[self initMainView];
		[self startAnimation];
	}
	
	return self;
}

- (void)initMainView
{
//	540 810
    mainViewWidth = [UIScreen mainScreen].bounds.size.width==736?405:270;
    mainViewHeight = 0;
    NSLog(@"%f",mainViewWidth);
    _mainView = [[UIView alloc] init];
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.layer.cornerRadius = 10;
    _mainView.layer.masksToBounds = YES;
    
    [self initIcon];
    [self initMessage];
    [self initAllButtons];
    
    _mainView.frame = CGRectMake(0, 0, mainViewWidth, mainViewHeight);
    _mainView.center = self.center;
    [self addSubview:_mainView];
}

- (void)initIcon
{
    if (_icon != nil)
    {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor whiteColor];
        _iconImageView.image = _icon;
        _iconImageView.frame = CGRectMake(mainViewWidth/2-25, 15, 50, 50);
        [_mainView addSubview:_iconImageView];
        mainViewHeight += _iconImageView.frame.size.height + 15;
    }
}

- (void)initMessage
{
    if (_message != nil)
    {
        _messageLabel = [[UILabel alloc] init];
        
        //设置行间距
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_message];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5.0];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _message.length)];
        _messageLabel.attributedText = attributedString;

        _messageLabel.backgroundColor = [UIColor whiteColor];
        _messageLabel.textColor = RGBACOLOR(50, 50, 50, 1.0);
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:MessageFont];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
		
        CGSize messageSize = [self getMessageSize];
        
        if (_icon != nil)
        {
            _messageLabel.frame = CGRectMake(30, 80, mainViewWidth - 60, messageSize.height);

        }else
        {
            _messageLabel.frame = CGRectMake(30, 15, mainViewWidth - 60, messageSize.height);
        }
        [_mainView addSubview:_messageLabel];
        mainViewHeight += _messageLabel.frame.size.height + 15;
		
		if (_subtitle != nil)
		{
			_subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_messageLabel.frame) + SubTitlePadding, mainViewWidth, SubTitleHeight)];
			_subtitleLabel.backgroundColor = [UIColor whiteColor];
			_subtitleLabel.text = _subtitle;
			_subtitleLabel.textColor = RGBACOLOR(50, 50, 50, 1.0);
			_subtitleLabel.font = [UIFont systemFontOfSize:13];
			_subtitleLabel.textAlignment = NSTextAlignmentCenter;
			[_mainView addSubview:_subtitleLabel];
			mainViewHeight += SubTitleHeight;
		}
    }
}

-(void)initBackGroundImage
{
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.backgroundColor = [UIColor whiteColor];
    _backgroundImageView.image = _backgroundImage;
    CGFloat retio = _backgroundImage.size.height / _backgroundImage.size.width;
    
    _backgroundImageView.frame = CGRectMake(0, 0, mainViewWidth, mainViewWidth * retio);
    [_mainView addSubview:_backgroundImageView];
    mainViewHeight += _backgroundImageView.frame.size.height;
}

- (void)initAllButtons
{
    if (_buttonTitleArray.count > 0)
    {
        UIView *horizonSperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_messageLabel.frame) + 15 + SubTitleAllHeight, mainViewWidth, 0.5)];
        mainViewHeight += 15 + 45 + SubTitlePadding;
        
        if (_backgroundImage)
		{
            horizonSperatorView.frame = CGRectMake(0, _backgroundImageView.frame.size.height, mainViewWidth, 0.5);
            mainViewHeight -= 15 + SubTitlePadding;
        }
        horizonSperatorView.backgroundColor = RGBACOLOR(175, 175, 188, 1.0);
        [_mainView addSubview:horizonSperatorView];
        
        CGFloat buttonWidth = mainViewWidth / _buttonTitleArray.count;
        for (NSString *buttonTitle in _buttonTitleArray)
        {
            NSInteger index = [_buttonTitleArray indexOfObject:buttonTitle];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(index * buttonWidth, CGRectGetMaxY(horizonSperatorView.frame), buttonWidth, 44)];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            if (_buttonTitleArray.count != 1)
            {
                if (index == 0)
                {
                    [button setTitleColor:RGBACOLOR(150, 150, 150, 1.0) forState:UIControlStateNormal];
                }else
                {
                    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                }
            }else
            {
                [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }

            [button addTarget:self action:@selector(buttonWithPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonArray addObject:button];
            [_mainView addSubview:button];
            
            if (index < _buttonTitleArray.count - 1)
            {
                UIView *verticalSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, button.frame.origin.y, 0.5, button.frame.size.height)];
                verticalSeperatorView.backgroundColor = RGBACOLOR(175, 175, 188, 1.0);
                [_mainView addSubview:verticalSeperatorView];
            }
        }
    }
}

- (CGSize)getMessageSize
{
    UIFont *font = [UIFont systemFontOfSize:MessageFont];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [_message boundingRectWithSize:CGSizeMake(mainViewWidth - (30 + 30), 2000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes context:nil].size;
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    return size;
}

- (void)startAnimation
{
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.removedOnCompletion = YES;
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.duration = 0.20;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    scaleAnim.values = values;
    [_mainView.layer addAnimation:scaleAnim forKey:nil];
}

- (void)buttonWithPressed:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
    {
        NSInteger index = [_buttonTitleArray indexOfObject:button.titleLabel.text];
        [_delegate alertView:self clickedButtonAtIndex:index];
    }
    [self disimss];
}

- (void)show
{
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
	BOOL ifShow = YES;
	
	for (id temp in keywindow.subviews)
	{
		if ([temp isKindOfClass:[GWAlertView class]])
		{
			GWAlertView *tempAlert = (GWAlertView *)temp;
			if ([tempAlert.message isEqualToString:_message])
			{
				ifShow = NO;
			}
		}
	}
	
	if (ifShow)[keywindow addSubview:self];
}

- (void)disimss
{
    [self removeFromSuperview];
}
- (instancetype)initWithIcon:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self)
    {
        [self setBackgroundColor:RGBACOLOR(0, 0, 0, 0.3)];
        
        _icon               = icon;
        _message            = title;
        _delegate           = delegate;
        _buttonArray        = [NSMutableArray array];
        _buttonTitleArray   = [NSMutableArray array];
        if (subtitle != nil) _subtitle = subtitle;
        
        SubTitlePadding = 10;
        SubTitleAllHeight = [self getSubTitleSize].height + SubTitlePadding;
        
        va_list args;
        va_start(args, buttonTitles);
        if (buttonTitles)
        {
            [_buttonTitleArray addObject:buttonTitles];
            while (1)
            {
                NSString *  otherButtonTitle = va_arg(args, NSString *);
                if(otherButtonTitle == nil)
                {
                    break;
                } else
                {
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
        }
        va_end(args);
        
        mainViewWidth = [UIScreen mainScreen].bounds.size.width  == 736?405:270;;
        mainViewHeight = 0;
        
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.layer.cornerRadius = 10;
        _mainView.layer.masksToBounds = YES;
        
        [self initIcon];
        
        if (_message != nil)
        {
            _messageLabel = [[UILabel alloc] init];
            
            //设置行间距
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_message];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:5.0];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _message.length)];
            _messageLabel.attributedText = attributedString;
            
            //			_messageLabel.backgroundColor = [UIColor lightGrayColor];
            _messageLabel.textColor = RGBACOLOR(50, 50, 50, 1.0);
            _messageLabel.numberOfLines = 0;
            _messageLabel.font = [UIFont systemFontOfSize:MessageFont];
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            
            CGSize messageSize = [self getMessageSize];
            
            if (_icon != nil)
            {
                _messageLabel.frame = CGRectMake(30, 80, mainViewWidth - 60, messageSize.height);
                
            }else
            {
                _messageLabel.frame = CGRectMake(30, 15, mainViewWidth - 60, messageSize.height);
            }
            [_mainView addSubview:_messageLabel];
            mainViewHeight += _messageLabel.frame.size.height + 15;
            
            if (_subtitle != nil)
            {
                _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(_messageLabel.frame) + SubTitlePadding, mainViewWidth - 60, [self getSubTitleSize].height)];
                //				_subtitleLabel.backgroundColor = [UIColor yellowColor];
                _subtitleLabel.text = _subtitle;
                _subtitleLabel.numberOfLines = 0;
                _subtitleLabel.textColor = RGBACOLOR(50, 50, 50, 1.0);
                _subtitleLabel.font = [UIFont systemFontOfSize:14];
                _subtitleLabel.textAlignment = NSTextAlignmentCenter;
                [_mainView addSubview:_subtitleLabel];
                mainViewHeight += [self getSubTitleSize].height;
            }
        }
        
        if (_buttonTitleArray.count > 0)
        {
            UIView *horizonSperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_subtitleLabel.frame) + 15, mainViewWidth, 0.5)];
            mainViewHeight += 15 + 45 + SubTitlePadding;
            
            if (_backgroundImage)
            {
                horizonSperatorView.frame = CGRectMake(0, _backgroundImageView.frame.size.height, mainViewWidth, 0.5);
                mainViewHeight -= 15 + SubTitlePadding;
            }
            horizonSperatorView.backgroundColor = RGBACOLOR(175, 175, 188, 1.0);
            [_mainView addSubview:horizonSperatorView];
            
            CGFloat buttonWidth = mainViewWidth / _buttonTitleArray.count;
            for (NSString *buttonTitle in _buttonTitleArray)
            {
                NSInteger index = [_buttonTitleArray indexOfObject:buttonTitle];
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(index * buttonWidth, CGRectGetMaxY(horizonSperatorView.frame), buttonWidth, 44)];
                button.titleLabel.font = [UIFont systemFontOfSize:16];
                [button setTitle:buttonTitle forState:UIControlStateNormal];
                if (_buttonTitleArray.count != 1)
                {
                    if (index == 0)
                    {
                        [button setTitleColor:RGBACOLOR(150, 150, 150, 1.0) forState:UIControlStateNormal];
                    }else
                    {
                        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    }
                }else
                {
                    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                }
                
                [button addTarget:self action:@selector(buttonWithPressed:) forControlEvents:UIControlEventTouchUpInside];
                [_buttonArray addObject:button];
                [_mainView addSubview:button];
                
                if (index < _buttonTitleArray.count - 1)
                {
                    UIView *verticalSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, button.frame.origin.y, 0.5, button.frame.size.height)];
                    verticalSeperatorView.backgroundColor = RGBACOLOR(175, 175, 188, 1.0);
                    [_mainView addSubview:verticalSeperatorView];
                }
            }
        }
        
        _mainView.frame = CGRectMake(0, 0, mainViewWidth, mainViewHeight);
        _mainView.center = self.center;
        [self addSubview:_mainView];
        
        [self startAnimation];
    }
    
    return self;
}

- (CGSize)getSubTitleSize
{
    UIFont *font = [UIFont systemFontOfSize:14];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [_subtitle boundingRectWithSize:CGSizeMake(mainViewWidth - (30 + 30), 2000)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes context:nil].size;
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    return size;
}
#pragma mark - 有3个标题的alert，曾经首页下单时弹出框用过
- (instancetype)initWithMessage1:(NSString *)message1 message2:(NSString *)message2 subtitle:(NSString *)subtitle delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self)
    {
        [self setBackgroundColor:RGBACOLOR(0, 0, 0, 0.3)];
		
        _delegate           = delegate;
        _buttonArray        = [NSMutableArray array];
        _buttonTitleArray   = [NSMutableArray array];
        if (subtitle != nil) _subtitle = subtitle;
        
        SubTitlePadding = 10;
        SubTitleAllHeight = SubTitleHeight + SubTitlePadding;
        
        va_list args;
        va_start(args, buttonTitles);
        if (buttonTitles)
        {
            [_buttonTitleArray addObject:buttonTitles];
            while (1)
            {
                NSString *  otherButtonTitle = va_arg(args, NSString *);
                if(otherButtonTitle == nil)
				{
                    break;
                } else
				{
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
        }
        va_end(args);
        
        mainViewWidth = [UIScreen mainScreen].bounds.size.width  == 736?405:270;;
        mainViewHeight = 155;
        
        _mainView = [[UIView alloc] init];
        _mainView.frame = CGRectMake(0, 0, mainViewWidth, mainViewHeight);
        
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.layer.cornerRadius = 10;
        _mainView.layer.masksToBounds = YES;
        
        UILabel *messageLabel1 = [[UILabel alloc] init];
        messageLabel1.text = message1;
        messageLabel1.frame = CGRectMake(0, 20, mainViewWidth, 20);
        messageLabel1.textColor = RGBACOLOR(100, 100, 100, 1);
        messageLabel1.numberOfLines = 0;
        messageLabel1.font = [UIFont systemFontOfSize:14];
        messageLabel1.textAlignment = NSTextAlignmentCenter;
        [_mainView addSubview:messageLabel1];

        if (message2 != nil)
        {
            _messageLabel = [[UILabel alloc] init];
            
            //设置行间距
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message2];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:5.0];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, message2.length)];
            _messageLabel.attributedText = attributedString;
            _messageLabel.backgroundColor = [UIColor whiteColor];
            _messageLabel.textColor = RGBACOLOR(255, 137, 3, 1.0);
            _messageLabel.numberOfLines = 0;
            _messageLabel.font = [UIFont systemFontOfSize:21];
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            _messageLabel.frame = CGRectMake(0, CGRectGetMaxY(messageLabel1.frame)+5, mainViewWidth, 25);
			
            [_mainView addSubview:_messageLabel];
			
            if (_subtitle != nil)
            {
                _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_messageLabel.frame) + SubTitlePadding, mainViewWidth, SubTitleHeight)];
                _subtitleLabel.backgroundColor = [UIColor whiteColor];
                _subtitleLabel.text = _subtitle;
                _subtitleLabel.textColor = RGBACOLOR(150, 150, 150, 1.0);
                _subtitleLabel.font = [UIFont systemFontOfSize:12];
                _subtitleLabel.textAlignment = NSTextAlignmentCenter;
                [_mainView addSubview:_subtitleLabel];
                mainViewHeight += SubTitleHeight;
            }
        }
        
        if (_buttonTitleArray.count > 0)
        {
            UIView *horizonSperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_subtitleLabel.frame)+5, mainViewWidth, 0.5)];
            mainViewHeight += 15 + 45 + SubTitlePadding;
            
            horizonSperatorView.backgroundColor = RGBACOLOR(175, 175, 188, 1.0);
            [_mainView addSubview:horizonSperatorView];
            
            CGFloat buttonWidth = mainViewWidth / _buttonTitleArray.count;
            for (NSString *buttonTitle in _buttonTitleArray)
            {
                NSInteger index = [_buttonTitleArray indexOfObject:buttonTitle];
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(index * buttonWidth, CGRectGetMaxY(horizonSperatorView.frame), buttonWidth, 44)];
                button.titleLabel.font = [UIFont systemFontOfSize:16];
                [button setTitle:buttonTitle forState:UIControlStateNormal];
                if (_buttonTitleArray.count != 1)
                {
                    if (index == 0)
                    {
                        [button setTitleColor:RGBACOLOR(150, 150, 150, 1.0) forState:UIControlStateNormal];
                    }else
                    {
                        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    }
                }else
                {
                    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                }
                
                [button addTarget:self action:@selector(buttonWithPressed:) forControlEvents:UIControlEventTouchUpInside];
                [_buttonArray addObject:button];
                [_mainView addSubview:button];
                
                if (index < _buttonTitleArray.count - 1)
                {
                    UIView *verticalSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, button.frame.origin.y, 0.5, button.frame.size.height)];
                    verticalSeperatorView.backgroundColor = RGBACOLOR(175, 175, 188, 1.0);
                    [_mainView addSubview:verticalSeperatorView];
                }
            }
        }
        
        _mainView.center = self.center;
        [self addSubview:_mainView];
		
        [self startAnimation];
    }
    
    return self;
}


#pragma mark - 带有textField的alert
-(instancetype)initTextFieldAlertWithMessage:(NSString *)message ImageUrl:(NSString *)imgUrl CertainBtnClickBlock:(void (^)(NSString *text))certainBtnClickBlock{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self setBackgroundColor:RGBACOLOR(0, 0, 0, 0.3)];
    _message            = message;
    _CertainBtnClickBlock = certainBtnClickBlock;
    
    mainViewWidth = [UIScreen mainScreen].bounds.size.width  == 736?405:270;
    mainViewHeight = 0;
    
    _mainView = [[UIView alloc] init];
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.layer.cornerRadius = 10;
    _mainView.layer.masksToBounds = YES;
    
    
    
    //添加messageLabel
    [self initMessage];
    //添加验证码图片
    _verifyWebView = [[UIWebView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_messageLabel.frame)+20, 115, 44)];
    _verifyWebView.scrollView.scrollEnabled = NO;
    _verifyWebView.delegate = self;
    _verifyWebView.hidden = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imgUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    [_verifyWebView loadRequest:request];

    
    _verfyTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_verifyWebView.frame) + 15, _verifyWebView.frame.size.height, 100, 44)];
    _verfyTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    
    _refreshVerifyImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _refreshVerifyImgBtn.frame = CGRectMake(_verifyWebView.frame.size.width, CGRectGetMaxY(_verifyWebView.frame) + 5, 115, 23);
    [_refreshVerifyImgBtn setTitle:@"看不清？" forState:UIControlStateNormal];
    _refreshVerifyImgBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [_refreshVerifyImgBtn setTitleColor:RGBACOLOR(163, 163, 163, 1) forState:UIControlStateNormal];
    _refreshVerifyImgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_refreshVerifyImgBtn addTarget:self action:@selector(reloadWeb) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *horizonSperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_refreshVerifyImgBtn.frame) + 10, mainViewWidth, 0.5)];
    horizonSperatorView.backgroundColor = RGBACOLOR(220, 220, 220, 1);
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(horizonSperatorView.frame), mainViewWidth, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setTitleColor:RGBACOLOR(255, 137, 3, 1) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(certainBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainView addSubview:_verifyWebView];
    [_mainView addSubview:_verfyTextField];
    [_mainView addSubview:_refreshVerifyImgBtn];
    [_mainView addSubview:horizonSperatorView];
    [_mainView addSubview:button];
    
    
    _mainView.frame = CGRectMake(0, 0, mainViewWidth, CGRectGetMaxY(button.frame));
    _mainView.center = self.center;
    [self addSubview:_mainView];
    [self startAnimation];
    
    return self;
    
    
}


-(void)certainBtnClick{
    if (_CertainBtnClickBlock){
        
        _CertainBtnClickBlock(_verfyTextField.text);
    }
    [self disimss];
}

-(void)showInView:(UIView *)view{
    [view addSubview:self];
}
//-(void)webViewDidFinishLoad:(UIWebView *)webView{
//    _verifyWebView.scrollView.scrollEnabled = NO;
//    _verifyWebView.scalesPageToFit = YES;
//    webView.scrollView.contentOffset = CGPointMake((webView.scrollView.contentSize.width - 115 )*0.5, 0);
//}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    webView.hidden = NO;
//    if (_ifTranslated){
//        webView.hidden = NO;
//        return;
//    }
//    
//    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
//    NSString *HTMLSource = [self.verifyWebView stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
//    
//    
//    NSString *newHTMLString = [self translatedHtml:HTMLSource];
//    _ifTranslated = YES;
//    self.transedHtmlStr = newHTMLString;
//    [webView loadHTMLString:newHTMLString baseURL:nil];
    
}

-(void)reloadWeb{
    if (self.transedHtmlStr) {
        
        [self.verifyWebView loadHTMLString:self.transedHtmlStr baseURL:nil];
    }
}

-(NSString *)translatedHtml:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while(text == nil)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<img" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@"src=" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:text withString:@"<img "];
    }
    
    return html;
}

#pragma mark - 仅有图片背景的alert
-(instancetype)initWithImage:(UIImage *)image delegate:(id<GWAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ...
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self)
    {
        [self setBackgroundColor:RGBACOLOR(0, 0, 0, 0.3)];
        _backgroundImage = image;
        _delegate           = delegate;
        _buttonArray        = [NSMutableArray array];
        _buttonTitleArray   = [NSMutableArray array];
        
        SubTitleAllHeight = 0;
        SubTitlePadding = 0;
        
        va_list args;
        va_start(args, buttonTitles);
        if (buttonTitles)
        {
            [_buttonTitleArray addObject:buttonTitles];
            while (1)
            {
                NSString *  otherButtonTitle = va_arg(args, NSString *);
                if(otherButtonTitle == nil)
                {
                    break;
                } else
                {
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
        }
        va_end(args);
        
        mainViewWidth = [UIScreen mainScreen].bounds.size.width  == 736?405:270;;
        mainViewHeight = 0;
        
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.layer.cornerRadius = 10;
        _mainView.layer.masksToBounds = YES;
        
        
        [self initBackGroundImage];
        [self initAllButtons];
        
        _mainView.frame = CGRectMake(0, 0, mainViewWidth, mainViewHeight);
        _mainView.center = self.center;
        [self addSubview:_mainView];
        [self startAnimation];
    }
    
    return self;
}



@end
