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

#define KCellLabelNameTag       (1001)
#define KCellLabelTimeTag       (1002)
#define KCellLabelDurationTag   (1003)
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
                     frame:CGRectMake(KCellOffset + CGRectGetMaxX(_playBtn.frame), 0, self.frame.size.width, self.frame.size.height * 0.68)];
        
        [self setCellLabel:object.tagName tag:KCellLabelTimeTag alignment:KTextAlignmentLeft
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
                     frame:CGRectMake(KCellOffset + CGRectGetMaxX(_playBtn.frame), self.frame.size.height * 0.7, self.frame.size.width, self.frame.size.height * 0.3)];
        
        [self setCellLabel:object.tagName tag:KCellLabelDurationTag alignment:KTextAlignmentRight
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
                     frame:CGRectMake(self.frame.size.width - 120, self.frame.size.height * 0.7, 110, self.frame.size.height * 0.3)];
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
@end
