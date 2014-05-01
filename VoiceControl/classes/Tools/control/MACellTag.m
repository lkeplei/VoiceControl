//
//  MACellTag.m
//  VoiceControl
//
//  Created by 刘坤 on 14-4-26.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MACellTag.h"
#import "MAConfig.h"
#import "MAUtils.h"
#import "MAModel.h"
#import "MARecordController.h"
#import "MAVoiceFiles.h"

#define KCellLabelNameTag       (1001)
#define KCellLabelTimeTag       (1002)
#define KCellLabelDurationTag   (1003)
#define KCellRenameButtonTag    (1004)
#define KCellOffset             (5)

@interface MACellTag()
@property (nonatomic, strong) UIButton* playBtn;
@property (nonatomic, strong) MATagObject* tagObject;
@end

@implementation MACellTag

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

-(void)setCellResource:(MATagObject*)object index:(NSInteger)index{
    if (object) {
        _tagObject = object;
        
        if (_playBtn == nil) {
            _playBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                        image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                     imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                       target:self
                                       action:@selector(playBtnClicked:)];
            _playBtn.center = CGPointMake(self.center.y, self.center.y);
            [self addSubview:_playBtn];
        }
        
        [self setCellLabel:object.tagName tag:KCellLabelNameTag alignment:KTextAlignmentLeft
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize18]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
                     frame:CGRectMake(KCellOffset + CGRectGetMaxX(_playBtn.frame), 0, self.frame.size.width, self.frame.size.height * 0.65)];
        
        [self setCellLabel:[MAUtils getStringFromDate:object.startDate format:KTimeFormat] tag:KCellLabelTimeTag alignment:KTextAlignmentLeft
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
                     frame:CGRectMake(KCellOffset + CGRectGetMaxX(_playBtn.frame), self.frame.size.height * 0.7, self.frame.size.width, self.frame.size.height * 0.3)];
        
        [self setCellLabel:[[MAModel shareModel] getStringTime:object.endTime - object.startTime type:MATypeTimeClock]
                       tag:KCellLabelDurationTag alignment:KTextAlignmentRight
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
                     frame:CGRectMake(self.frame.size.width - 120, self.frame.size.height * 0.7, 110, self.frame.size.height * 0.3)];
        
        UIButton* button = (UIButton*)[self.contentView viewWithTag:KCellRenameButtonTag];
        if (button == nil) {
            button = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                        image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                     imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                       target:self
                                       action:@selector(tagRename:)];
            button.frame = (CGRect){self.frame.size.width - button.frame.size.width - KCellOffset, 0, button.frame.size};
            [self addSubview:button];
        }
    }
}

-(void)setCellLabel:(NSString*)content tag:(uint32_t)tag alignment:(NSTextAlignment)alignment font:(UIFont*)font color:(UIColor*)color frame:(CGRect)frame{
    UILabel* label = (UILabel*)[self.contentView viewWithTag:tag];
    if (label == nil) {
        frame.origin.y += fabsf((frame.size.height - [MAUtils getFontSize:content font:font].height)) / 2;
        label = [MAUtils labelWithTxt:content frame:frame font:font color:color];
        label.tag = tag;
        label.textAlignment = alignment;
        [self.contentView addSubview:label];
    } else {
        label.text = content;
    }
}

-(void)setPlayBtnStatus:(BOOL)play{
    if (_playBtn) {
        if (play) {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                forState:UIControlStateSelected];
        } else {
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateNormal];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateHighlighted];
            [_playBtn setBackgroundImage:[[MAModel shareModel] getImageByType:MATypeImgPlayPause default:NO]
                                forState:UIControlStateSelected];
        }
    }
}

#pragma mark - btn clicked
- (void)playBtnClicked:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MACellTagBack:object:)]) {
        [self.delegate MACellTagBack:self object:_tagObject];
    }
}

-(void)tagRename:(id)sender{
    UIAlertView* promptAlert = [[UIAlertView alloc] initWithTitle:MyLocal(@"file_input_new_name")
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:MyLocal(@"cancel")
                                                otherButtonTitles:MyLocal(@"ok"), nil];
    promptAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [promptAlert show];
}

#pragma mark - alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField* field = [alertView textFieldAtIndex:0];
        _tagObject.tagName = field.text;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(MACellTagBackSave:object:)]) {
            [self.delegate MACellTagBackSave:self object:_tagObject];
        }
    }
}

#pragma mark - other
-(void)setCellPlaying:(BOOL)playing{
    [self setPlayBtnStatus:!playing];
    
    if (playing) {
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorBtnRed default:NO]];
    } else {
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];
    }
}
@end
