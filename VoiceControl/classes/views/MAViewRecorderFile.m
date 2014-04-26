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

#define KShowFileViewHeight             (150)

#define KTabbarItem1Tag                 (100)
#define KTabbarItem2Tag                 (101)
#define KTabbarItem3Tag                 (102)
#define KTabbarItem4Tag                 (103)
#define KTextViewLabelTag               (200)

@interface MAViewRecorderFile (){
    uint16_t    currentIndex;
}

@property (nonatomic, copy) NSMutableArray* resourceArray;
@property (nonatomic, strong) UIView* showFileView;
@property (nonatomic, strong) UIView* tabbarView;
@property (nonatomic, strong) UIButton* playButton;
@property (nonatomic, strong) UISlider* durationSlider;
@property (nonatomic, strong) UITextField* renameField;
@property (nonatomic, strong) UITextView* describleTextView;
@end

@implementation MAViewRecorderFile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeRecorderFile;
        self.viewTitle = MyLocal(@"view_title_recorder_file");
        
        currentIndex = 0;
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
    _playButton.frame = (CGRect){0, KShowFileViewHeight - _playButton.frame.size.height, _playButton.frame.size};
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
                                          font:[[MAModel shareModel] getLabelFontSize:KLabelFontArial size:KLabelFontSize14]
                                          text:MyLocal(@"custom_default")];
    _renameField.delegate = self;
    _renameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self addSubview:_renameField];
    
    //describle
    _describleTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 15 + CGRectGetMaxY(_renameField.frame), 300,240)];
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

#pragma mark - btn clicked
-(void)playBtnClicked:(id)sender{
    
}

-(void)tabbarItemClicked:(id)sender{
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == KTabbarItem1Tag) {
        NSMutableArray* tagArray = [[NSMutableArray alloc] init];
        MAVoiceFiles* file = [_resourceArray objectAtIndex:currentIndex];
        if (file.tag) {
            NSArray* tagArr = [MAUtils getArrayFromStrByCharactersInSet:file.tag character:@";"];
            for(int i = 0; i < [tagArr count]; i++){
                NSString* tag = [tagArr objectAtIndex:i];
                MATagObject* tagObject = [[MATagObject alloc] init];
                if ([tagObject initDataWithString:tag]) {
                    tagObject.tag = i;
                    tagObject.totalTime = [file.duration floatValue];
                    if (tagObject.endTime > tagObject.totalTime) {
                        tagObject.endTime = tagObject.totalTime;
                    }
                    tagObject.name = file.name;
                    [tagArray addObject:tagObject];
                }
            }
        }

        MAViewBase* view = [SysDelegate.viewController getView:MaviewTypeTagManager];
        [self pushView:view animatedType:MATypeChangeViewCurlDown];
        [(MAViewTagManager*)view initTagObject:tagArray];
    } else if (btn.tag == KTabbarItem2Tag) {
    } else if (btn.tag == KTabbarItem3Tag) {
    } else if (btn.tag == KTabbarItem4Tag) {
    }
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
    
    MAVoiceFiles* file = [_resourceArray objectAtIndex:currentIndex];
    _renameField.text = file.name;
}
@end
