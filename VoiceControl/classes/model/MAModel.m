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
    
    //初始服务
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
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
    int res = 0;
    NSString* str = [MADataManager getDataByKey:KUserDefaultFileTimeMin];
    if (str) {
        if ([str compare:MyLocal(@"setting_time_3second")] == NSOrderedSame) {
            res = 3;
        } else if ([str compare:MyLocal(@"setting_time_5second")] == NSOrderedSame) {
            res = 5;
        } else if ([str compare:MyLocal(@"setting_time_10second")] == NSOrderedSame) {
            res = 10;
        } else if ([str compare:MyLocal(@"setting_time_20second")] == NSOrderedSame) {
            res = 20;
        } else if ([str compare:MyLocal(@"setting_time_30second")] == NSOrderedSame) {
            res = 30;
        } else if ([str compare:MyLocal(@"setting_time_50second")] == NSOrderedSame) {
            res = 50;
        } else if ([str compare:MyLocal(@"setting_time_60second")] == NSOrderedSame) {
            res = 60;
        } else {
            res = 3;
        } 
    }
    
    return res;
}

-(int)getFileTimeMax{
    //以秒为单位
    int res = 0;
    NSString* str = [MADataManager getDataByKey:KUserDefaultFileTimeMax];
    if (str) {
        if ([str compare:MyLocal(@"setting_time_1minute")] == NSOrderedSame) {
            res = 1;
        } else if ([str compare:MyLocal(@"setting_time_2minute")] == NSOrderedSame) {
            res = 2;
        } else if ([str compare:MyLocal(@"setting_time_5minute")] == NSOrderedSame) {
            res = 5;
        } else if ([str compare:MyLocal(@"setting_time_10minute")] == NSOrderedSame) {
            res = 10;
        } else if ([str compare:MyLocal(@"setting_time_30minute")] == NSOrderedSame) {
            res = 30;
        } else if ([str compare:MyLocal(@"setting_time_60minute")] == NSOrderedSame) {
            res = 60;
        } else if ([str compare:MyLocal(@"setting_time_120minute")] == NSOrderedSame) {
            res = 120;
        } else {
            res = 5;
        }
    }
    
    return res * 60;
}

-(int)getVoiceStatPos{
    int res = 0;
    NSString* str = [MADataManager getDataByKey:KUserDefaultVoiceStartPos];
    if (str) {
        if ([str compare:MyLocal(@"setting_voice_10")] == NSOrderedSame) {
            res = 10;
        } else if ([str compare:MyLocal(@"setting_voice_20")] == NSOrderedSame) {
            res = 20;
        } else if ([str compare:MyLocal(@"setting_voice_30")] == NSOrderedSame) {
            res = 30;
        } else if ([str compare:MyLocal(@"setting_voice_40")] == NSOrderedSame) {
            res = 40;
        } else if ([str compare:MyLocal(@"setting_voice_50")] == NSOrderedSame) {
            res = 50;
        } else if ([str compare:MyLocal(@"setting_voice_60")] == NSOrderedSame) {
            res = 60;
        } else if ([str compare:MyLocal(@"setting_voice_70")] == NSOrderedSame) {
            res = 70;
        } else if ([str compare:MyLocal(@"setting_voice_80")] == NSOrderedSame) {
            res = 80;
        } else if ([str compare:MyLocal(@"setting_voice_90")] == NSOrderedSame) {
            res = 90;
        } else {
            res = 20;
        }
    }
    
    return res;
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
