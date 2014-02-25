//
//  MAViewSettingFile.m
//  VoiceControl
//
//  Created by ken on 13-9-11.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewSettingFile.h"
#import "MAModel.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MADataManager.h"

//@interface MAViewSettingFile ()
//@property (nonatomic,strong)  UIButton* btnChangePassword;
//@property (nonatomic,strong)  UIButton* btnResetPassword;
//@property (nonatomic,strong)  UIButton* btnEncryptFile;
//@end

@interface MAViewSettingFile ()
@property (nonatomic, strong) UIView* menuView;
@end

@implementation MAViewSettingFile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSettingFile;
        self.viewTitle = MyLocal(@"view_title_set_file");
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
        
        [self initView];
    }
    return self;
}

- (void)initView{
    if (_menuView) {
        [_menuView removeFromSuperview];
    }
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)];
    NSString* str = nil;
    NSString* strPassword = [MADataManager getDataByKey:KUserDefaultPassword];
    if ((strPassword == nil) || ([strPassword compare:@"123456"] == NSOrderedSame) ) {
        str = MyLocal(@"setfile_setpassword");
    } else {
        str = MyLocal(@"setfile_changepassword");
    }
    UIButton* btnChangePassword = [MAUtils buttonWithImg:str off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(chaPWBtnClicked:)];
    UIButton* btnResetPassword  = [MAUtils buttonWithImg:MyLocal(@"setfile_resetpassword") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(resPWBtnClicked:)];
    UIButton* btnEncryptFile    = [MAUtils buttonWithImg:MyLocal(@"setfile_encryptfile") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(encryBtnClicked:)];
    
    btnChangePassword.frame = CGRectMake(self.frame.size.width/2 - 80, 100, 160, 40);
    btnResetPassword.frame  = CGRectMake(self.frame.size.width/2 - 80, 150, 160, 40);
    btnEncryptFile.frame    = CGRectMake(self.frame.size.width/2 - 80, 200, 160, 40);
    
    [btnChangePassword setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnChangePassword setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [btnResetPassword setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnResetPassword setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [btnEncryptFile setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btnEncryptFile setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    [_menuView addSubview:btnChangePassword];
    [_menuView addSubview:btnResetPassword];
    [_menuView addSubview:btnEncryptFile];
    
    [self addSubview:_menuView];
}

#pragma mark - btn clicked
- (void)chaPWBtnClicked:(id)sender{
    [_menuView setHidden:YES];
    MAViewFilePasswordManager* view = [[MAViewFilePasswordManager alloc] initWithFrame:CGRectMake(0, 0,
                                                                    self.frame.size.width,
                                                                    self.frame.size.height - 40)];
    view.delegate = self;
    [self addSubview:view];
}

- (void)resPWBtnClicked:(id)sender{
    [MADataManager setDataByKey:[NSNumber numberWithBool:YES] forkey:KUserDefaultResetPassword];
    [_menuView setHidden:YES];
    MAViewFilePasswordManager* view = [[MAViewFilePasswordManager alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                  self.frame.size.width,
                                                                                                  self.frame.size.height - 40)];
    view.delegate = self;
    [self addSubview:view];
}

- (void)encryBtnClicked:(id)sender{
    
}

#pragma mark - MAClickPasswordBtn
- (void)Passwordclick:(id)view btnState:(BOOL)btnState{
//    [view setHidden:YES];
    [view removeFromSuperview];
    [_menuView setHidden:NO];
}



@end
