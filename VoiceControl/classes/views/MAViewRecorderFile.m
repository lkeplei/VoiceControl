//
//  MAViewRecorderFile.m
//  VoiceControl
//
//  Created by apple on 14-4-25.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewRecorderFile.h"
#import "MAConfig.h"
#import "MAModel.h"
#import "MAUtils.h"
#import "MAVoiceFiles.h"
#import "MARecordController.h"
#import "MAViewTagManager.h"
#import "MACoreDataManager.h"

#define KRecorderFileOffset             (5)
#define KMessageViewHeight              (30)
#define KShowFileViewHeight             (250)

#define KTabbarItem1Tag                 (100)
#define KTabbarItem2Tag                 (101)
#define KTabbarItem3Tag                 (102)
#define KTabbarItem4Tag                 (103)
#define KTextViewLabelTag               (200)

@interface MAViewRecorderFile (){
    uint16_t    currentIndex;
    CGRect hudRect;
}

@property (nonatomic, copy) NSMutableArray* resourceArray;
@property (nonatomic, strong) UIView* tabbarView;
@property (nonatomic, strong) UIButton* playButton;
@property (nonatomic, strong) UISlider* durationSlider;
@property (nonatomic, strong) UITextField* renameField;
@property (nonatomic, strong) UITextView* describleTextView;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property (nonatomic, strong) MAVoiceFiles* voiceFile;
@property (nonatomic, strong) UILabel* durationLabel;
@property (nonatomic, strong) UILabel* dateLabel;
@property (nonatomic, strong) UILabel* timeLabel;

@end

@implementation MAViewRecorderFile

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeRecorderFile;
        self.viewTitle = MyLocal(@"view_title_recorder_file");
        
        currentIndex = 0;
        
        [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:MyLocal(@"file_top_more") enabled:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    if (_voiceFile) {
        _voiceFile.custom = [NSString stringWithFormat:@"%@%@%@", _renameField.text, KCharactersInSetCustom, _describleTextView.text];
        [[MACoreDataManager sharedCoreDataManager] saveEntry];
    }
}

-(void)showView{
    //msgView
    [self initMessageView];
    
    //play btn and slider
    [self initControlView];
    
    //reanme
    _renameField = [MAUtils textFieldInit:CGRectMake(10, KShowFileViewHeight, 300, KMessageViewHeight)
                                         color:[UIColor magentaColor]
                                       bgcolor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
                                          secu:NO
                                          font:[[MAModel shareModel] getLabelFontSize:KLabelFontArial size:KLabelFontSize14]
                                          text:MyLocal(@"custom_default")];
    _renameField.delegate = self;
    _renameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:_renameField];
    
    //describle
    _describleTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 15 + CGRectGetMaxY(_renameField.frame), 300,
                                                                      self.frame.size.height - 20 - KNavigationHeight - CGRectGetMaxY(_renameField.frame))];
    _describleTextView.scrollEnabled = YES;
    _describleTextView.font = [[MAModel shareModel] getLabelFontSize:KLabelFontArial size:KLabelFontSize14];
    _describleTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _describleTextView.delegate = self;
    [self addSubview:_describleTextView];
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"recorder_decrible_default")
                                     frame:CGRectMake(5, 2, 300, 30)
                                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize16]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    label.tag = KTextViewLabelTag;
    label.textAlignment = KTextAlignmentLeft;
    [_describleTextView addSubview:label];

    //tab bar
    [self initTabbarView];
}

-(void)initMessageView{
    hudRect = CGRectMake(0, KMessageViewHeight, self.frame.size.width, KShowFileViewHeight - KMessageViewHeight * 2 - KRecorderFileOffset * 2);
    UIView* mesView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.frame.size.width, KMessageViewHeight}];
    [mesView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorViewBg default:NO]];
    [self addSubview:mesView];
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KMessageViewHeight, KMessageViewHeight)];
    [view setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorBtnRed default:NO]];
    [mesView addSubview:view];
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"1")
                                     frame:view.frame
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize22]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [view addSubview:label];
    
    _durationLabel = [MAUtils labelWithTxt:[[MAModel shareModel] getStringTime:0 type:MATypeTimeClock]
                                     frame:CGRectMake(KMessageViewHeight + 10, 0, 200, KMessageViewHeight)
                                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorBtnDarkGreen default:NO]];
    _durationLabel.textAlignment = KTextAlignmentLeft;
    [mesView addSubview:_durationLabel];
    
    _dateLabel = [MAUtils labelWithTxt:nil
                                 frame:CGRectMake(110, 0, 160, KMessageViewHeight / 2)
                                  font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    _dateLabel.textAlignment = KTextAlignmentRight;
    [view addSubview:_dateLabel];
    
    _timeLabel = [MAUtils labelWithTxt:nil
                                 frame:CGRectMake(110, KMessageViewHeight / 2, 205, KMessageViewHeight / 2)
                                  font:[UIFont fontWithName:KLabelFontArial size:10]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    _timeLabel.textAlignment = KTextAlignmentRight;
    [view addSubview:_timeLabel];
}

-(void)initControlView{
    UIView* conView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(hudRect), self.frame.size.width, KMessageViewHeight + KRecorderFileOffset * 2)];
    [conView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorTopView default:NO]];
    [self addSubview:conView];
    
    _playButton = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                   image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                  target:self
                                  action:@selector(playBtnClicked:)];
    _playButton.frame = (CGRect){KRecorderFileOffset, KRecorderFileOffset, _playButton.frame.size};
    [conView addSubview:_playButton];
    
    _durationSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame) + KRecorderFileOffset, KRecorderFileOffset, 270, KMessageViewHeight)];
    [_durationSlider addTarget:self action:@selector(durationSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _durationSlider.minimumValue = 0;
    _durationSlider.maximumValue = 0;
    [conView addSubview:_durationSlider];
}

-(void)initTabbarView{
    _tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - KNavigationHeight,
                                                           self.frame.size.width, KNavigationHeight)];
    [_tabbarView setBackgroundColor:[UIColor blackColor]];
    [self addSubview:_tabbarView];
    
    float width = _tabbarView.frame.size.width / 4;
    UIButton* item1 = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                       image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                    imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                      target:self
                                      action:@selector(tabbarItemClicked:)];
    item1.tag = KTabbarItem1Tag;
    item1.frame = CGRectMake(0, 0, width, _tabbarView.frame.size.height);
    [_tabbarView addSubview:item1];
    
    UIButton* item2 = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                       image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                    imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                      target:self
                                      action:@selector(tabbarItemClicked:)];
    item2.tag = KTabbarItem2Tag;
    item2.frame = (CGRect){CGRectGetMaxX(item1.frame), 0, item1.frame.size};
    [_tabbarView addSubview:item2];
    
    UIButton* item3 = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                       image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                    imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                      target:self
                                      action:@selector(tabbarItemClicked:)];
    item3.tag = KTabbarItem3Tag;
    item3.frame = (CGRect){CGRectGetMaxX(item2.frame), 0, item1.frame.size};
    [_tabbarView addSubview:item3];
    
    UIButton* item4 = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                       image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                    imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                      target:self
                                      action:@selector(tabbarItemClicked:)];
    item4.tag = KTabbarItem4Tag;
    item4.frame = (CGRect){CGRectGetMaxX(item3.frame), 0, item1.frame.size};
    [_tabbarView addSubview:item4];
}

-(void)setPlayBtnStatus:(BOOL)play{
    if (_playButton) {
        if (play) {
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateNormal];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateHighlighted];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateSelected];
        } else {
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateNormal];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateHighlighted];
            [_playButton setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateSelected];
        }
    }
}

- (void)detectionVoice{
    if (_avPlay && _avPlay.playing) {
        [_avPlay updateMeters];//刷新音量数据
        
        _durationSlider.value = _avPlay.currentTime;
        _durationLabel.text = [[MAModel shareModel] getStringTime:[_voiceFile.duration intValue] - _avPlay.currentTime type:MATypeTimeClock];
    } else {
        [self setPlayBtnStatus:YES];
    }
}

#pragma mark - audio player
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _durationSlider.value = 0;
    _durationLabel.text = [[MAModel shareModel] getStringTime:[_voiceFile.duration intValue] type:MATypeTimeClock];
}

#pragma mark - btn clicked
-(void)playBtnClicked:(id)sender{
    if (_avPlay) {
        if (_avPlay.playing) {
            [_avPlay pause];
            
            [self setPlayBtnStatus:YES];
        } else {
            [_avPlay play];
            
            [self setPlayBtnStatus:NO];
        }
    } else {
        [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
    }
}

-(void)tabbarItemClicked:(id)sender{
    if (_avPlay) {
        UIButton* btn = (UIButton*)sender;
        if (btn.tag == KTabbarItem1Tag) {
            if ([_avPlay play]) {
                [_avPlay pause];
            }
            
            MAViewBase* view = [SysDelegate.viewController getView:MaviewTypeTagManager];
            [self pushView:view animatedType:MATypeChangeViewCurlDown];
            [(MAViewTagManager*)view initTagObject:[_resourceArray objectAtIndex:currentIndex]];
        } else if (btn.tag == KTabbarItem2Tag) {
            [[[UIAlertView alloc] initWithTitle:MyLocal(@"more_user_management_title")
                                        message:MyLocal(@"more_user_management_title")
                                       delegate:self
                              cancelButtonTitle:MyLocal(@"cancel")
                              otherButtonTitles:MyLocal(@"ok"), nil] show];
        } else if (btn.tag == KTabbarItem3Tag) {
        } else if (btn.tag == KTabbarItem4Tag) {
        }
    } else {
        [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KFileManDelete label:nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docspath = [paths objectAtIndex:0];
        //删除数据库与文件
        [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.zip", _voiceFile.name]];
        [MAUtils deleteFileWithPath:[docspath stringByAppendingFormat:@"/%@.aac", _voiceFile.name]];
        [[MACoreDataManager sharedCoreDataManager] deleteObject:_voiceFile];
        
        _voiceFile =  nil;
        
        [self popView:MATypeChangeViewCurlUp];
    }
}

#pragma mark - slider
-(void)durationSliderMoved:(id)sender{
    if (![_avPlay isPlaying]) {
        [_avPlay play];
        [self setPlayBtnStatus:NO];
    }
    
    _avPlay.currentTime = _durationSlider.value;
}

#pragma mark - text field
- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_renameField isExclusiveTouch]) {
        [_renameField resignFirstResponder];
    }
    
    if (![_describleTextView isExclusiveTouch]) {
        [_describleTextView resignFirstResponder];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    UIView* label = [textView viewWithTag:KTextViewLabelTag];
    if (textView.text.length == 0) {
        [label setHidden:NO];
    } else {
        if (![label isHidden]) {
            [label setHidden:YES];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

#pragma mark - other
-(void)eventTopBtnClicked:(BOOL)left{
    if (left)  {
        [self popView:MATypeChangeViewCurlUp];
    }
}

-(void)initResource:(uint16_t)index array:(NSArray*)array{
    _resourceArray = [array copy];
    currentIndex = index;
    
    _voiceFile = [_resourceArray objectAtIndex:currentIndex];
    
    //初始avplay
    BOOL play = YES;
    if (![MAUtils fileExistsAtPath:_voiceFile.path]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docspath = [paths objectAtIndex:0];
        NSString* fileName = [docspath stringByAppendingFormat:@"/%@.zip", _voiceFile.name];
        
        if (![MAUtils unzipFiles:fileName unZipFielPath:nil]) {
            play = NO;
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"file_cannot_open") time:1];
        }
    }
    
    if (play) {
        _avPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_voiceFile.path] error:nil];
        _avPlay.delegate = self;
        _durationSlider.maximumValue = _avPlay.duration;
    }
    
    //view content
    NSArray* contentArr = [MAUtils getArrayFromStrByCharactersInSet:_voiceFile.custom character:KCharactersInSetCustom];
    if ([contentArr count] >= 1) {
        _renameField.text = [contentArr objectAtIndex:0];
    }
    if ([contentArr count] >= 2) {
        _describleTextView.text = [contentArr objectAtIndex:1];
        [self textViewDidChange:_describleTextView];
    }
    
    _durationLabel.text = [[MAModel shareModel] getStringTime:[_voiceFile.duration intValue] type:MATypeTimeClock];
    _dateLabel.text = [MAUtils getStringFromDate:_voiceFile.time format:@"MMM dd,yyyy"];
    NSDate* endTime = [_voiceFile.time dateByAddingTimeInterval:[_voiceFile.duration intValue]];
    _timeLabel.text = [NSString stringWithFormat:@"%@ - %@", [MAUtils getStringFromDate:_voiceFile.time format:@"HH:mm:ss"], [MAUtils getStringFromDate:endTime format:@"HH:mm:ss"]];
}

#pragma mark - Drawing operations
- (void)drawRect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *strokeColor = [UIColor colorWithRed:0.886 green:0.0 blue:0.0 alpha:0.8];
    UIColor *fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    UIColor *gradientColor = [UIColor colorWithRed:0.72 green:0.76 blue:0.8 alpha:0.7];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:
                               (id)fillColor.CGColor,
                               (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:hudRect cornerRadius:1.0];
    CGContextSaveGState(context);
    [border addClip];
    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(hudRect.origin.x + hudRect.size.width / 2, 120), 10,
                                CGPointMake(hudRect.origin.x + hudRect.size.width / 2, 195), 215,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    border.lineWidth = 0;       //设置边框宽度
    [border stroke];

    // Draw sound meter wave
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] set];
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
//    int baseLine = hudRect.origin.y + hudRect.size.height / 2;
//    int multiplier = 1;
//    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--){
//        multiplier = ((int)x % 2) == 0 ? 1 : -1;
//        
//        CGFloat y = baseLine + ((KMaxValueOfMetaer * (KMaxLengthOfWave - abs(soundMeters[(int)x]))) / KMaxLengthOfWave) * multiplier;
//        
//        if(x == SOUND_METER_COUNT - 1) {
//            CGContextMoveToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 4, y);
//            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 2, y);
//        }
//        else {
//            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 4, y);
//            CGContextAddLineToPoint(context, x * (KHudSizeWidth / SOUND_METER_COUNT) + hudRect.origin.x + 2, y);
//        }
//    }
    
    CGContextStrokePath(context);
}
@end
