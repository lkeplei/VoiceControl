//
//  MAModel.m
//  VoiceControl
//
//  Created by ken on 13-7-24.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "MAModel.h"
#import "MAConfig.h"
#import "MADataManager.h"
#import "MASkinData.h"
#import "BaiduMobStat.h"
#import "MAUtils.h"
#import "MARecordController.h"
#import "MAViewSetting.h"

@interface MAModel ()
@property (nonatomic, strong) MASkinData* skinData;
@property (nonatomic, strong) MARecordController* recordController;
@end

@implementation MAModel

@synthesize recordAutoStatus = _recordAutoStatus;

static MAModel* _sharedModel = nil;

+(MAModel*)shareModel{
	if (!_sharedModel) {
        _sharedModel = [[self alloc]init];
	}
    
	return _sharedModel;
};

-(void)initAppSource{
    //初始皮肤
    _skinData = [[MASkinData alloc] init];
    
    //初始录音控制器
    _recordController = [[MARecordController alloc] init];
    [self setRecordAutoStatus:[[MADataManager getDataByKey:KUserDefaultRecorderStatus] boolValue]];
    
    //初始数据
    [[MADataManager shareDataManager] createTabel:KTableVoiceFiles];
    
    if ([MADataManager getDataByKey:KUserDefaultSetSkin] == nil) {
        [MADataManager setDataByKey:KSkinSetDefault forkey:KUserDefaultSetSkin];
    }
    
    if ([MADataManager getDataByKey:KUserDefaultFileTimeMax] == nil) {
        [MADataManager setDataByKey:[NSNumber numberWithInt:MASettingMaxTime10] forkey:KUserDefaultFileTimeMax];
    }
    
    if ([MADataManager getDataByKey:KUserDefaultFileTimeMin] == nil) {
        [MADataManager setDataByKey:[NSNumber numberWithInt:MASettingMinTime5] forkey:KUserDefaultFileTimeMin];
    }
    
    if ([MADataManager getDataByKey:KUserDefaultClearRubbish] == nil) {
        [MADataManager setDataByKey:[NSNumber numberWithInt:MASettingClearEveryDay] forkey:KUserDefaultClearRubbish];
    }
    
    //初始声音服务
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(UIColor*)getColorByType:(MAType)type default:(BOOL)defult{
    if (type == MATypeColorDefault) {
        return [UIColor clearColor];
    } else {
        return [_skinData getColorByType:type default:defult];
    }
}

-(UIImage*)getImageByType:(MAType)type default:(BOOL)defult{
    return [_skinData getImageByType:type default:defult];
}

- (UIFont *)getLaberFontSize:(NSString *)fontName size:(CGFloat)fontSize{
    return [UIFont fontWithName:fontName size:fontSize];
}

-(void)setBaiduMobStat:(MAType)type eventName:(NSString*)eventName label:(NSString*)label{
    switch (type) {
        case MATypeBaiduMobLogEvent:{
            [[BaiduMobStat defaultStat] logEvent:eventName eventLabel:label];
        }
            break;
        case MATypeBaiduMobEventStart:{
            [[BaiduMobStat defaultStat] eventStart:eventName eventLabel:label];
        }
            break;
        case MATypeBaiduMobEventEnd:{
            [[BaiduMobStat defaultStat] eventEnd:eventName eventLabel:label];
        }
            break;
        case MATypeBaiduMobPageStart:{
            [[BaiduMobStat defaultStat] pageviewStartWithName:eventName];
        }
            break;
        case MATypeBaiduMobPageEnd:{
            [[BaiduMobStat defaultStat] pageviewEndWithName:eventName];
        }
            break;
        default:
            break;
    }
}

-(NSString*)getStringTime:(int32_t)time type:(MAType)type{
    NSMutableString* timeStr = [[NSMutableString alloc] init];
    if (time >= 60 * 60 * 24) {
        if (type == MATypeTimeCh) {
            [timeStr appendFormat:MyLocal(@"time_day"), time / (60 * 60 * 24)];
        } else if (type == MATypeTimeNum) {
            [timeStr appendFormat:MyLocal(@"time_num_day"), time / (60 * 60 * 24)];
        } else {
            [timeStr appendFormat:MyLocal(@"time_day"), time / (60 * 60 * 24)];
        }
        [timeStr appendFormat:MyLocal(@"time_day"), time / (60 * 60 * 24)];
        [timeStr appendString:[self getStringTime:(time % (60 * 60 * 24)) type:type]];
    } else {
        if (time >= 60 * 60) {
            if (type == MATypeTimeCh) {
                [timeStr appendFormat:MyLocal(@"time_hour"), time / (60 * 60)];
            } else if (type == MATypeTimeNum) {
                [timeStr appendFormat:MyLocal(@"time_num_hour"), time / (60 * 60)];
            } else {
                [timeStr appendFormat:MyLocal(@"time_hour"), time / (60 * 60)];
            }
            [timeStr appendFormat:MyLocal(@"time_hour"), time / (60 * 60)];
            [timeStr appendString:[self getStringTime:(time % (60 * 60)) type:type]];
        } else {
            if (time >= 60) {
                if (type == MATypeTimeCh) {
                    [timeStr appendFormat:MyLocal(@"time_minute"), time / 60];
                } else if (type == MATypeTimeNum) {
                    [timeStr appendFormat:MyLocal(@"time_num_minute"), time / 60];
                } else {
                    [timeStr appendFormat:MyLocal(@"time_minute"), time / 60];
                }
                [timeStr appendString:[self getStringTime:time % 60 type:type]];
            } else {
                if (type == MATypeTimeCh) {
                    [timeStr appendFormat:MyLocal(@"time_second"), time];
                } else if (type == MATypeTimeNum) {
                    [timeStr appendFormat:MyLocal(@"time_num_second"), time];
                } else {
                    [timeStr appendFormat:MyLocal(@"time_second"), time];
                }
            }
        }
    }
    return timeStr;
}

-(void)changeView:(UIView*)from to:(UIView*)to type:(MAType)type delegate:(UIViewController*)delegate selector:(SEL)selector{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:KAnimationTime];

    switch (type) {
        case MATypeChangeViewCurlDown:
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:delegate.view cache:YES];
            break;
        case MATypeChangeViewCurlUp:
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:delegate.view cache:YES];
            break;
        case MATypeChangeViewFlipFromLeft:
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:delegate.view cache:YES];
            break;
        case MATypeChangeViewFlipFromRight:
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:delegate.view cache:YES];
            break;
        default:
            break;
    }
    
    NSUInteger first = [[delegate.view subviews] indexOfObject:from];
    NSUInteger second = [[delegate.view subviews] indexOfObject:to];

    [delegate.view exchangeSubviewAtIndex:first withSubviewAtIndex:second];
    
    [UIView setAnimationDelegate:delegate];
    // 动画完毕后调用某个方法
    [UIView setAnimationDidStopSelector:selector];
    [UIView commitAnimations];
}

-(int)getFileTimeMin{
    //以秒为单位
    int res = 5;
    int type = [[MADataManager getDataByKey:KUserDefaultFileTimeMin] intValue];
    switch (type) {
        case MASettingMinTime3:
            res = 3;
            break;
        case MASettingMinTime5:
            res = 5;
            break;
        case MASettingMinTime10:
            res = 10;
            break;
        case MASettingMinTime20:
            res = 20;
            break;
        case MASettingMinTime30:
            res = 30;
            break;
        case MASettingMinTime50:
            res = 50;
            break;
        case MASettingMinTime60:
            res = 60;
            break;
        default:
            break;
    }
    return res;
}

-(int)getFileTimeMax{
    //以秒为单位
    int res = 10;
    int type = [[MADataManager getDataByKey:KUserDefaultFileTimeMax] intValue];
    switch (type) {
        case MASettingMaxTime1:
            res = 1;
            break;
        case MASettingMaxTime2:
            res = 2;
            break;
        case MASettingMaxTime5:
            res = 5;
            break;
        case MASettingMaxTime10:
            res = 10;
            break;
        case MASettingMaxTime30:
            res = 30;
            break;
        case MASettingMaxTime60:
            res = 60;
            break;
        case MASettingMaxTime120:
            res = 120;
            break;
        default:
            break;
    }
    return res * 60;
}

-(int)getVoiceStartPos{
    int res = 20;
    int type = [[MADataManager getDataByKey:KUserDefaultVoiceStartPos] intValue];
    switch (type) {
        case MASettingMinVoice10:
            res = 10;
            break;
        case MASettingMinVoice20:
            res = 20;
            break;
        case MASettingMinVoice30:
            res = 30;
            break;
        case MASettingMinVoice40:
            res = 40;
            break;
        case MASettingMinVoice50:
            res = 50;
            break;
        case MASettingMinVoice60:
            res = 60;
            break;
        case MASettingMinVoice70:
            res = 70;
            break;
        case MASettingMinVoice80:
            res = 80;
            break;
        case MASettingMinVoice90:
            res = 90;
            break;
        default:
            break;
    }
    
    return res;
}

-(void)clearRubbish:(BOOL)now{
    if (now) {
        NSArray* array = [[MADataManager shareDataManager] selectValueFromTabel:nil tableName:KTableVoiceFiles];
        for (NSDictionary* dic in array) {
            NSString* file = [dic objectForKey:KDataBasePath];
            if ([MAUtils getFileSize:file] > KZipMinSize) {
                [MAUtils deleteFileWithPath:file];
            }
        }
    } else {
        dispatch_queue_t queue = dispatch_queue_create("clearBlock", NULL);
        
        dispatch_async(queue, ^(void) {
            NSString* preDateStr = [MADataManager getDataByKey:KUserDefaultPreClearTime];
            NSDate* date = [NSDate date];
            if (preDateStr) {
                date = [MAUtils getDateFromString:preDateStr format:KDateTimeFormat];
            }
            
            MASettingType type = [[MADataManager getDataByKey:KUserDefaultClearRubbish] intValue];
            switch (type) {
                case MASettingClearRightNow:
                case MASettingClearTwoHour:
                case MASettingClearFiveHour:
                case MASettingClearTenHour:
                case MASettingClearEveryDay:
                case MASettingClearEveryWeek:
                case MASettingClearEveryMonth:
                    break;
                default:
                    break;
            }
            
//            if (<#condition#>) {
//                <#statements#>
//            }
        });
    }
}

-(NSString*)getRepeatTest:(NSString*)resource add:(BOOL)add{
    NSString* string = @"";
    NSArray* array = [MAUtils getArrayFromStrByCharactersInSet:resource character:@","];
    if (array && [array count] > 0) {
        if ([[array objectAtIndex:0] intValue] == 99) {
            if (add) {
                string = @"plan_add_repeat_default";
            } else {
                return string;
            }
        } else {
            if ([array count] == 1) {
                string = [@"plan_add_repeat_" stringByAppendingFormat:@"%d", [[array objectAtIndex:0] intValue]];
            } else if ([array count] >= 7){
                string = @"plan_time_7";
            }else {
                for (NSString* index in array) {
                    NSString* str = [@"plan_time_" stringByAppendingFormat:@"%@", index];
                    string = [string stringByAppendingString:MyLocal(str)];
                }
                return string;
            }
        }
    }
    return MyLocal(string);
}

#pragma mark - about record
-(void)startRecord{
    [_recordController startRecord];
}

-(void)stopRecord{
    [_recordController stopRecord];
}

-(void)resetPlan{
    [_recordController resetPlan];
}

-(BOOL)isRecording{
    return [_recordController isRecording];
}

-(NSString*)getCurrentFileName{
    return [_recordController fileName];
}

-(NSString*)getcurrentFilePath{
    return [_recordController filePath];
}

-(AVAudioRecorder*)getRecorder{
    return [_recordController recorder];
}

-(void)setRecordAutoStatus:(BOOL)recordAutoStatus{
    _recordAutoStatus = recordAutoStatus;
    [_recordController setRecordAutoStatus:recordAutoStatus];
}
@end
