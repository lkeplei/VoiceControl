//
//  MAViewFilePasswordManager.h
//  VoiceControl
//
//  Created by yons on 14-1-13.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewBase.h"

typedef enum {
    MASetPasswordType = 1000,
    MAConfirmPasswordType,
    MAOldPasswordType,
    MANewPasswordType,
    MACaptchaType
} MAPasswordTypeTag;


@protocol MAClickPasswordBtn <NSObject>
- (void)Passwordclick:(id)view btnState:(BOOL)btnState ;
@end

@interface MAViewFilePasswordManager : MAViewBase<UITextFieldDelegate>

@property (nonatomic, assign) id <MAClickPasswordBtn> delegate;

@end
