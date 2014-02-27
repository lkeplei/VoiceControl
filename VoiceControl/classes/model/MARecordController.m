//
//  MARecordController.m
//  VoiceControl
//
//  Created by apple on 14-2-13.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MARecordController.h"
#import "MADataManager.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"

#ifdef KAppTest
#import "MAViewController.h"
#endif

#define KTimeRecorderDuration       (20)

@interface MARecordController (){
    NSTimer*    autoTimer;
    NSURL*      urlPlay;
}

@property (assign) int recordId;
@property (assign) float recorderDuration;
@property (assign) float durationStart;
@property (assign) float offsetDuration;
@property (nonatomic, strong) NSMutableArray* planArray;
@property (nonatomic, strong) NSString* fileTime;
@property (nonatomic, strong) NSMutableDictionary* recordSetting;

@end

@implementation MARecordController

@synthesize fileName = _fileName;
@synthesize filePath = _filePath;
@synthesize recorder = _recorder;

-(id)init{
    self = [super init];
    if (self) {
        _recordId = -1;
        _recorderDuration = 0;
        _durationStart = 0;
        _offsetDuration = KTimeRecorderDuration;
        
        [self initAudio];
        [self resetPlan];
        [self resetTimer];
    }
    return self;
}

#pragma mark -
- (void)initAudio{
    _isRecording = NO;
    
    //录音设置
    _recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [_recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [_recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [_recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [_recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [_recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
}

#pragma mark - about record
-(void)startRecord{
    if (_isRecording) {
        return;
    }
    
    _isRecording = YES;
    NSArray* array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strUrl = [array lastObject];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:KNameFormat];
    _fileName = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    _filePath = [NSString stringWithFormat:@"%@/%@.aac", strUrl, _fileName];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:KTimeFormat];
    _fileTime = [formatter stringFromDate:[NSDate date]];
    
    NSURL* url = [NSURL fileURLWithPath:_filePath];
    urlPlay = url;
    
    NSError *error;
    //初始化
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//        [audioSession setActive:YES error:nil];
//    }
    _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:_recordSetting error:&error];
    //开启音量检测
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    //创建录音文件，准备录音
    if ([_recorder prepareToRecord]) {
        //开始
        [_recorder record];
    }
}

-(void)stopRecord{
    if (!_isRecording) {
        return;
    }
    
    _recorderDuration = 0;
    _durationStart = 0;
    _isRecording = NO;
    double duration = _recorder.currentTime;
    if (duration < [[MAModel shareModel] getFileTimeMin]) {//如果录制时间小于最小时长 不发送
        //删除记录的文件
        [_recorder deleteRecording];
    } else {
        //insert value to table
        NSMutableArray* resArr = [[NSMutableArray alloc] init];
        NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
        [res setObject:_filePath forKey:KDataBasePath];
        [res setObject:_fileName forKey:KDataBaseFileName];
        [res setObject:_fileTime forKey:KDataBaseTime];
        [res setObject:[MAUtils getStringByFloat:duration decimal:0] forKey:KDataBaseDuration];
        [res setObject:[MAUtils getNumberByInt:MATypeFileNormal] forKey:KDataBaseDataEver];
        [resArr addObject:res];
        [[MADataManager shareDataManager] insertValueToTabel:resArr tableName:KTableVoiceFiles maxCount:0];
        
        if ([MAUtils getFileSize:_filePath] > KZipMinSize) {
            // create dispatch queue
            dispatch_queue_t queue = dispatch_queue_create("zipBlock", NULL);
            
            dispatch_async(queue, ^(void) {
                //zip file
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docspath = [paths objectAtIndex:0];
                
                NSMutableArray* array = [[NSMutableArray alloc] init];
                
                NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
                [dic setObject:[@"" stringByAppendingFormat:@"%@.aac", _fileName] forKey:KName];
                [dic setObject:_filePath forKey:KPath];
                [array addObject:dic];
                
                BOOL result = [MAUtils zipFiles:[docspath stringByAppendingFormat:@"/%@.zip", _fileName] resourceArr:array];
                if (result) {
                    //delete file
                    [MAUtils deleteFileWithPath:_filePath];
                }
            });
        }
    }
    [_recorder stop];
}

-(void)autoTimerOut{
#ifdef KAppTest
    static int startNum = 0;
    static int timerNum = 0;
    static int stopNum = 0;
#endif
    
    if (_isRecording) {
        if (_recordId != -1) {
            _recorderDuration += _offsetDuration;
            BOOL stop = YES;
            
            for (NSDictionary* plan in _planArray) {
                if ([[plan objectForKey:KDataBaseId] intValue] == _recordId) {
                    if ([[plan objectForKey:KDataBaseStatus] boolValue]) {
                        int durationMin = _recorderDuration / 60;
                        DebugLog(@"durationMin = %d, planDuration = %d, timeMax = %d", durationMin, [[plan objectForKey:KDataBaseDuration] intValue], [[MAModel shareModel] getFileTimeMax]);
                        if (durationMin < [[plan objectForKey:KDataBaseDuration] intValue]
                            && ((_recorderDuration - _durationStart) / 60) < [[MAModel shareModel] getFileTimeMax]) {
                            stop = NO;
                        }
                    }
                    break;
                }
            }
            
            if (stop) {
#ifdef KAppTest
                stopNum++;
#endif
                [self stopRecord];
            }
        }
    } else {
        for (NSDictionary* plan in _planArray) {
            if ([[plan objectForKey:KDataBaseStatus] boolValue]) {
                NSArray* array = [MAUtils getArrayFromStrByCharactersInSet:[plan objectForKey:KDataBasePlanTime] character:@","];
                if (array && [array count] > 0) {
                    if ([[array objectAtIndex:0] intValue] == 99) {
                        NSString* dateTime = [[array objectAtIndex:1] stringByAppendingFormat:@" %@", [plan objectForKey:KDataBaseTime]];
                        if ([self whetherStart:[MAUtils getDateFromString:dateTime format:KDateTimeFormat] plan:plan]) {
#ifdef KAppTest
                            startNum++;
#endif
                        }
                    } else {
                        for (NSString* planTime in array) {
                            NSDateComponents* components = [MAUtils getComponentsFromDate:[NSDate date]];
                            if ([planTime intValue] == ([components weekday] - 1)) {
                                NSString* dateTime = [@"" stringByAppendingFormat:@"%d-%d-%d %@", [components year], [components month], [components day], [plan objectForKey:KDataBaseTime]];
                                if ([self whetherStart:[MAUtils getDateFromString:dateTime format:KDateTimeFormat] plan:plan]) {
#ifdef KAppTest
                                    startNum++;
#endif
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //清理垃圾文件
    [[MAModel shareModel] clearRubbish:NO];
#ifdef KAppTest
    timerNum++;
    [SysDelegate.viewController setLabel:[@"" stringByAppendingFormat:@"start = %d, stop = %d, timer = %d", startNum, stopNum, timerNum]
                                   timer:[MAUtils getStringFromDate:[NSDate date] format:KTimeFormat]];
#endif
}

-(BOOL)whetherStart:(NSDate*)planDate plan:(NSDictionary*)plan{
    NSTimeInterval between = [[NSDate date] timeIntervalSinceDate:planDate];
    if (between >= 0) {
        if ((between / 60) < [[plan objectForKey:KDataBaseDuration] intValue]) {
            _recorderDuration = between;
            _durationStart = between;
            _recordId = [[plan objectForKey:KDataBaseId] intValue];
            [self startRecord];

            return YES;
        }
    }
    
    return NO;
}

#pragma mark - other
-(void)resetPlan{
    if (_planArray) {
        [_planArray removeAllObjects];
    } else {
        _planArray = [[NSMutableArray alloc] init];
    }
    
    NSArray* array = [[MADataManager shareDataManager] selectValueFromTabel:nil tableName:KTablePlan];
    if (array && [array count] > 0) {
        [_planArray addObjectsFromArray:array];
    }
}

-(void)resetTimer{
    if (autoTimer) {
        [autoTimer invalidate];
        autoTimer = nil;
    }
    
    _offsetDuration = MIN([[MAModel shareModel] getFileTimeMin], _offsetDuration);
    autoTimer = [NSTimer scheduledTimerWithTimeInterval:_offsetDuration target:self selector:@selector(autoTimerOut) userInfo:nil repeats:YES];
}
@end
