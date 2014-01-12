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

@interface MAViewSettingFile ()
@property (nonatomic,strong)  UIButton* btnChangePassword;
@property (nonatomic,strong)  UIButton* btnResetPassword;
@property (nonatomic,strong)  UIButton* btnEncryptFile;
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
    NSString* str = nil;
    NSString* strPassword = [MADataManager getDataByKey:KUserPassword];
    if ((strPassword == nil) || ([strPassword compare:@"123456"] == NSOrderedSame) ) {
        str = MyLocal(@"setfile_setpassword");
    } else {
        str = MyLocal(@"setfile_changepassword");
    }
    _btnChangePassword = [MAUtils buttonWithImg:str off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(chaPwBtnClicked:)];
    _btnResetPassword  = [MAUtils buttonWithImg:MyLocal(@"setfile_resetpassword") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(resPwBtnClicked:)];
    _btnEncryptFile    = [MAUtils buttonWithImg:MyLocal(@"setfile_encryptfile") off:0 zoomIn:NO image:nil imagesec:nil target:self action:@selector(encryBtnClicked:)];
    
    _btnChangePassword.frame = CGRectMake(self.frame.size.width/2 - 80, 100, 160, 40);
    _btnResetPassword.frame  = CGRectMake(self.frame.size.width/2 - 80, 150, 160, 40);
    _btnEncryptFile.frame    = CGRectMake(self.frame.size.width/2 - 80, 200, 160, 40);
    
    [_btnChangePassword setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [_btnChangePassword setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [_btnResetPassword setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [_btnResetPassword setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [_btnEncryptFile setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [_btnEncryptFile setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    [self addSubview:_btnChangePassword];
    [self addSubview:_btnResetPassword];
    [self addSubview:_btnEncryptFile];
}

#pragma mark - btn clicked
- (void)chaPwBtnClicked:(id)sender{

}

- (void)resPwBtnClicked:(id)sender{
    
}

- (void)encryBtnClicked:(id)sender{
    
}


@end
