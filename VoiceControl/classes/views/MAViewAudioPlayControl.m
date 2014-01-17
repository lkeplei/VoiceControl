//
//  MAViewAudioPlayControl.m
//  VoiceControl
//
//  Created by ken on 13-7-26.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewAudioPlayControl.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MAModel.h"

#define KSpaceOff                   (10)
#define KTimeLabelHeight            (20)
#define KTimeLabelWidth             (100)

@interface MAViewAudioPlayControl (){
    int     currentIndex;
}

@property (nonatomic, strong) UISlider* progressSlider;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UIButton* playBtn;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic) NSMutableArray* resouceArr;

@end

@implementation MAViewAudioPlayControl

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        currentIndex = 0;
        
        // Initialization code
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];
        
        //subscription 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        //set back ground alpha
        [self setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
        
        //set gestures
        [self setupGestures];
    }
    return self;
}

#pragma mark - init area
-(void)initView{
    _timeLabel = [MAUtils labelWithTxt:@""
                                   frame:CGRectMake(self.frame.size.width - KSpaceOff - KTimeLabelWidth,
                                                    self.frame.size.height - KTimeLabelHeight, KTimeLabelWidth, KTimeLabelHeight)
                                    font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize16]
                                   color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    _timeLabel.textAlignment = UITextAlignmentRight;
    [self addSubview:_timeLabel];
    
    //add progress
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, self.frame.size.height * 1 / 7, 260, 10)];
    [_progressSlider setThumbImage:LOADIMAGE(@"AudioPlayerScrubberKnob", @"png")
                          forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                forState:UIControlStateNormal];
    [_progressSlider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                forState:UIControlStateNormal];
    [_progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _progressSlider.maximumValue = 0.0;
    _progressSlider.minimumValue = 0.0;
    [self addSubview:_progressSlider];
    
    //add contrl button
    UIButton* preBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                         image:[[MAModel shareModel] getImageByType:MATypeImgPlayPre default:NO]
                                      imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPre default:NO]
                                        target:self
                                        action:@selector(preBtnClicked:)];
    preBtn.frame = CGRectOffset(preBtn.frame, 30, 40);
    [self addSubview:preBtn];
    
    _playBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                 image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                              imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                target:self
                                action:@selector(playBtnClicked:)];
    _playBtn.frame = CGRectOffset(_playBtn.frame, 70, 40);
    [self addSubview:_playBtn];
    
    UIButton* nextBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                          image:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                       imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                         target:self
                                         action:@selector(nextBtnClicked:)];
    nextBtn.frame = CGRectOffset(nextBtn.frame, 110, 40);
    [self addSubview:nextBtn];

}

-(void)playWithPath:(NSString*)path array:(NSArray *)array{
    if (_avPlay.playing) {
        [self stopAudio];
    }
    
    if (_timeLabel == nil) {
        [self initView];
    }
    
    //deal with message
    if (path) {
        _filePath = [NSString stringWithString:path];
    } else {
        if (_filePath == nil) {
            DebugLog(@"no file path coming");
            return;
        }
    }
    
    if (array) {
        if (_resouceArr == nil) {
            _resouceArr = [[NSMutableArray alloc] init];
        } else {
            [_resouceArr removeAllObjects];
        }
        
        [_resouceArr addObjectsFromArray:array];
        
        if (path) {
            for (int i = 0; i < [array count]; i++) {
                NSDictionary* resDic = [array objectAtIndex:i];
                NSString* file = [resDic objectForKey:KDataBasePath];
                if ([file compare:path] == NSOrderedSame) {
                    currentIndex = i;
                    break;
                }
            }
        }
    }
    
    //set btn
    if (_playBtn) {
        [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                            forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                            forState:UIControlStateHighlighted];
        [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                            forState:UIControlStateSelected];
    }

    //play
    _avPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_filePath] error:nil];
    _avPlay.delegate = self;
    [_avPlay play];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    _timeLabel.text = [[MAModel shareModel] getStringTime:_avPlay.duration type:MATypeTimeNum];
    
    //slider
    _progressSlider.maximumValue = _avPlay.duration;
}

- (void)stopAudio{
    if (_avPlay.playing) {
        //stop
        [_avPlay stop];
        
        //set btn
        if (_playBtn) {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateSelected];
        }
    }
}

- (void)detectionVoice
{
    [_avPlay updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
//    double lowPassResults = pow(10, (0.05 * [_avPlay peakPowerForChannel:0]));
    _timeLabel.text = [[MAModel shareModel] getStringTime:(_avPlay.duration - _avPlay.currentTime) type:MATypeTimeNum];

    _progressSlider.value = _avPlay.currentTime;
}

#pragma mark - btn clicked
- (void)playBtnClicked:(id)sender{
    if (_avPlay.playing) {
        [_avPlay pause];

        //set btn
        if (_playBtn) {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateSelected];
        }
    } else {
        [_avPlay play];
        
        //set btn
        if (_playBtn) {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateSelected];
        }
    }
}

- (void)preBtnClicked:(id)sender{
    if (_resouceArr) {
        int count = _resouceArr.count;
        
        currentIndex--;
        if (currentIndex < 0 || currentIndex >= count) {
            currentIndex = count - 1;
        }
        [self playWithPath:[[_resouceArr objectAtIndex:currentIndex] objectForKey:KDataBasePath] array:nil];
    }
}

- (void)nextBtnClicked:(id)sender{
    if (_resouceArr) {
        int count = _resouceArr.count;
        
        currentIndex++;
        if (currentIndex >= count) {
            currentIndex = 0;
        }
        [self playWithPath:[[_resouceArr objectAtIndex:currentIndex] objectForKey:KDataBasePath] array:nil];
    }
}

#pragma mark - slider
-(void)progressSliderMoved:(id)sender{
    _avPlay.currentTime = _progressSlider.value;
}

#pragma mark Swipe Gesture Setup/Actions
-(void)setupGestures {
	UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTime:)];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:tapRecognizer];
}

-(void)tapTime:(id)sender {
    DebugLog(@"tap");
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
	CGPoint tapPoint = [(UITapGestureRecognizer*)sender locationInView:self];
    CGRect rect = CGRectMake(_progressSlider.frame.origin.x, _progressSlider.frame.origin.y - 10,
                             _progressSlider.frame.size.width, _progressSlider.frame.size.height + 20);
    if (CGRectContainsPoint(rect, tapPoint)) {
        float p = (tapPoint.x - _progressSlider.frame.origin.x) / _progressSlider.frame.size.width;
        _avPlay.currentTime = _avPlay.duration * p;
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    DebugLog(@"finished");
    _progressSlider.value = 0;
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    DebugLog(@"decode error");
}

#pragma mark - multi task
- (void)applicationDidEnterBackground:(UIApplication *)application{
    DebugLog(@"app did enter back ground");
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    DebugLog(@"app will enter back ground");
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}
@end
