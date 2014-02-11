//
//  MAViewFactory.m
//  VoiceControl
//
//  Created by apple on 14-2-8.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewFactory.h"
#import "MAConfig.h"

#import "MAViewSelectMenu.h"
#import "MAViewHome.h"
#import "MAViewFileManager.h"
#import "MAViewAboutUs.h"
#import "MAViewSetting.h"
#import "MAViewSettingFile.h"
#import "MAViewPlanCustomize.h"
#import "MAViewAddPlan.h"
#import "MAViewAddPlanRepeat.h"
#import "MAViewAddPlanLabel.h"

@interface MAViewFactory ()

@property (nonatomic, strong) MAViewSelectMenu* selectMenu;
@property (nonatomic, strong) MAViewHome* homeView;
@property (nonatomic, strong) MAViewFileManager* fileManagerView;
@property (nonatomic, strong) MAViewPlanCustomize* planCustomizeView;
@property (nonatomic, strong) MAViewAddPlan* addPlanView;
@property (nonatomic, strong) MAViewAddPlanRepeat* addPlanRepeatView;
@property (nonatomic, strong) MAViewAddPlanLabel* addPlanLabelView;
@property (nonatomic, strong) MAViewAboutUs* aboutUsView;
@property (nonatomic, strong) MAViewSetting* settingView;
@property (nonatomic, strong) MAViewSettingFile* settingFileView;

@end

@implementation MAViewFactory

#pragma mark - about view manager
-(MAViewBase*)getView:(MAViewType)type frame:(CGRect)frame{
    MAViewBase* view = nil;
    switch (type) {
        case MAViewTypeHome:
        {
            if (_homeView == nil) {
                _homeView = [[MAViewHome alloc] initWithFrame:frame];
            }
            view = _homeView;
        }
            break;
            
        case MAViewTypeFileManager:
        {
            if (_fileManagerView == nil) {
                _fileManagerView = [[MAViewFileManager alloc] initWithFrame:frame];
            }
            view = _fileManagerView;
        }
            break;
        case MAViewTypeSetting:
        {
            if (_settingView == nil) {
                _settingView = [[MAViewSetting alloc] initWithFrame:frame];
            }
            view = _settingView;
        }
            break;
        case MAViewTypeSettingFile:
        {
            if (_settingFileView == nil) {
                _settingFileView = [[MAViewSettingFile alloc] initWithFrame:frame];
            }
            view = _settingFileView;
        }
            break;
        case MAViewTypePlanCustomize:
        {
            if (_planCustomizeView == nil) {
                _planCustomizeView = [[MAViewPlanCustomize alloc] initWithFrame:frame];
            }
            view = _planCustomizeView;
        }
            break;
        case MAViewTypeAddPlan:
        {
            if (_addPlanView == nil) {
                _addPlanView = [[MAViewAddPlan alloc] initWithFrame:frame];
            }
            view = _addPlanView;
        }
            break;
        case MAViewTypeAddPlanRepeat:
        {
            if (_addPlanRepeatView == nil) {
                _addPlanRepeatView = [[MAViewAddPlanRepeat alloc] initWithFrame:frame];
            }
            view = _addPlanRepeatView;
        }
            break;
        case MAViewTypeAddPlanLabel:
        {
            if (_addPlanLabelView == nil) {
                _addPlanLabelView = [[MAViewAddPlanLabel alloc] initWithFrame:frame];
            }
            view = _addPlanLabelView;
        }
            break;
        case MAViewTypeAboutUs:
        {
            if (_aboutUsView == nil) {
                _aboutUsView = [[MAViewAboutUs alloc] initWithFrame:frame];
            }
            view = _aboutUsView;
        }
            break;
            
        default:
            break;
    }
    
    return view;
}

-(void)removeView:(MAViewType)type{
    switch (type) {
        case MAViewTypeHome:
        {
            if (_homeView) {
                [_homeView removeFromSuperview];
                _homeView = nil;
            }
        }
            break;
        case MAViewTypeFileManager:
        {
            if (_fileManagerView) {
                [_fileManagerView removeFromSuperview];
                _fileManagerView = nil;
            }
        }
            break;
        case MAViewTypeSetting:
        {
            if (_settingView) {
                [_settingView removeFromSuperview];
                _settingView = nil;
            }
        }
            break;
        case MAViewTypeSettingFile:
        {
            if (_settingFileView) {
                [_settingFileView removeFromSuperview];
                _settingFileView = nil;
            }
        }
            break;
        case MAViewTypePlanCustomize:
        {
            if (_planCustomizeView) {
                [_planCustomizeView removeFromSuperview];
                _planCustomizeView = nil;
            }
        }
            break;
        case MAViewTypeAddPlan:
        {
            if (_addPlanView) {
                [_addPlanView removeFromSuperview];
                _addPlanView = nil;
            }
        }
            break;
        case MAViewTypeAddPlanRepeat:
        {
            if (_addPlanRepeatView) {
                [_addPlanRepeatView removeFromSuperview];
                _addPlanRepeatView = nil;
            }
        }
            break;
        case MAViewTypeAddPlanLabel:
        {
            if (_addPlanLabelView) {
                [_addPlanLabelView removeFromSuperview];
                _addPlanLabelView = nil;
            }
        }
            break;
        case MAViewTypeAboutUs:
        {
            if (_aboutUsView) {
                [_aboutUsView removeFromSuperview];
                _aboutUsView = nil;
            }
        }
            break;
            
        default:
            break;
    }
}
@end