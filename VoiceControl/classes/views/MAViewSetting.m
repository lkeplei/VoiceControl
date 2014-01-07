//
//  MAViewSetting.m
//  VoiceControl
//
//  Created by 刘坤 on 13-8-10.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewSetting.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MADataManager.h"

#define KDropDownOff        (0.1)
#define KDropDownHeight     (30)
#define KElementHOff        (10)

@interface MAViewSetting ()
@property (nonatomic, strong) MADropDownControlView* fileTimeMax;
@property (nonatomic, strong) MADropDownControlView* fileTimeMin;
@property (nonatomic, strong) MADropDownControlView* minVoice;
@end

@implementation MAViewSetting

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSetting;
        self.viewTitle = MyLocal(@"view_title_setting");
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
        
        [self initView];
    }
    return self;
}

#pragma mark - init area
-(void)initView{
    //单文件最大时长
    float off = self.frame.size.width * KDropDownOff;
    _fileTimeMax = [[MADropDownControlView alloc] initWithFrame:CGRectMake(off, 20,
                                                                                                 self.frame.size.width - off * 2,
                                                                                                 KDropDownHeight)];
    [_fileTimeMax setTitle:MyLocal(@"setting_file_time_max")];
    _fileTimeMax.delegate = self;
    
    // Add a bunch of options
    NSArray* options = [[NSArray alloc] initWithObjects:MyLocal(@"setting_time_1minute"), MyLocal(@"setting_time_2minute"),
                        MyLocal(@"setting_time_5minute"), MyLocal(@"setting_time_10minute"), MyLocal(@"setting_time_30minute"),
                        MyLocal(@"setting_time_60minute"), MyLocal(@"setting_time_120minute"), nil];
    [_fileTimeMax setSelectionOptions:options];
    [_fileTimeMax setSelectedContent:[MADataManager getDataByKey:KUserDefaultFileTimeMax]];

    //单文件最小时长
    _fileTimeMin = [[MADropDownControlView alloc] initWithFrame:CGRectMake(off,
                                                                                                 KElementHOff + CGRectGetMaxY(_fileTimeMax.frame),
                                                                                                 self.frame.size.width - off * 2,
                                                                                                 KDropDownHeight)];
    [_fileTimeMin setTitle:MyLocal(@"setting_file_time_min")];
    _fileTimeMin.delegate = self;
    
    // Add a bunch of options
    options = [[NSArray alloc] initWithObjects:MyLocal(@"setting_time_3second"), MyLocal(@"setting_time_5second"),
                        MyLocal(@"setting_time_10second"), MyLocal(@"setting_time_20second"), MyLocal(@"setting_time_30second"),
                        MyLocal(@"setting_time_50second"), MyLocal(@"setting_time_60second"), nil];
    [_fileTimeMin setSelectionOptions:options];
    [_fileTimeMin setSelectedContent:[MADataManager getDataByKey:KUserDefaultFileTimeMin]];

    
    //文件管理的密码设置
    
    //自动录音，最低分贝数
    _minVoice = [[MADropDownControlView alloc] initWithFrame:CGRectMake(off,
                                                                                              KElementHOff + CGRectGetMaxY(_fileTimeMin.frame),
                                                                                              self.frame.size.width - off * 2,
                                                                                              KDropDownHeight)];
    [_minVoice setTitle:MyLocal(@"setting_voice_min")];
    _minVoice.delegate = self;

    // Add a bunch of options
    options = [[NSArray alloc] initWithObjects:MyLocal(@"setting_voice_10"), MyLocal(@"setting_voice_20"),
               MyLocal(@"setting_voice_30"), MyLocal(@"setting_voice_40"), MyLocal(@"setting_voice_50"), MyLocal(@"setting_voice_60"),
               MyLocal(@"setting_voice_70"), MyLocal(@"setting_voice_80"), MyLocal(@"setting_voice_90"), nil];
    [_minVoice setSelectionOptions:options];
    [_minVoice setSelectedContent:[MADataManager getDataByKey:KUserDefaultVoiceStartPos]];
    
    [self addSubview:_minVoice];
    [self addSubview:_fileTimeMin];
    [self addSubview:_fileTimeMax];
}

#pragma mark - Drop Down Selector Delegate
- (void)dropDownControlViewWillBecomeActive:(MADropDownControlView *)view  {
    [SysDelegate.viewController setGestureEnabled:NO];
    
    if (_fileTimeMax == view) {
        [_fileTimeMin inactivateControl];
        [_minVoice inactivateControl];
    } else if (_fileTimeMin == view) {
        [_fileTimeMax inactivateControl];
        [_minVoice inactivateControl];
    } else if(_minVoice == view){
        [_fileTimeMin inactivateControl];
        [_fileTimeMax inactivateControl];
    }
}

- (void)dropDownControlViewWillBecomeInactive:(MADropDownControlView *)view{
    [SysDelegate.viewController setGestureEnabled:YES];
}

- (void)dropDownControlView:(MADropDownControlView *)view didFinishWithSelection:(id)selection {
    if (selection) {
        if (_fileTimeMax == view) {
            [MADataManager setDataByKey:selection forkey:KUserDefaultFileTimeMax];
        } else if (_fileTimeMin == view) {
            [MADataManager setDataByKey:selection forkey:KUserDefaultFileTimeMin];
        } else if(_minVoice == view){
            [MADataManager setDataByKey:selection forkey:KUserDefaultVoiceStartPos];
        }
        
        [view setSelectedContent:selection];
    }
}
@end
