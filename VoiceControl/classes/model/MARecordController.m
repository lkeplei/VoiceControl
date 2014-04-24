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

#import "MAVoiceFiles.h"
#import "MACoreDataManager.h"

#define KTimeRecorderDuration       (20)
#define KTimeOffset                 (1)
#define KMarkDuration               (60)


#pragma mark - MATagObject
@interface MATagObject (){
    int     points;
}
@end

@implementation MATagObject
-(void)initData{
    _startTime = 0;
    _endTime = 0;
    _averageVoice = 0;
    _totalTime = 0;
    _pointX = 0;
    _tagName = MyLocal(@"custom_default");
    
    _duration = 0;
    points = 0;
}

-(void)addAverage:(Float32)voice{
    _duration += KTimeOffset;
    
    Float32 total = points * _averageVoice;
    points++;
    _averageVoice = (total + voice) / points;
}

-(BOOL)initDataWithString:(NSString*)string{
    NSArray* array = [MAUtils getArrayFromStrByCharactersInSet:string character:@"-"];
    if (array && [array count] >= 4) {
        _startTime = [[array objectAtIndex:0] floatValue];
        _endTime = [[array objectAtIndex:1] floatValue];
        _averageVoice = [[array objectAtIndex:2] floatValue];
        _tagName = [array objectAtIndex:3];
        
        return YES;
    }
    
    return NO;
}
@end




#pragma mark - MARecordController
@interface MARecordController (){
    NSTimer*    autoTimer;
    NSURL*      urlPlay;
}

@property (assign) Float32 tagOffset;           //两个标记的间隔
@property (assign) int recordId;                //当前运行的计划Id
@property (assign) int recorderTimer;           //录音计点
@property (assign) float recorderDuration;      //录音计时
@property (assign) float durationStart;         //录音计划起点
@property (assign) float offsetDuration;        //录音间隔点
@property (nonatomic, strong) NSMutableString* markResource;
@property (nonatomic, strong) NSMutableArray* planArray;
@property (nonatomic, strong) NSDate* fileTime;
@property (nonatomic, strong) NSMutableDictionary* recordSetting;

@property (nonatomic, strong) MATagObject* tagObject;

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
        _tagOffset = 0;
        _offsetDuration = KTimeRecorderDuration;
        
        [self initAudio];
        [self resetPlan];
        [self resetTimer];
    }
    return self;
}

#pragma mark - init
- (void)initAudio{
    _isRecording = NO;
    
    [self resetRecorderQuality:(MARecorderQualityType)[[MADataManager getDataByKey:KUserDefaultQualityLevel] intValue]];
}

-(void)initTagObject{
    if (_tagObject == nil) {
        _tagObject = [[MATagObject alloc] init];
    }
    
    [_tagObject initData];
}

#pragma mark - about record
-(void)resetRecorderQuality:(MARecorderQualityType)type{
    MARecorderQualityType oldType = (MARecorderQualityType)[[MADataManager getDataByKey:KUserDefaultQualityLevel] intValue];
    if (type != oldType || _recordSetting == nil) {
        [MADataManager setDataByKey:[NSNumber numberWithInt:type] forkey:KUserDefaultQualityLevel];
        
        if (_recordSetting == nil) {
            //录音设置
            _recordSetting = [[NSMutableDictionary alloc]init];
            //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
            [_recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
            //录音通道数  1 或 2
            [_recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
            //线性采样位数  8、16、24、32
            [_recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
            //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
            [_recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
        }
        
        switch (type) {
            case MARecorderQualityLow:{
                //录音的质量
                [_recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
            }
                break;
            case MARecorderQualityNormal:{
                //录音的质量
                [_recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
            }
                break;
            case MARecorderQualityHigh:{
                //录音的质量
                [_recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)startDefaultRecord{
    if (_isRecording) {
        return;
    }
    NSArray* array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strUrl = [array lastObject];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:KNameFormat];
    NSString* name = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    NSString* path = [NSString stringWithFormat:@"%@/%@.aac", strUrl, name];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:KTimeFormat];
    
    NSURL* url = [NSURL fileURLWithPath:path];
    
    _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:_recordSetting error:nil];
    //开启音量检测
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    //创建录音文件，准备录音
    if ([_recorder prepareToRecord]) {
        //开始
        [_recorder record];
    }
}

-(void)stopDefaultRecord{
    if (_isRecording) {
        return;
    }
    
    if ([_recorder isRecording]) {
        [_recorder stop];
        [_recorder deleteRecording];
    }
}

-(void)startRecord{
    if (_isRecording) {
        return;
    }
    
    //开始正式录音之前先停掉默认录音
    [self stopDefaultRecord];
    
    [self initTagObject];
    
    //录音设置
    _isRecording = YES;
    NSArray* array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strUrl = [array lastObject];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:KNameFormat];
    _fileName = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    _filePath = [NSString stringWithFormat:@"%@/%@.aac", strUrl, _fileName];
    _fileTime = [NSDate date];
    _markResource = nil;
    
    NSURL* url = [NSURL fileURLWithPath:_filePath];
    urlPlay = url;
    
    NSError *error;
    //初始化
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

    //结束之前先打结束标记
    [self markEndPoint];
    
    _recorderDuration = 0;
    _durationStart = 0;
    _isRecording = NO;
    double duration = _recorder.currentTime;
    
    if (duration < KFileTimeMin) {//如果录制时间小于最小时长 不发送
        _fileName = nil;
        
        [_recorder stop];
        //删除记录的文件
        [_recorder deleteRecording];
    } else {
        //insert value to table
        [self saveData];
        [_recorder stop];
        
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
    
    //结束之后，如果在后台，开启默认录音
    if ([[MAModel shareModel] isAppForeground]) {
        [self startDefaultRecord];
    }
}

-(void)autoTimerOut{
    _recorderTimer--;
    if (_recorderTimer <= 0) {
        _recorderTimer = _offsetDuration;
        
        if (_isRecording) {
            if (_recordId != -1) {
                _recorderDuration += _offsetDuration;
                BOOL stop = YES;
                
                for (NSDictionary* plan in _planArray) {
                    if ([[plan objectForKey:KDataBaseId] intValue] == _recordId) {
                        if ([[plan objectForKey:KDataBaseStatus] boolValue]) {
                            int durationMin = _recorderDuration / 60;
                            if (durationMin < [[plan objectForKey:KDataBaseDuration] intValue]
                                && (_recorderDuration - _durationStart) < [[MAModel shareModel] getFileTimeMax]) {
                                stop = NO;
                            }
                        }
                        break;
                    }
                }
                
                if (stop) {
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
                            }
                        } else {
                            for (NSString* planTime in array) {
                                NSDateComponents* components = [MAUtils getComponentsFromDate:[NSDate date]];
                                if ([planTime intValue] == ([components weekday] - 1)) {
                                    NSString* dateTime = [@"" stringByAppendingFormat:@"%d-%d-%d %@", (int)[components year], (int)[components month], (int)[components day], [plan objectForKey:KDataBaseTime]];
                                    if ([self whetherStart:[MAUtils getDateFromString:dateTime format:KDateTimeFormat] plan:plan]) {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //记录标记点
    [self markRecord];
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

-(void)markRecord{
    if (_tagOffset <= 0 && [_recorder isRecording]) {
        [_recorder updateMeters];//刷新音量数据
        float averageVoice = [_recorder averagePowerForChannel:0] + 100;
        int tagVoice = [[MAModel shareModel] getTagVoice];
        if (averageVoice >= tagVoice) {
            if (_tagObject.startTime == 0) {
                [self initTagObject];
            }
            if (_tagObject.startTime == 0) {
                _tagObject.startTime = _recorder.currentTime;
            }
            [_tagObject addAverage:averageVoice];
        } else {
            if (_tagObject.duration > KFileTimeMin) {
                [self markEndPoint];
            } else {
                [_tagObject addAverage:averageVoice];
            }
        }
    }
    
    _tagOffset -= _offsetDuration;
}

-(void)markEndPoint{
    if ([self needMarkEnd]) {
        _tagObject.endTime = _recorder.currentTime;
        
        if (_markResource == nil) {
            _markResource = [[NSMutableString alloc] init];
            [_markResource appendFormat:@"%.1f-%.1f-%.1f-%@", _tagObject.startTime, _tagObject.endTime,
             _tagObject.averageVoice, _tagObject.tagName];
        } else {
            [_markResource appendFormat:@";%.1f-%.1f-%.1f-%@", _tagObject.startTime, _tagObject.endTime,
             _tagObject.averageVoice, _tagObject.tagName];
        }
    }
    
    [self initTagObject];
    _tagOffset = KFileTimeMin;
}

#pragma mark - audio delegate
/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    DebugLog(@"audioRecorderDidFinishRecording flag = %d", flag);
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    DebugLog(@"audioRecorderEncodeErrorDidOccur error = %@", error);
}

/* audioRecorderBeginInterruption: is called when the audio session has been interrupted while the recorder was recording. The recorded file will be closed. */
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    DebugLog(@"audioRecorderBeginInterruption");
}

/* audioRecorderEndInterruption:withOptions: is called when the audio session interruption has ended and this recorder had been interrupted while recording. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags NS_AVAILABLE_IOS(6_0){
    DebugLog(@"audioRecorderEndInterruption flags = %d", (int)flags);
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags NS_DEPRECATED_IOS(4_0, 6_0){
    DebugLog(@"audioRecorderEndInterruption flags = %d", (int)flags);
}

/* audioRecorderEndInterruption: is called when the preferred method, audioRecorderEndInterruption:withFlags:, is not implemented. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder NS_DEPRECATED_IOS(2_2, 6_0){
    DebugLog(@"audioRecorderEndInterruption");
}

#pragma mark - other
-(BOOL)needMarkEnd{
    BOOL res = YES;
    if (_tagObject.startTime < 0.0001) {
        res = NO;
    } else if (_markResource) {
        NSArray* tagArr = [MAUtils getArrayFromStrByCharactersInSet:_markResource character:@";"];
        if (tagArr && [tagArr count] > 0) {
            NSArray* element = [MAUtils getArrayFromStrByCharactersInSet:[tagArr lastObject] character:@"-"];
            if (_tagObject.startTime - [[element objectAtIndex:0] floatValue] < KFileTimeMin) {
                res = NO;
            }
        }
    }
    return res;
}

-(void)saveData{
    MAVoiceFiles* file = (MAVoiceFiles*)[[MACoreDataManager sharedCoreDataManager] getNewManagedObject:KCoreVoiceFiles];
    file.name = _fileName;
    file.path = _filePath;
    file.custom = MyLocal(@"custom_default");
    file.level = [MAUtils getNumberByInt:MATypeFileNormal];
    file.type = [MAUtils getNumberByInt:MATypeFileCustomDefault];
    file.time = _fileTime;
    file.duration = [NSNumber numberWithFloat:_recorder.currentTime];
    file.tag = _markResource;
    file.image = nil;
    [[MACoreDataManager sharedCoreDataManager] saveEntry];
}

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
    if (autoTimer == nil) {
        autoTimer = [NSTimer scheduledTimerWithTimeInterval:KTimeOffset target:self
                                                   selector:@selector(autoTimerOut)
                                                   userInfo:nil repeats:YES];
    }
    
    _offsetDuration = MIN(KFileTimeMin, _offsetDuration);
    _recorderTimer = _offsetDuration;
}
@end
