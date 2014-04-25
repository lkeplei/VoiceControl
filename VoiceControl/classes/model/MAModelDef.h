//
//  MAModelDef.h
//  VoiceControl
//
//  Created by apple on 14-4-22.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#ifndef VoiceControl_MAModelDef_h
#define VoiceControl_MAModelDef_h

typedef enum {
    MATypeTimeCh = 0,
    MATypeTimeNum,
    MATypeTimeClock,
    
    MATypeSkinDefault = 50,
    MATypeSkinBlack,
    
    MATypeFileNormal = 70,
    MATypeFileForEver,
    MATypeFilePwd,
    
    MATypeFileCustomDefault = 80,
    
    MATypeChangeViewNull = 100,
    MATypeChangeViewCurlDown,
    MATypeChangeViewCurlUp,
    MATypeChangeViewFlipFromLeft,
    MATypeChangeViewFlipFromRight,
    MATypeTransitionCube,
    MATypeTransitionPush,
    MATypeTransitionReveal,
    MATypeTransitionMoveIn,
    MATypeTransitionFade,
    MATypeTransitionSuckEffect,
    MATypeTransitionOglFlip,
    MATypeTransitionRippleEffect,
    MATypeTransitionCameraIrisHollowOpen,
    MATypeTransitionCameraIrisHollowClose,
    MATypePositionLeft,
    
    MATypeColorDefault = 200,
    MATypeColorDefWhite,
    MATypeColorDefBlack,
    MATypeColorDefGray,
    MATypeColorDefBlue,
    MATypeColorHomeBg,
    MATypeColorTableLabel,
    MATypeColorDropBG,
    MATypeColorDropCellBG,
    MATypeColorBtnGreen,
    MATypeColorBtnDarkGreen,
    MATypeColorBtnRed,
    MATypeColorBtnDarkRed,
    MATypeColorBtnGray,
    MATypeColorTopView,
    MATypeColorViewBg,
    
    MATypeImgHomePhone = 300,
    MATypeImgHomeMenu,
    MATypeImgPlayPlay,
    MATypeImgPlayNext,
    MATypeImgPlayPause,
    MATypeImgPlayPre,
    MATypeImgBtnGreenCircleSec,
    MATypeImgBtnGreenCircle,
    MATypeImgBtnRedCircleSec,
    MATypeImgBtnRedCircle,
    MATypeImgBtnGrayCircle,
    MATypeImgAddPlanReSec,
    MATypeImgCheckBoxNormal,
    MATypeImgCheckBoxSec,
    MATypeImgCellIndicator,
    MATypeImgSliderScrubberKnob,
    MATypeImgSliderScrubberLeft,
    MATypeImgSliderScrubberRight,
    MATypeImgSysSettingCellBg,
    
    MATypeBaiduMobLogEvent = 400,
    MATypeBaiduMobEventStart,
    MATypeBaiduMobEventEnd,
    MATypeBaiduMobPageStart,
    MATypeBaiduMobPageEnd,
} MAType;

typedef enum {
    MARecorderQualityLow = 0,
    MARecorderQualityNormal,
    MARecorderQualityHigh,
} MARecorderQualityType;

#endif
