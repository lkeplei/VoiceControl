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
#import "MAServerConfig.h"

#import "MACoreDataManager.h"
#import "MAVoiceFiles.h"

@interface MAModel ()
@property (nonatomic, strong) MASkinData* skinData;
@property (nonatomic, strong) MARecordController* recordController;
@end

@implementation MAModel

@synthesize appForeground = _appForeground;

+(MAModel*)shareModel{
    static MAModel* sharedModel = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedModel = [[self alloc] init];
    });
    return sharedModel;
};

-(void)initAppSource{
    //初始皮肤
    _skinData = [[MASkinData alloc] init];
    
    //初始录音控制器
    _recordController = [[MARecordController alloc] init];
    
    //初始数据
    [self initSettingData];
    
    //数据转移
    [self dataTransfer];
    
    //垃圾数据清理
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:folderPath]) return 0;
//    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
//    NSString* fileName;
//    unsigned long long folderSize = 0;
//    while ((fileName = [childFilesEnumerator nextObject]) != nil){
//        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//        folderSize += [self getFileSize:fileAbsolutePath];
//    }
//    return folderSize;
    
    //初始声音服务
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)initSettingData{
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
    
    if ([MADataManager getDataByKey:KUserDefaultMarkVoice] == nil) {
        [MADataManager setDataByKey:[NSNumber numberWithInt:MASettingMinVoice30] forkey:KUserDefaultMarkVoice];
    }
}

-(void)dataTransfer{
    NSString* guideV = [MADataManager getDataByKey:KUserDefaultDataVersion];
    BOOL transfer = NO;
    if (guideV) {
        if ([guideV compare:KDataVersion] != NSOrderedSame) {
            transfer = YES;
        }
    } else {
        transfer = YES;
    }
    
    if (transfer) {
        [MADataManager setDataByKey:KDataVersion forkey:KUserDefaultDataVersion];
        
        NSArray* resource = [[MADataManager shareDataManager] selectValueFromTabel:nil tableName:KTableVoiceFiles];
        if (resource && [resource count] > 0) {
            for (NSDictionary* dic in resource) {
                MAVoiceFiles* file = (MAVoiceFiles*)[[MACoreDataManager sharedCoreDataManager] getNewManagedObject:KCoreVoiceFiles];
                file.name = [dic objectForKey:KDataBaseFileName];
                file.path = [dic objectForKey:KDataBasePath];
                file.custom = MyLocal(@"custom_default");
                file.level = [dic objectForKey:KDataBaseDataEver];
                file.type = [MAUtils getNumberByInt:MATypeFileCustomDefault];
                file.time = [MAUtils getDateFromString:[[MAUtils getStringFromDate:[NSDate date] format:@"yyyy-"] stringByAppendingString:[dic objectForKey:KDataBaseTime]]
                                                format:@"yyyy-MM-dd HH:mm:ss"];
                file.duration = [NSNumber numberWithFloat:[[dic objectForKey:KDataBaseDuration] floatValue]];
                file.tag = nil;
                file.image = nil;
            }
            [[MACoreDataManager sharedCoreDataManager] saveEntry];
        }
        
        [[MADataManager shareDataManager] dropTabel:KTableVoiceFiles];
    }
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
    
    if (type == MATypeTimeClock) {
        if (time >= 60 * 60 * 24) {
            [timeStr appendFormat:@"%d:", time / (60 * 60 * 24)];
            time %= 60 * 60 * 24;
            [timeStr appendFormat:@"%02d:", time / (60 * 60)];
        } else {
            [timeStr appendFormat:@"%d:", time / (60 * 60)];
        }
        time %= 60 * 60;
        
        [timeStr appendFormat:@"%02d:", time / (60)];
        time %= 60;
        
        [timeStr appendFormat:@"%02d", time];
    } else {
        if (time >= 60 * 60 * 24) {
            if (type == MATypeTimeCh) {
                [timeStr appendFormat:MyLocal(@"time_day"), time / (60 * 60 * 24)];
            } else if (type == MATypeTimeNum) {
                [timeStr appendFormat:MyLocal(@"time_num_day"), time / (60 * 60 * 24)];
            }
            [timeStr appendString:[self getStringTime:(time % (60 * 60 * 24)) type:type]];
        } else {
            if (time >= 60 * 60) {
                if (type == MATypeTimeCh) {
                    [timeStr appendFormat:MyLocal(@"time_hour"), time / (60 * 60)];
                } else if (type == MATypeTimeNum) {
                    [timeStr appendFormat:MyLocal(@"time_num_hour"), time / (60 * 60)];
                }
                [timeStr appendString:[self getStringTime:(time % (60 * 60)) type:type]];
            } else {
                if (time >= 60) {
                    if (type == MATypeTimeCh) {
                        [timeStr appendFormat:MyLocal(@"time_minute"), time / 60];
                    } else if (type == MATypeTimeNum) {
                        [timeStr appendFormat:MyLocal(@"time_num_minute"), time / 60];
                    }
                    [timeStr appendString:[self getStringTime:time % 60 type:type]];
                } else {
                    if (type == MATypeTimeCh) {
                        [timeStr appendFormat:MyLocal(@"time_second"), time];
                    } else if (type == MATypeTimeNum) {
                        [timeStr appendFormat:MyLocal(@"time_num_second"), time];
                    }
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
    return res;
}

-(int)getVoiceStartPos{
    int res = 20;
    int type = [[MADataManager getDataByKey:KUserDefaultMarkVoice] intValue];
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
        [self clearRubbish];
    } else {
        dispatch_queue_t queue = dispatch_queue_create("clearBlock", NULL);
        
        dispatch_async(queue, ^(void) {
            NSString* nextDate = [MADataManager getDataByKey:KUserDefaultNextClearTime];
            NSDate* date = [NSDate date];
            if (nextDate) {
                date = [MAUtils getDateFromString:nextDate format:KDateTimeFormat];
            } else {
                [self getNextClearDate:date];
                [MADataManager setDataByKey:[MAUtils getStringFromDate:date format:KDateTimeFormat] forkey:KUserDefaultNextClearTime];
            }
            
            if ([[NSDate date] timeIntervalSince1970] >= [date timeIntervalSince1970]) {
                [self clearRubbish];
                [MADataManager setDataByKey:[MAUtils getStringFromDate:[date dateByAddingTimeInterval:60] format:KDateTimeFormat] forkey:KUserDefaultPreClearTime];
                [MADataManager removeDataByKey:KUserDefaultNextClearTime];
            }
        });
    }
}

-(void)clearRubbish{
    NSArray* array = [[MACoreDataManager sharedCoreDataManager] queryFromDB:KCoreVoiceFiles sortKey:nil];
    for (int i = 0; i < [array count]; i++) {
        MAVoiceFiles* file = (MAVoiceFiles*)[array objectAtIndex:i];
        if ([MAUtils getFileSize:file.path] > KZipMinSize) {
            [MAUtils deleteFileWithPath:file.path];
        }
    }
}

-(void)getNextClearDate:(NSDate*)date{
    NSString* preDateStr = [MADataManager getDataByKey:KUserDefaultPreClearTime];
    if (preDateStr) {
        date = [MAUtils getDateFromString:preDateStr format:KDateTimeFormat];
    } else {
        [MADataManager setDataByKey:[MAUtils getStringFromDate:date format:KDateTimeFormat] forkey:KUserDefaultPreClearTime];
    }
    
    MASettingType type = [[MADataManager getDataByKey:KUserDefaultClearRubbish] intValue];
    NSTimeInterval timeInterval = 0;
    NSDate* newDate = date;
    switch (type) {
        case MASettingClearRightNow:
        case MASettingClearEveryDay:
        case MASettingClearEveryWeek:
        case MASettingClearEveryMonth:{
            NSDateComponents* com = [MAUtils getComponentsFromDate:[NSDate date]];
            newDate = [MAUtils getDateFromString:[NSString stringWithFormat:@"%d-%d-%d %@:%@",
                                                  (int)[com year], (int)[com month], (int)[com day], @"02", @"00"]
                                                  format:KDateTimeFormat];
            if ([com hour] > 2 || ([com hour] == 2 && [com minute] > 0)) {
                if (type == MASettingClearRightNow || type == MASettingClearEveryDay) {
                    timeInterval = 24 * 3600;
                } else if (type == MASettingClearEveryWeek){
                    timeInterval = 24 * 3600 * 7;
                } else if (type == MASettingClearEveryWeek){
                    timeInterval = 24 * 3600 * 30;
                }
            } else {
                date = newDate;
            }
        }
            break;
        case MASettingClearTwoHour:{
            timeInterval = 7200;
        }
            break;
        case MASettingClearFiveHour:{
            timeInterval = 18000;
        }
            break;
        case MASettingClearTenHour:{
            timeInterval = 36000;
        }
            break;
        default:
            break;
    }
    
    if (timeInterval != 0) {
        date = [newDate dateByAddingTimeInterval:timeInterval];
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

-(void)resetFileMin:(int)time{
    [MADataManager setDataByKey:[NSNumber numberWithInt:time] forkey:KUserDefaultFileTimeMin];
}

-(void)setAppForeground:(BOOL)appForeground{
    _appForeground = appForeground;
    if (appForeground) {
        [_recordController startDefaultRecord];
    } else {
        [_recordController stopDefaultRecord];
    }
}
@end
