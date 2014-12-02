//
//  MAViewSystemSetting.m
//  VoiceControl
//
//  Created by apple on 14-4-15.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewSystemSetting.h"
#import "MAConfig.h"
#import "MADataManager.h"
#import "MAUtils.h"
#import "MAServerConfig.h"

#define KViewVerOffset          (10)
#define KViewLabelHeight        (20)

@interface MAViewSystemSetting ()
@property (nonatomic, strong) UIView* durationView;
@property (nonatomic, strong) UIView* markDBView;
@property (nonatomic, strong) UIView* qualityView;
@property (nonatomic, strong) UIView* contactView;
@property (nonatomic, strong) UIView* autoRecorderSwitchView;
@property (nonatomic, strong) UISlider* progressSlider;
@property (nonatomic, strong) UISlider* markSlider;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UILabel* dbLabel;
@end

@implementation MAViewSystemSetting

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSetting;
        self.viewTitle = MyLocal(@"view_title_setting");
        
        [self initView];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [SysDelegate.viewController setGestureEnabled:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    [SysDelegate.viewController setGestureEnabled:YES];
}

- (void)initView{
    [self initDurationView];
    [self initMarkDBView];
    [self initQualityView];
    [self initAutoRecorderView];
    [self initContactView];
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:(CGRect){CGPointZero, self.frame.size}];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:_durationView];
    [scrollView addSubview:_markDBView];
    [scrollView addSubview:_qualityView];
    [scrollView addSubview:_autoRecorderSwitchView];
    [scrollView addSubview:_contactView];
    [self addSubview:scrollView];

    scrollView.contentSize = CGSizeMake(self.frame.size.width, CGRectGetMaxY(_contactView.frame) + KNavigationHeight);
    scrollView.contentOffset  = CGPointMake(0, 0);
}

#pragma mark - duration area
-(void)initDurationView{
    _durationView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _durationView.frame = (CGRect){KViewVerOffset, KViewVerOffset, self.width - KViewVerOffset * 2, _durationView.height};
    [_durationView setUserInteractionEnabled:YES];
    
    //label
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_duration_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_durationView addSubview:label];

    UILabel* descr = [MAUtils labelWithTxt:MyLocal(@"system_setting_duration_describe")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset / 2 + CGRectGetMaxY(label.frame),
                                                      _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    descr.textAlignment = KTextAlignmentLeft;
    [_durationView addSubview:descr];
    
    _timeLabel = [MAUtils labelWithTxt:[[MAModel shareModel] getStringTime:[[MAModel shareModel] getFileTimeMax] type:MATypeTimeClock]
                                 frame:CGRectMake(0, 0, _durationView.frame.size.width, KViewLabelHeight)
                                  font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    _timeLabel.center = CGPointMake(_durationView.center.x, CGRectGetMaxY(descr.frame) + KViewVerOffset * 2);
    [_durationView addSubview:_timeLabel];
    
    //button
    UIButton* del = [MAUtils buttonWithImg:MyLocal(@"system_setting_del_five") off:0 zoomIn:NO
                                image:[UIImage imageNamed:@"button_color1.png"]
                             imagesec:[UIImage imageNamed:@"button_color4.png"]
                               target:self
                               action:@selector(delDuration:)];
    [del setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgBtnGrayCircle default:NO]
                        forState:UIControlStateDisabled];
    del.frame = CGRectMake(KViewVerOffset, CGRectGetMaxY(descr.frame) + KViewVerOffset / 2, 60, 30);
    [del setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
                   forState:UIControlStateNormal];
    [del setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
                   forState:UIControlStateHighlighted];
    [_durationView addSubview:del];
    
    UIButton* add = [MAUtils buttonWithImg:MyLocal(@"system_setting_add_five") off:0 zoomIn:NO
                                     image:[UIImage imageNamed:@"button_color1.png"]
                                  imagesec:[UIImage imageNamed:@"button_color4.png"]
                                    target:self
                                    action:@selector(addDuration:)];
    [add setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgBtnGrayCircle default:NO]
                   forState:UIControlStateDisabled];
    add.frame = (CGRect){_durationView.frame.size.width - KViewVerOffset - del.frame.size.width, CGRectGetMinY(del.frame), del.frame.size};
    [add setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
              forState:UIControlStateNormal];
    [add setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
              forState:UIControlStateHighlighted];
    [_durationView addSubview:add];
    
    //progress
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(add.frame),
                                                                 _durationView.frame.size.width, 30)];
    [_progressSlider addTarget:self action:@selector(durationSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _progressSlider.maximumValue = 180;
    _progressSlider.minimumValue = 1;
    [_progressSlider setMinimumTrackTintColor:[[MAModel shareModel] getColorByType:MATypeColorLightBlue default:NO]];
    _progressSlider.value = [[MAModel shareModel] getFileTimeMax] / 60;
    [_durationView addSubview:_progressSlider];
}

-(void)delDuration:(id)sender{
    int max = [[MAModel shareModel] getFileTimeMax];
    max -= 300;
    max = max > 60 ? max : 60;
    _progressSlider.value = max / 60;
    [_timeLabel setText:[[MAModel shareModel] getStringTime:max type:MATypeTimeClock]];
    [MADataManager setDataByKey:[NSNumber numberWithInt:max] forkey:KUserDefaultFileTimeMax];
}

-(void)addDuration:(id)sender{
    int max = [[MAModel shareModel] getFileTimeMax];
    max += 300;
    max = max > 180 * 60 ? 180 * 60 : max;
    _progressSlider.value = max / 60;
    [_timeLabel setText:[[MAModel shareModel] getStringTime:max type:MATypeTimeClock]];
    [MADataManager setDataByKey:[NSNumber numberWithInt:max] forkey:KUserDefaultFileTimeMax];
}

-(void)durationSliderMoved:(id)sender{
    int max = _progressSlider.value * 60;
    [_timeLabel setText:[[MAModel shareModel] getStringTime:max type:MATypeTimeClock]];
    [MADataManager setDataByKey:[NSNumber numberWithInt:max] forkey:KUserDefaultFileTimeMax];
}

#pragma mark - mark db area
-(void)initMarkDBView{
    _markDBView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _markDBView.frame = (CGRect){KViewVerOffset, KViewVerOffset + CGRectGetMaxY(_durationView.frame), self.width - KViewVerOffset * 2, _markDBView.height};
    [_markDBView setUserInteractionEnabled:YES];
    
    //label
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_mark_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_markDBView addSubview:label];
    
    UILabel* descr = [MAUtils labelWithTxt:MyLocal(@"system_setting_mark_describe")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset / 2 + CGRectGetMaxY(label.frame),
                                                      _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    descr.textAlignment = KTextAlignmentLeft;
    [_markDBView addSubview:descr];
    
    _dbLabel = [MAUtils labelWithTxt:[MAUtils getStringByInt:[[MAModel shareModel] getTagVoice]]
                                 frame:CGRectMake(0, 0, _markDBView.frame.size.width, KViewLabelHeight)
                                  font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    _dbLabel.center = CGPointMake(_markDBView.center.x, CGRectGetMaxY(descr.frame) + KViewVerOffset * 2);
    [_markDBView addSubview:_dbLabel];
    
    //button
    UIButton* del = [MAUtils buttonWithImg:MyLocal(@"system_setting_del_db") off:0 zoomIn:NO
                                     image:[UIImage imageNamed:@"button_color1.png"]
                                  imagesec:[UIImage imageNamed:@"button_color4.png"]
                                    target:self
                                    action:@selector(delDB:)];
    [del setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgBtnGrayCircle default:NO]
                   forState:UIControlStateDisabled];
    del.frame = CGRectMake(KViewVerOffset, CGRectGetMaxY(descr.frame) + KViewVerOffset / 2, 60, 30);
    [del setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
              forState:UIControlStateNormal];
    [del setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
              forState:UIControlStateHighlighted];
    [_markDBView addSubview:del];
    
    UIButton* add = [MAUtils buttonWithImg:MyLocal(@"system_setting_add_db") off:0 zoomIn:NO
                                     image:[UIImage imageNamed:@"button_color1.png"]
                                  imagesec:[UIImage imageNamed:@"button_color4.png"]
                                    target:self
                                    action:@selector(addDB:)];
    [add setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgBtnGrayCircle default:NO]
                   forState:UIControlStateDisabled];
    add.frame = (CGRect){_durationView.frame.size.width - KViewVerOffset - del.frame.size.width, CGRectGetMinY(del.frame), del.frame.size};
    [add setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
              forState:UIControlStateNormal];
    [add setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
              forState:UIControlStateHighlighted];
    [_markDBView addSubview:add];
    
    //progress
    _markSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(add.frame) + KViewVerOffset / 2,
                                                             _markDBView.frame.size.width, 30)];
    [_markSlider addTarget:self action:@selector(markSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _markSlider.maximumValue = 90;
    _markSlider.minimumValue = 10;
    [_markSlider setMinimumTrackTintColor:[[MAModel shareModel] getColorByType:MATypeColorLightBlue default:NO]];
    _markSlider.value = [[MAModel shareModel] getTagVoice];
    [_markDBView addSubview:_markSlider];
}

-(void)delDB:(id)sender{
    int tag = [[MAModel shareModel] getTagVoice];
    tag -= 5;
    tag = tag > 10 ? tag : 10;
    _markSlider.value = tag;
    [_dbLabel setText:[MAUtils getStringByInt:tag]];
    [MADataManager setDataByKey:[NSNumber numberWithInt:tag] forkey:KUserDefaultMarkVoice];
}

-(void)addDB:(id)sender{
    int tag = [[MAModel shareModel] getTagVoice];
    tag += 5;
    tag = tag > 90 ? 90 : tag;
    _markSlider.value = tag;
    [_dbLabel setText:[MAUtils getStringByInt:tag]];
    [MADataManager setDataByKey:[NSNumber numberWithInt:tag] forkey:KUserDefaultMarkVoice];
}

-(void)markSliderMoved:(id)sender{
    [_dbLabel setText:[MAUtils getStringByInt:_markSlider.value]];
    [MADataManager setDataByKey:[NSNumber numberWithInt:_markSlider.value] forkey:KUserDefaultMarkVoice];
}

#pragma mark - quality area
-(void)initQualityView{
    _qualityView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _qualityView.frame = (CGRect){KViewVerOffset, KViewVerOffset + CGRectGetMaxY(_markDBView.frame), self.width - KViewVerOffset * 2, _qualityView.height};
    [_qualityView setUserInteractionEnabled:YES];
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_quality_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_qualityView addSubview:label];
    
    //segment
    NSArray *array=@[MyLocal(@"system_setting_quality_low"), MyLocal(@"system_setting_quality_normal"), MyLocal(@"system_setting_quality_high")];
    UISegmentedControl* segmentControl = [[UISegmentedControl alloc]initWithItems:array];
    //设置字体属性
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName,
                         [UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18], NSFontAttributeName, nil];
    [segmentControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    //设置位置 大小
    segmentControl.frame = CGRectMake((_qualityView.frame.size.width - 270) / 2, CGRectGetMaxY(label.frame) + KViewVerOffset, 270, 40);
    //默认选择
    segmentControl.selectedSegmentIndex = [[MADataManager getDataByKey:KUserDefaultQualityLevel] intValue] - MARecorderQualityLow;
    //设置背景色
    segmentControl.tintColor = [[MAModel shareModel] getColorByType:MATypeColorLightGreen default:NO];
//    [segmentControl setImage:[[UIImage imageNamed:@"slider_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
    //设置监听事件
    [segmentControl addTarget:self action:@selector(segmentedSelected:) forControlEvents:UIControlEventValueChanged];
    [_qualityView addSubview:segmentControl];
    
    //describle
    UILabel* label1 = [MAUtils labelWithTxt:MyLocal(@"system_setting_quality_des_low")
                                      frame:CGRectMake(CGRectGetMinX(segmentControl.frame), KViewVerOffset / 2 + CGRectGetMaxY(segmentControl.frame), 90, KViewLabelHeight)
                                       font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize14]
                                      color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_qualityView addSubview:label1];
    UILabel* label2 = [MAUtils labelWithTxt:MyLocal(@"system_setting_quality_des_normal")
                                      frame:CGRectMake(CGRectGetMaxX(label1.frame), CGRectGetMinY(label1.frame), 90, KViewLabelHeight)
                                       font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize14]
                                      color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_qualityView addSubview:label2];
    UILabel* label3 = [MAUtils labelWithTxt:MyLocal(@"system_setting_quality_des_high")
                                      frame:CGRectMake(CGRectGetMaxX(label2.frame), CGRectGetMinY(label1.frame), 90, KViewLabelHeight)
                                       font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize14]
                                      color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_qualityView addSubview:label3];
}

-(void)segmentedSelected:(id)sender{
    [[MAModel shareModel] resetRecorderQuality:[(UISegmentedControl*)sender selectedSegmentIndex] + MARecorderQualityLow];
}

#pragma mark - aruto recorder area
- (void)initAutoRecorderView {
    _autoRecorderSwitchView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _autoRecorderSwitchView.frame = (CGRect){KViewVerOffset, KViewVerOffset + CGRectGetMaxY(_qualityView.frame),
        self.width - KViewVerOffset * 2, 90};
    [_autoRecorderSwitchView setUserInteractionEnabled:YES];
 
    //label
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_auto_recorder")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_autoRecorderSwitchView addSubview:label];

    
    //label
    UILabel* descr = [MAUtils labelWithTxt:MyLocal(@"system_setting_auto_recorder_desc")
                                     frame:CGRectMake(KViewVerOffset, CGRectGetMaxY(label.frame) + 15,
                                                      _durationView.frame.size.width * 0.6, KViewLabelHeight * 2)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize16]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorBtnGray default:NO]];
    descr.textAlignment = KTextAlignmentLeft;
    descr.numberOfLines = 0;
    [_autoRecorderSwitchView addSubview:descr];
    
    //switch
    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(_autoRecorderSwitchView.width - (IsPad ? 100 : 70),
                                                                    CGRectGetMaxY(label.frame) + 15, 0, 0)];
    [switcher setOn:[[MADataManager getDataByKey:KUserDefaultAutoRecorder] boolValue]];
    [switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [_autoRecorderSwitchView addSubview:switcher];
}

-(void)switchAction:(UISwitch *)sender{
    [[MAModel shareModel] setAutoRecorder:[sender isOn]];
}

#pragma mark - contact area
-(void)initContactView{
    _contactView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _contactView.frame = (CGRect){KViewVerOffset, KViewVerOffset + CGRectGetMaxY(_autoRecorderSwitchView.frame), self.width - KViewVerOffset * 2, 90};
    [_contactView setUserInteractionEnabled:YES];
    
    //label
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_contact_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_contactView addSubview:label];
    
    //button
    UIButton* contact = [MAUtils buttonWithImg:MyLocal(@"system_setting_contact") off:0 zoomIn:NO
                                     image:[UIImage imageNamed:@"button_color1.png"]
                                  imagesec:[UIImage imageNamed:@"button_color4.png"]
                                    target:self
                                    action:@selector(contactUs:)];
    contact.titleLabel.font = [UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize16];
    contact.frame = CGRectMake(KViewVerOffset, CGRectGetMaxY(label.frame) + KViewVerOffset,
                               (_contactView.frame.size.width - KViewVerOffset * 3) / 2, 40);
    [contact setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
              forState:UIControlStateNormal];
    [contact setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
              forState:UIControlStateHighlighted];
    [contact setSelected:YES];
    [_contactView addSubview:contact];
    
    UIButton* evaluation = [MAUtils buttonWithImg:MyLocal(@"system_setting_evaluation") off:0 zoomIn:NO
                                     image:[UIImage imageNamed:@"button_color2.png"]
                                  imagesec:[UIImage imageNamed:@"button_color3.png"]
                                    target:self
                                    action:@selector(evaluateApp:)];
    evaluation.titleLabel.font = [UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize16];
    evaluation.frame = (CGRect){CGRectGetMaxX(contact.frame) + KViewVerOffset, CGRectGetMinY(contact.frame), contact.frame.size};
    [evaluation setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
              forState:UIControlStateNormal];
    [evaluation setTitleColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
              forState:UIControlStateHighlighted];
    [_contactView addSubview:evaluation];
}

-(void)contactUs:(id)sender{
    NSMutableDictionary* mailDic = [[NSMutableDictionary alloc] init];
    [mailDic setObject:[NSArray arrayWithObject:MyLocal(@"system_setting_mail_to")] forKey:KMailToRecipients];
    [mailDic setObject:MyLocal(@"system_setting_mail_subject") forKey:KMailSubject];
    NSString* body = [NSString stringWithFormat:MyLocal(@"system_setting_mail_body"), [MAUtils getAppVersion]];
    [mailDic setObject:body forKey:KMailBody];
    [SysDelegate.viewController sendEMail:mailDic];
    
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobLogEvent eventName:KAboutUsSendMail label:nil];
}

-(void)evaluateApp:(id)sender{
    [MAUtils openUrl:KIosItunesIP];
}
@end
