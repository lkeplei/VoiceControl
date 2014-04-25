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

#define KShowFileViewHeight             (120)

@interface MAViewRecorderFile ()
@property (nonatomic, strong) UIView* showFileView;
@property (nonatomic, strong) UIButton* playButton;
@property (nonatomic, strong) UISlider* durationSlider;
@property (nonatomic, strong) UITextField* renameField;
@end

@implementation MAViewRecorderFile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeRecorderFile;
        self.viewTitle = MyLocal(@"view_title_recorder_file");
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:MyLocal(@"file_top_more") enabled:YES];
}

-(void)showView{
    //show file view
    _showFileView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.frame.size.width, KShowFileViewHeight}];
    [_showFileView setBackgroundColor:[UIColor blackColor]];
    [self addSubview:_showFileView];
    
    _playButton = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                   image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                  target:self
                                  action:@selector(playBtnClicked:)];
    [_showFileView addSubview:_playButton];
    
    _durationSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame), KShowFileViewHeight - 30,
                                                                 260, 30)];
    [_durationSlider addTarget:self action:@selector(durationSliderMoved:) forControlEvents:UIControlEventValueChanged];
    _durationSlider.minimumValue = 0;
    _durationSlider.maximumValue = 0;
    [_showFileView addSubview:_durationSlider];
    
    //reanme
    _renameField = [MAUtils textFieldInit:CGRectMake(10, CGRectGetMaxY(_showFileView.frame), 300, 30)
                                         color:[UIColor magentaColor]
                                       bgcolor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]
                                          secu:NO
                                          font:[[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize14]
                                          text:MyLocal(@"custom_default")];
    _renameField.delegate = self;
    _renameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    _renameField.layer.borderColor = [UIColor lightGrayColor].CGColor; // set color as you want.
//    _renameField.layer.borderWidth = 1.0;
//    _renameField.layer.cornerRadius = 4.f;
    [self addSubview:_renameField];
    
    //describle
    
    //tab bar
}

#pragma mark - btn clicked
-(void)playBtnClicked:(id)sender{
    
}

#pragma mark - slider
-(void)durationSliderMoved:(id)sender{
    
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
}

#pragma mark - other
-(void)eventTopBtnClicked:(BOOL)left{
    if (left)  {
        [self popView:MATypeChangeViewCurlUp];
    }
}

@end
