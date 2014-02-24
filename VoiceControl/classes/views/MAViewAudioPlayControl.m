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
#define KTimeLabelWidth             (60)

@interface MAViewAudioPlayControl (){
//    int     currentIndex;
}

@property (nonatomic, strong) UISlider* progressSlider;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UILabel* fileLabel;
@property (nonatomic, strong) UIButton* playBtn;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic) NSMutableArray* resouceArr;

@end

@implementation MAViewAudioPlayControl

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        currentIndex = 0;
        
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
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - init area
-(void)initView{
    //add progress
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 10)];
    [_progressSlider setThumbImage:[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberKnob default:NO]
                          forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackImage:[[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberLeft default:NO] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                forState:UIControlStateNormal];
    [_progressSlider setMaximumTrackImage:[[[MAModel shareModel] getImageByType:MATypeImgSliderScrubberRight default:NO] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                forState:UIControlStateNormal];
    [_progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _progressSlider.maximumValue = 0.0;
    _progressSlider.minimumValue = 0.0;
    [self addSubview:_progressSlider];
    
    //add label
    float hOff = _progressSlider.frame.origin.y + _progressSlider.frame.size.height;
    _timeLabel = [MAUtils labelWithTxt:@""
                                 frame:CGRectMake(KSpaceOff, hOff, KTimeLabelWidth, KTimeLabelHeight)
                                  font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    _timeLabel.textAlignment = KTextAlignmentLeft;
    [self addSubview:_timeLabel];
    
    _fileLabel = [MAUtils labelWithTxt:@""
                                 frame:CGRectMake(KSpaceOff + _timeLabel.frame.origin.x + _timeLabel.frame.size.width,
                                                  hOff, self.frame.size.width , KTimeLabelHeight)
                                  font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    _fileLabel.textAlignment = KTextAlignmentLeft;
    [self addSubview:_fileLabel];
    
    //add contrl button
    UIButton* preBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                         image:[[MAModel shareModel] getImageByType:MATypeImgPlayPre default:NO]
                                      imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPre default:NO]
                                        target:self
                                        action:@selector(preBtnClicked:)];
    preBtn.frame = CGRectOffset(preBtn.frame, 20, 40);
    [self addSubview:preBtn];
    
    _playBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                 image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                              imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                target:self
                                action:@selector(playBtnClicked:)];
    _playBtn.frame = CGRectOffset(_playBtn.frame, 60, 40);
    [self addSubview:_playBtn];
    
    UIButton* nextBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                          image:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                       imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayNext default:NO]
                                         target:self
                                         action:@selector(nextBtnClicked:)];
    nextBtn.frame = CGRectOffset(nextBtn.frame, 100, 40);
    [self addSubview:nextBtn];

}

-(void)playWithPath:(NSDictionary*)resDic array:(NSArray *)array{
    if (_avPlay.playing) {
        [self stopAudio];
    }
    
    if (_timeLabel == nil) {
        [self initView];
    }
    
    //deal with message
    if (resDic) {
        _filePath = [NSString stringWithString:[resDic objectForKey:KDataBasePath]];
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
    BOOL play = YES;
    _avPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_filePath] error:nil];
    _avPlay.delegate = self;
    if (![_avPlay play]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docspath = [paths objectAtIndex:0];
        NSString* file = [docspath stringByAppendingFormat:@"/%@.zip", [resDic objectForKey:KDataBaseFileName]];
        
        if ([MAUtils unzipFiles:file unZipFielPath:nil]) {
            play = [_avPlay play];
        } else {
            play = NO;
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
        }
    }
    
    if (play) {
        _timeLabel.text = [[MAModel shareModel] getStringTime:_avPlay.currentTime type:MATypeTimeNum];
        _fileLabel.text = [resDic objectForKey:KDataBaseFileName];
        
        //slider
        _progressSlider.maximumValue = _avPlay.duration;
    }
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

- (void)detectionVoice{
    if (_avPlay && _avPlay.playing) {
        [_avPlay updateMeters];//刷新音量数据
        
        _timeLabel.text = [[MAModel shareModel] getStringTime:_avPlay.currentTime type:MATypeTimeNum];
        _progressSlider.value = _avPlay.currentTime;
    }
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
        if (self.audioPlayCallBack) {
            if (self.audioPlayCallBack(MAAudioPlayPre)) {
                DebugLog(@"2222222222222");
            } else {
                DebugLog(@"111111111111")
            }
        }
    }
}

- (void)nextBtnClicked:(id)sender{
    if (_resouceArr) {
        if (self.audioPlayCallBack) {
            if (self.audioPlayCallBack(MAAudioPlayNext)) {
                DebugLog(@"333333333333");
            } else {
                DebugLog(@"4444444444444")
            }
        }
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
