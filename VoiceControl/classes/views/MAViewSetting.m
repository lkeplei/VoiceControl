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
#define KDropDownHeight     (40)
#define KElementHOff        (10)

@interface MAViewSetting ()
@property (nonatomic, strong) MADropDownControlView* fileTimeMax;
@property (nonatomic, strong) MADropDownControlView* fileTimeMin;
@property (nonatomic, strong) MADropDownControlView* clearRubbish;
@property (nonatomic, strong) MADropDownControlView* markVoice;
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
    
    NSArray* options = [[NSArray alloc] initWithObjects:MyLocal(@"setting_time_1minute"), MyLocal(@"setting_time_2minute"),
                        MyLocal(@"setting_time_5minute"), MyLocal(@"setting_time_10minute"), MyLocal(@"setting_time_30minute"),
                        MyLocal(@"setting_time_60minute"), MyLocal(@"setting_time_120minute"), nil];
    [_fileTimeMax setSelectionOptions:options];
    [_fileTimeMax setSelectedContent:[options objectAtIndex:[[MADataManager getDataByKey:
                                                              KUserDefaultFileTimeMax] intValue] - MASettingMaxTime1]];

    //单文件最小时长
    _fileTimeMin = [[MADropDownControlView alloc] initWithFrame:CGRectMake(off,
                                                                           KElementHOff + CGRectGetMaxY(_fileTimeMax.frame),
                                                                           self.frame.size.width - off * 2, KDropDownHeight)];
    [_fileTimeMin setTitle:MyLocal(@"setting_file_time_min")];
    _fileTimeMin.delegate = self;

    options = [[NSArray alloc] initWithObjects:MyLocal(@"setting_time_3second"), MyLocal(@"setting_time_5second"),
                        MyLocal(@"setting_time_10second"), MyLocal(@"setting_time_20second"), MyLocal(@"setting_time_30second"),
                        MyLocal(@"setting_time_50second"), MyLocal(@"setting_time_60second"), nil];
    [_fileTimeMin setSelectionOptions:options];
    [_fileTimeMin setSelectedContent:[options objectAtIndex:[[MADataManager getDataByKey:
                                                              KUserDefaultFileTimeMin] intValue] - MASettingMinTime3]];

    //清理垃圾文件设置
    _clearRubbish = [[MADropDownControlView alloc] initWithFrame:CGRectMake(off,
                                                                           KElementHOff + CGRectGetMaxY(_fileTimeMin.frame),
                                                                           self.frame.size.width - off * 2, KDropDownHeight)];
    [_clearRubbish setTitle:MyLocal(@"setting_clear_rubbish")];
    _clearRubbish.delegate = self;
    
    options = [[NSArray alloc] initWithObjects:MyLocal(@"setting_clear_right_now"), MyLocal(@"setting_clear_two_hour"),
               MyLocal(@"setting_clear_five_hour"), MyLocal(@"setting_clear_ten_hour"), MyLocal(@"setting_clear_every_day"),
               MyLocal(@"setting_clear_every_week"), MyLocal(@"setting_clear_every_month"), nil];
    [_clearRubbish setSelectionOptions:options];
    [_clearRubbish setSelectedContent:[options objectAtIndex:[[MADataManager getDataByKey:
                                                               KUserDefaultClearRubbish] intValue] - MASettingClearRightNow]];
    
    //文件管理的密码设置
    
    //自动录音，最低分贝数(暂时不加分贝限制)
    _markVoice = [[MADropDownControlView alloc] initWithFrame:CGRectMake(off,
                                                                            KElementHOff + CGRectGetMaxY(_clearRubbish.frame),
                                                                            self.frame.size.width - off * 2, KDropDownHeight)];
    [_markVoice setTitle:MyLocal(@"setting_voice_min")];
    _markVoice.delegate = self;
    
    options = [[NSArray alloc] initWithObjects:MyLocal(@"setting_voice_10"), MyLocal(@"setting_voice_20"),
               MyLocal(@"setting_voice_30"), MyLocal(@"setting_voice_40"), MyLocal(@"setting_voice_50"),
               MyLocal(@"setting_voice_60"), MyLocal(@"setting_voice_70"), nil];
    [_markVoice setSelectionOptions:options];
    [_markVoice setSelectedContent:[options objectAtIndex:[[MADataManager getDataByKey:
                                                               KUserDefaultMarkVoice] intValue] - MASettingMinVoice10]];
    
    [self addSubview:_markVoice];
    [self addSubview:_clearRubbish];
    [self addSubview:_fileTimeMin];
    [self addSubview:_fileTimeMax];
}

#pragma mark - Drop Down Selector Delegate
- (void)dropDownControlViewWillBecomeActive:(MADropDownControlView *)view  {
    if (_fileTimeMax == view) {
        [_fileTimeMin inactivateControl];
        [_clearRubbish inactivateControl];
        [_markVoice inactivateControl];
    } else if (_fileTimeMin == view) {
        [_fileTimeMax inactivateControl];
        [_clearRubbish inactivateControl];
        [_markVoice inactivateControl];
    } else if(_clearRubbish == view){
        [_fileTimeMin inactivateControl];
        [_fileTimeMax inactivateControl];
        [_markVoice inactivateControl];
    } else if(_markVoice == view){
        [_fileTimeMin inactivateControl];
        [_fileTimeMax inactivateControl];
        [_clearRubbish inactivateControl];
    }
    
    [self setGestureEnabled];
}

- (void)dropDownControlViewWillBecomeInactive:(MADropDownControlView *)view{
    [self setGestureEnabled];
}

- (void)dropDownControlView:(MADropDownControlView *)view didFinishWithSelection:(id)selection {
    if (selection) {
        if (_fileTimeMax == view) {
            [MADataManager setDataByKey:[NSNumber numberWithInt:MASettingMaxTime1 + [selection intValue]]
                                 forkey:KUserDefaultFileTimeMax];
            
            [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KSettingMaxDuration
                                            label:[NSString stringWithFormat:@"-%d", MASettingMaxTime1 + [selection intValue]]];
        } else if (_fileTimeMin == view) {
            [[MAModel shareModel] resetFileMin:MASettingMinTime3 + [selection intValue]];
            
            [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KSettingMinDuration
                                            label:[NSString stringWithFormat:@"-%d", MASettingMinTime3 + [selection intValue]]];
        } else if(_clearRubbish == view){
            [MADataManager setDataByKey:[NSNumber numberWithInt:MASettingClearRightNow + [selection intValue]]
                                 forkey:KUserDefaultClearRubbish];
            if ([selection intValue] == 0) {
                [[MAModel shareModel] clearRubbish:YES];
            }
            
            [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KSettingRubbishClear
                                            label:[NSString stringWithFormat:@"-%d", MASettingClearRightNow + [selection intValue]]];
        } else if (_markVoice == view) {
            [MADataManager setDataByKey:[NSNumber numberWithInt:MASettingMinVoice10 + [selection intValue]]
                                 forkey:KSettingMarkVoice];
            
            [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KSettingMarkVoice
                                            label:[NSString stringWithFormat:@"-%d", MASettingMinVoice10 + [selection intValue]]];
        }
        
        [view setSelectedContent:[view selectedContent]];
    }
}

#pragma mark - others
- (void)setGestureEnabled{
    if ([_fileTimeMin controlIsActive] || [_fileTimeMax controlIsActive] || [_clearRubbish controlIsActive] || [_markVoice controlIsActive]) {
        [SysDelegate.viewController setGestureEnabled:NO];
    } else {
        [SysDelegate.viewController setGestureEnabled:YES];
    }
}
@end
