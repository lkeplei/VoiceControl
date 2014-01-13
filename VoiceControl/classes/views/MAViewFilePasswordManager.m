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

@implementation MAViewFilePasswordManager

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString* strPassword = [MADataManager getDataByKey:KUserPassword];
        BOOL reset = [[MADataManager getDataByKey:KUserResetPassword] boolValue];
        if (reset) {
            [MADataManager setDataByKey:[NSNumber numberWithBool:NO] forkey:KUserResetPassword];
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
    UILabel* labelPassword = [MAUtils laeblWithTxt:MyLocal(@"file_password")
                                             frame:CGRectMake(20, 100, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    labelPassword.textAlignment = UITextAlignmentRight;
    [self addSubview:labelPassword];
    
    UILabel* labelconfirmPassword = [MAUtils laeblWithTxt:MyLocal(@"file_confirm_password")
                                             frame:CGRectMake(20, 150, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    labelPassword.textAlignment = UITextAlignmentRight;
    [self addSubview:labelconfirmPassword];
    
    UITextField* Password = [MAUtils textFieldInit:CGRectMake(130, 100, 130, 40)
                                       color:[UIColor blueColor]
                                     bgcolor:[UIColor grayColor]
                                        secu:NO
                                        font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                        text:nil];
    Password.delegate = self;
    Password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:Password];

    
    UITextField* confirmPassword = [MAUtils textFieldInit:CGRectMake(130, 150, 130, 40)
                                           color:[UIColor blueColor]
                                         bgcolor:[UIColor grayColor]
                                            secu:YES
                                            font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                            text:nil];
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
    UILabel* oldLabelPassword = [MAUtils laeblWithTxt:MyLocal(@"file_old_password")
                                             frame:CGRectMake(20, 50, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    oldLabelPassword.textAlignment = UITextAlignmentRight;
    [self addSubview:oldLabelPassword];
    
    UITextField* oldPassword = [MAUtils textFieldInit:CGRectMake(130, 50, 130, 40)
                                             color:[UIColor blueColor]
                                           bgcolor:[UIColor grayColor]
                                              secu:NO
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                              text:[MADataManager getDataByKey:KUserPassword]];
    oldPassword.delegate = self;
    oldPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [oldPassword setEnabled:NO];
    [self addSubview:oldPassword];
    
    UILabel* labelPassword = [MAUtils laeblWithTxt:MyLocal(@"file_new_password")
                                             frame:CGRectMake(20, 100, 110, 40)
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                             color:[UIColor whiteColor] ];
    labelPassword.textAlignment = UITextAlignmentRight;
    [self addSubview:labelPassword];
    
    UILabel* labelconfirmPassword = [MAUtils laeblWithTxt:MyLocal(@"file_confirm_password")
                                                    frame:CGRectMake(20, 150, 110, 40)
                                                     font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                    color:[UIColor whiteColor] ];
    labelPassword.textAlignment = UITextAlignmentRight;
    [self addSubview:labelconfirmPassword];
    
    UITextField* Password = [MAUtils textFieldInit:CGRectMake(130, 100, 130, 40)
                                             color:[UIColor blueColor]
                                           bgcolor:[UIColor grayColor]
                                              secu:NO
                                              font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                              text:nil];
    Password.delegate = self;
    Password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:Password];
    
    
    UITextField* confirmPassword = [MAUtils textFieldInit:CGRectMake(130, 150, 130, 40)
                                                    color:[UIColor blueColor]
                                                  bgcolor:[UIColor grayColor]
                                                     secu:YES
                                                     font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                     text:nil];
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
    UILabel* labelGetCaptcha= [MAUtils laeblWithTxt:MyLocal(@"file_get_captcha")
                                                frame:CGRectMake(20, 50, 110, 40)
                                                 font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                color:[UIColor whiteColor] ];
    labelGetCaptcha.textAlignment = UITextAlignmentLeft;
    [self addSubview:labelGetCaptcha];
    
    UITextField* Captcha = [MAUtils textFieldInit:CGRectMake(20, 150, 100, 40)
                                                    color:[UIColor blueColor]
                                                  bgcolor:[UIColor grayColor]
                                                     secu:YES
                                                     font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
                                                     text:nil];
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

@end
