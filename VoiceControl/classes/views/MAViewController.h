//
//  MAViewController.h
//  VoiceControl
//
//  Created by 刘坤 on 13-7-9.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>  
#import "MAModel.h"

@class MAViewBase;

typedef enum {
    MAViewTypeBase = 0,
    MAViewTypeHome,
    MAViewTypeFileManager,
    MAViewTypeSetting,
    MAViewTypeSettingFile,
    MAViewTypePlanCustomize,
    MAViewTypeAddPlan,
    MAViewTypeAddPlanRepeat,
    MAViewTypeAddPlanDuration,
    MAViewTypeAddPlanLabel,
    MAViewTypeAboutUs,
    MAViewTypeSelectMenu
} MAViewType;

@interface MAViewController : UIViewController<MFMailComposeViewControllerDelegate>

-(void)changeToViewByType:(MAViewType)type;
-(void)setGestureEnabled:(BOOL)enabled;

-(void)setTopBtn:(NSString*)leftBtn rightBtn:(NSString*)rightBtn enabled:(BOOL)enabled;

#ifdef KAppTest
-(void)setLabel:(NSString*)recorder timer:(NSString*)timer;
#endif

//about view
-(MAViewBase*)getView:(MAViewType)type;

/**
 *  视图进栈
 *
 *  @param subView 要进来的视图
 *  @param type 进栈动画
 */
-(void)pushView:(MAViewBase*)subView animatedType:(MAType)type;

/**
 *  视图出栈
 *
 *  @param lastView 要出的视图
 *  @param preView  前一个视图
 *  @param type 出栈动画
 */
-(void)popView:(MAViewBase*)lastView preView:(MAViewBase*)preView animatedType:(MAType)type;

//email
-(void)sendEMail:(NSArray*)fileArray;

@end

@interface UINavigationController (Autorotate)

- (BOOL)shouldAutorotate   ;
- (NSUInteger)supportedInterfaceOrientations;

@end
