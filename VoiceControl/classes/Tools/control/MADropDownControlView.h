//
//  MADropDownControlView.h
//  VoiceControl
//
//  Created by ken on 13-4-15.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MADropDownControlView;


@protocol MADropDownControlViewDelegate <NSObject>

// Selection contains the user selected option or nil if nothing was selected
- (void)dropDownControlView:(MADropDownControlView *)view didFinishWithSelection:(id)selection;

@optional
- (void)dropDownControlViewWillBecomeActive:(MADropDownControlView *)view;
- (void)dropDownControlViewWillBecomeInactive:(MADropDownControlView *)view;

@end



@interface MADropDownControlView : UIView

@property (nonatomic, strong) id<MADropDownControlViewDelegate> delegate;
@property (assign) BOOL controlIsActive;

- (void)setSelectionOptions:(NSArray*)selectionOptions;
- (void)setTitle:(NSString *)title;
- (void)setSelectedContent:(NSString *)selectedContent;
- (void)inactivateControl;

@end
