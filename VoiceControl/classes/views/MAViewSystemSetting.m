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
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* durationView;
@property (nonatomic, strong) UIView* markDBView;
@property (nonatomic, strong) UIView* qualityView;
@property (nonatomic, strong) UIView* contactView;
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
    [SysDelegate.viewController setGestureEnabled:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    [SysDelegate.viewController setGestureEnabled:YES];
}

- (void)initView{
    [self initDurationView];
    [self initMarkDBView];
    [self initQualityView];
    [self initContactView];
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:(CGRect){CGPointZero, self.frame.size}];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:_durationView];
    [scrollView addSubview:_markDBView];
    [scrollView addSubview:_qualityView];
    [scrollView addSubview:_contactView];
    [self addSubview:scrollView];

    scrollView.contentSize = CGSizeMake(self.frame.size.width, CGRectGetMaxY(_contactView.frame) + KNavigationHeight);
    scrollView.contentOffset  = CGPointMake(0, 0);
}

#pragma mark - duration area
-(void)initDurationView{
    _durationView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _durationView.frame = (CGRect){(CGRectGetWidth(self.frame) - CGRectGetWidth(_durationView.frame)) / 2,
        KViewVerOffset, _durationView.frame.size};
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
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(add.frame) + KViewVerOffset / 2,
                                                                 _durationView.frame.size.width, 30)];
    [_progressSlider addTarget:self action:@selector(durationSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _progressSlider.maximumValue = 1;
    _progressSlider.minimumValue = 180;
    [_durationView addSubview:_progressSlider];
}

-(void)delDuration:(id)sender{
    
}

-(void)addDuration:(id)sender{
    
}

-(void)durationSliderMoved:(id)sender{
//    _avPlay.currentTime = _progressSlider.value;
}

#pragma mark - mark db area
-(void)initMarkDBView{
    _markDBView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _markDBView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_durationView.frame), _markDBView.frame.size};
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
    
    _dbLabel = [MAUtils labelWithTxt:[[MAModel shareModel] getStringTime:[[MAModel shareModel] getFileTimeMax] type:MATypeTimeClock]
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
    _markSlider.maximumValue = 10;
    _markSlider.minimumValue = 90;
    [_markDBView addSubview:_markSlider];
}

-(void)delDB:(id)sender{
    
}

-(void)addDB:(id)sender{
    
}

-(void)markSliderMoved:(id)sender{
    //    _avPlay.currentTime = _progressSlider.value;
}

#pragma mark - quality area
-(void)initQualityView{
    _qualityView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _qualityView.frame = (CGRect){CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_markDBView.frame),
        _qualityView.frame.size};
    [_qualityView setUserInteractionEnabled:YES];
    
    UILabel* label = [MAUtils labelWithTxt:MyLocal(@"system_setting_quality_label")
                                     frame:CGRectMake(KViewVerOffset / 2, KViewVerOffset, _durationView.frame.size.width, KViewLabelHeight)
                                      font:[UIFont fontWithName:KLabelFontHelvetica size:KLabelFontSize18]
                                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    label.textAlignment = KTextAlignmentLeft;
    [_qualityView addSubview:label];
    

    
    NSArray *array=@[@"搜索\r\naa",@"选择",@"视频",@"图片"];
    UISegmentedControl* segmentControl = [[UISegmentedControl alloc]initWithItems:array];
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBordered;
    //设置位置 大小
    segmentControl.frame = CGRectMake(60, 40, 200, 50);
    //默认选择
    segmentControl.selectedSegmentIndex = 1;
    //设置背景色
    segmentControl.tintColor = [UIColor greenColor];
    [segmentControl setImage:[UIImage imageNamed:@"slider_tag.png"] forSegmentAtIndex:1];
    //设置监听事件
    [segmentControl addTarget:self action:@selector(segmentedSelected:) forControlEvents:UIControlEventValueChanged];
    [_qualityView addSubview:segmentControl];
}

-(void)segmentedSelected:(id)sender{
    
}

#pragma mark - contact area
-(void)initContactView{
    _contactView = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgSysSettingCellBg default:NO]];
    _contactView.frame = CGRectMake(CGRectGetMinX(_durationView.frame), KViewVerOffset + CGRectGetMaxY(_qualityView.frame),
        _durationView.frame.size.width, 90);
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
