//
//  MAViewController.h
//  VoiceControl
//
//  Created by 刘坤 on 13-7-9.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>  

@class MAViewBase;

typedef enum {
    MAViewTypeBase = 0,
    MAViewTypeHome,
    MAViewTypeFileManager,
    MAViewTypeSetting,
    MAViewTypeSettingFile,
    MAViewTypeAboutUs,
    MAViewTypeSelectMenu
} MAViewType;

@interface MAViewController : UIViewController<MFMailComposeViewControllerDelegate>

-(void)changeToViewByType:(MAViewType)type;
-(void)setGestureEnabled:(BOOL)enabled;

//about view
-(MAViewBase*)getView:(MAViewType)type;
-(void)removeView:(MAViewType)type;

//email
-(void)sendEMail:(NSArray*)fileArray;

@end

@interface UINavigationController (Autorotate)

- (BOOL)shouldAutorotate   ;
- (NSUInteger)supportedInterfaceOrientations;

@end
