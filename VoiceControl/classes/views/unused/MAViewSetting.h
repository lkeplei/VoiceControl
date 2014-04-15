//
//  MAViewSetting.h
//  VoiceControl
//
//  Created by 刘坤 on 13-8-10.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewTableBase.h"
#import "MADropDownControlView.h"

typedef enum {
    MASettingMinVoice10 = 100,
    MASettingMinVoice20,
    MASettingMinVoice30,
    MASettingMinVoice40,
    MASettingMinVoice50,
    MASettingMinVoice60,
    MASettingMinVoice70,
    MASettingMinVoice80,
    MASettingMinVoice90,
    
    MASettingClearRightNow = 200,
    MASettingClearTwoHour,
    MASettingClearFiveHour,
    MASettingClearTenHour,
    MASettingClearEveryDay,
    MASettingClearEveryWeek,
    MASettingClearEveryMonth,
    
    MASettingMinTime3 = 300,
    MASettingMinTime5,
    MASettingMinTime10,
    MASettingMinTime20,
    MASettingMinTime30,
    MASettingMinTime50,
    MASettingMinTime60,
    
    MASettingMaxTime1 = 400,
    MASettingMaxTime2,
    MASettingMaxTime5,
    MASettingMaxTime10,
    MASettingMaxTime30,
    MASettingMaxTime60,
    MASettingMaxTime120,
} MASettingType;

@interface MAViewSetting : MAViewBase<MADropDownControlViewDelegate>

@end
