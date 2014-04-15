//
//  MAViewFilePasswordManager.m
//  VoiceControl
//
//  Created by yons on 14-1-13.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewFilePasswordManager.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MADataManager.h"
#import "RegexKitLite.h"
#import "MACheckBox.h"

#define KBoxSendEmail   (100)
#define KBoxSendSMS     (101)
#define KBoxGroupId     @"reset_box"

@implementation MAViewFilePasswordManager

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString* strPassword = [MADataManager getDataByKey:KUserDefaultPassword];
        BOOL reset = [[MADataManager getDataByKey:KUserDefaultResetPassword] boolValue];
        if (reset) {
            [MADataManager setDataByKey:[NSNumber numberWithBool:NO] forkey:KUserDefaultResetPassword];
            [self initResetPassword];
        }else{
            if ((strPassword == nil) || ([strPassword compare:@"123456"] == NSOrderedSame) ) {
                [self initSetPassword];
            } else {
                [self initChangePassword];
            }
        }
        [self setUpForDismissKeyboard];
    }
    return self;
}

- (void)initSetPassword{
    UILabel* labelPassword = [MAUtils labelWithTxt:MyLocal(@"file_password")
                                             frame:CGRectMake(20, 100, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    labelPassword.textAlignment = KTextAlignmentRight;
    [self addSubview:labelPassword];
    
    UILabel* labelconfirmPassword = [MAUtils labelWithTxt:MyLocal(@"file_confirm_password")
                                             frame:CGRectMake(20, 150, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    labelPassword.textAlignment = KTextAlignmentRight;
    [self addSubview:labelconfirmPassword];
    
    UITextField* Password = [MAUtils textFieldInit:CGRectMake(130, 100, 130, 40)
                                       color:[UIColor blueColor]
                                     bgcolor:[UIColor grayColor]
                                        secu:NO
                                        font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                        text:nil];
    Password.tag = MASetPasswordType;
    Password.delegate = self;
    Password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:Password];
    
    UITextField* confirmPassword = [MAUtils textFieldInit:CGRectMake(130, 150, 130, 40)
                                           color:[UIColor blueColor]
                                         bgcolor:[UIColor grayColor]
                                            secu:NO
                                            font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                            text:nil];
    confirmPassword.tag = MAConfirmPasswordType;
    confirmPassword.delegate = self;
    confirmPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:confirmPassword];
    
    UIButton* btnOk = [MAUtils buttonWithImg:MyLocal(@"file_password_OK") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(okBtnClicked:)];
    UIButton* btnCancel = [MAUtils buttonWithImg:MyLocal(@"file_password_cancel") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(cancelBtnClicked:)];
    btnOk.frame = CGRectMake(40, 200, 80, 40);
    btnCancel.frame = CGRectMake(200, 200, 80, 40);
    
    [btnOk setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnOk setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [btnCancel setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnCancel setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    [self addSubview:btnOk];
    [self addSubview:btnCancel];

}

- (void)initChangePassword{
    UILabel* oldLabelPassword = [MAUtils labelWithTxt:MyLocal(@"file_old_password")
                                             frame:CGRectMake(20, 50, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    oldLabelPassword.textAlignment = KTextAlignmentRight;
    [self addSubview:oldLabelPassword];
    
    UITextField* oldPassword = [MAUtils textFieldInit:CGRectMake(130, 50, 130, 40)
                                             color:[UIColor blueColor]
                                           bgcolor:[UIColor grayColor]
                                              secu:NO
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                              text:[MADataManager getDataByKey:KUserDefaultPassword]];
    oldPassword.tag = MAOldPasswordType;
    oldPassword.delegate = self;
    oldPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [oldPassword setEnabled:NO];
    [self addSubview:oldPassword];
    
    UILabel* labelPassword = [MAUtils labelWithTxt:MyLocal(@"file_new_password")
                                             frame:CGRectMake(20, 100, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    labelPassword.textAlignment = KTextAlignmentRight;
    [self addSubview:labelPassword];
    
    UILabel* labelconfirmPassword = [MAUtils labelWithTxt:MyLocal(@"file_confirm_password")
                                                    frame:CGRectMake(20, 150, 110, 40)
                                                     font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                    color:[UIColor whiteColor] ];
    labelPassword.textAlignment = KTextAlignmentRight;
    [self addSubview:labelconfirmPassword];
    
    UITextField* Password = [MAUtils textFieldInit:CGRectMake(130, 100, 130, 40)
                                             color:[UIColor blueColor]
                                           bgcolor:[UIColor grayColor]
                                              secu:NO
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                              text:nil];
    Password.tag = MANewPasswordType;
    Password.delegate = self;
    Password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:Password];
    
    
    UITextField* confirmPassword = [MAUtils textFieldInit:CGRectMake(130, 150, 130, 40)
                                                    color:[UIColor blueColor]
                                                  bgcolor:[UIColor grayColor]
                                                     secu:NO
                                                     font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                     text:nil];
    confirmPassword.tag = MAConfirmPasswordType;
    confirmPassword.delegate = self;
    confirmPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:confirmPassword];
    
    UIButton* btnOk = [MAUtils buttonWithImg:MyLocal(@"file_password_OK") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(okBtnClicked:)];
    UIButton* btnCancel = [MAUtils buttonWithImg:MyLocal(@"file_password_cancel") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(cancelBtnClicked:)];
    btnOk.frame = CGRectMake(40, 200, 80, 40);
    btnCancel.frame = CGRectMake(200, 200, 80, 40);
    
    [btnOk setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnOk setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [btnCancel setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnCancel setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    [self addSubview:btnOk];
    [self addSubview:btnCancel];
}

- (void)initResetPassword{
    UILabel* labelGetCaptcha= [MAUtils labelWithTxt:MyLocal(@"file_get_captcha")
                                                frame:CGRectMake(20, 50, 110, 40)
                                                 font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                color:[UIColor whiteColor] ];
    labelGetCaptcha.textAlignment = KTextAlignmentLeft;
    [self addSubview:labelGetCaptcha];
    
    //添加多选框
    MACheckBox *box1 = [[MACheckBox alloc] initWithGroupId:KBoxGroupId index:KBoxSendEmail text:MyLocal(@"file_set_reset_email")];
	box1.frame = CGRectMake(40, 100, 115, 40);
	[self addSubview:box1];
    
	MACheckBox *box2 = [[MACheckBox alloc] initWithGroupId:KBoxGroupId index:KBoxSendSMS text:MyLocal(@"file_set_reset_sms")];
	box2.frame = CGRectMake(180, 100, 115, 40);
	[self addSubview:box2];
    
    [MACheckBox addObserverForGroupId:KBoxGroupId observer:self];
    
    //输入
    UITextField* Captcha = [MAUtils textFieldInit:CGRectMake(20, 150, 100, 40)
                                                    color:[UIColor blueColor]
                                                  bgcolor:[UIColor grayColor]
                                                     secu:NO
                                                     font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                     text:nil];
    Captcha.tag = MACaptchaType;
    Captcha.delegate = self;
    Captcha.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:Captcha];
    UIButton* btnCaptcha = [MAUtils buttonWithImg:MyLocal(@"file_clicke_captcha") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(captchaBtnClicked:)];
    btnCaptcha.frame = CGRectMake(125, 150, 100, 40);
    [btnCaptcha setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [btnCaptcha setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnCaptcha setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [self addSubview:btnCaptcha];
    
    UIButton* btnOk = [MAUtils buttonWithImg:MyLocal(@"file_password_OK") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(captchaOKBtnClicked:)];
    btnOk.frame = CGRectMake(120,200, 80, 40);
    [btnOk setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnOk setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [self addSubview:btnOk];
}

- (void)okBtnClicked:(id)sender{
    //密码验证
    NSString* passwordFormatstr = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,}$";//@"^[0-9A-Za-z]{6,}$";
    UITextField* textfielsetPW = (UITextField*)[self viewWithTag:MASetPasswordType];
    UITextField* textfielconPW = (UITextField*)[self viewWithTag:MAConfirmPasswordType];
    UITextField* textfielnewPW = (UITextField*)[self viewWithTag:MANewPasswordType];
    if (textfielsetPW) {
        if (textfielsetPW.text == nil) {
            //密码不能为空
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"password_null") time:1];
            return;
        }else{
            if (![textfielsetPW.text isMatchedByRegex:passwordFormatstr]) {
                //密码格式不正确
                [[MAUtils shareUtils] showWeakRemind:MyLocal(@"password_error") time:2];
                return;
            }
        }
    }
    if (textfielnewPW) {
        if (textfielnewPW.text == nil) {
            //密码不能为空
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"password_null") time:1];
            return;
        }else{
            if (![textfielnewPW.text isMatchedByRegex:passwordFormatstr]) {
                //密码格式不正确
                [[MAUtils shareUtils] showWeakRemind:MyLocal(@"password_error") time:1];
                return;
            }
        }
    }
    if (textfielconPW) {
        if (textfielconPW.text == nil) {
            //再次输入密码不能为空
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"password_confirm_null") time:1];
            return;
        }else{
            if ((textfielsetPW && [textfielconPW.text compare:textfielsetPW.text] != NSOrderedSame) ||
                (textfielnewPW && [textfielconPW.text compare:textfielnewPW.text] != NSOrderedSame) ) {
                //密码不匹配
                [[MAUtils shareUtils] showWeakRemind:MyLocal(@"password_mismatching") time:1];
                return;
            }
        }
    }
    
    //保存密码
    NSString *password = textfielsetPW ? textfielsetPW.text : textfielnewPW.text;
    [MADataManager setDataByKey:password forkey:KUserDefaultPassword];

    [_delegate Passwordclick:self btnState:YES];
}

- (void)cancelBtnClicked:(id)sender{
    [_delegate Passwordclick:self btnState:NO];
}

- (void)captchaBtnClicked:(id)sender{
    
}

- (void)captchaOKBtnClicked:(id)sender{
     [_delegate Passwordclick:self btnState:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)setUpForDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    //此method会将self.view里所有的subview的first responder都resign掉
    [self endEditing:YES];
}

#pragma mark - checkbox Delegate
-(void)checkBoxSelectedAtIndex:(MACheckBox*)box curSeleckeds:(NSMutableArray *)selecteds{
    if (box.index == KBoxSendEmail) {
        if ([box checkboxSelected:nil]) {

        }
    } else if (box.index == KBoxSendSMS) {
        if (![box checkboxSelected:nil]) {

        }
    }
}

@end
