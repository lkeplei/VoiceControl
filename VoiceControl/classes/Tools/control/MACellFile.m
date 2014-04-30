//
//  MACellFile.m
//  VoiceControl
//
//  Created by apple on 14-3-17.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MACellFile.h"
#import "MAModel.h"
#import "MAUtils.h"
#import "MAConfig.h"

#import "MAVoiceFiles.h"

#define KCellOffset             (5)
#define KCellLabelNameTag       (1001)
#define KCellImgTag             (1002)
#define KCellImgSecTag          (1003)
#define KCellButtonTag          (1004)
#define KCellLabelTimeTag       (1005)
#define KCellLabelDurationTag   (1006)

@implementation MACellFile

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setCellResource:(MAVoiceFiles*)file editing:(BOOL)editing{
    if (file) {
        float offsetY = self.frame.size.height * 0.75;
        NSArray* contentArr = [MAUtils getArrayFromStrByCharactersInSet:file.custom character:KCharactersInSetCustom];
        NSString* name = MyLocal(@"custom_default");
        if ([contentArr count] >= 1 && [(NSString*)[contentArr objectAtIndex:0] length] > 0) {
            name = [contentArr objectAtIndex:0];
        }
        [self setCellLabel:name tag:KCellLabelNameTag alignment:KTextAlignmentLeft
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize18]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]
                     frame:CGRectMake(KCellOffset, 0, self.frame.size.width, self.frame.size.height * 0.68)];
        
        [self setCellLabel:[MAUtils getStringFromDate:file.time format:KTimeFormat] tag:KCellLabelTimeTag alignment:KTextAlignmentLeft
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]
                     frame:CGRectMake(KCellOffset, offsetY, self.frame.size.width, self.frame.size.height / 2)];
        
        [self setCellLabel:[[MAModel shareModel] getStringTime:[file.duration intValue] type:MATypeTimeClock]
                       tag:KCellLabelDurationTag alignment:KTextAlignmentRight
                      font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                     color:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]
                     frame:CGRectMake(KCellOffset, offsetY, self.frame.size.width - KCellOffset * 2, self.frame.size.height / 2)];
        if (editing) {
            [self setCellImage:[[MAModel shareModel] getImageByType:MATypeImgCheckBoxNormal default:NO]
                           tag:KCellImgTag hide:file.status];
            
            [self setCellImage:[[MAModel shareModel] getImageByType:MATypeImgCheckBoxSec default:NO]
                           tag:KCellImgSecTag hide:!file.status];
        } else {
            [self setCellImage:[[MAModel shareModel] getImageByType:MATypeImgCellIndicator default:NO]
                           tag:KCellButtonTag hide:NO];
        }
    }
}

-(void)setCellEditing:(BOOL)editing{
    UIImageView* img = (UIImageView*)[self viewWithTag:KCellImgTag];
    UIImageView* imgSec = (UIImageView*)[self viewWithTag:KCellImgSecTag];
    if (img && imgSec) {
        [img setHidden:!editing];
        [imgSec setHidden:editing];
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

-(void)setCellImage:(UIImage*)img tag:(uint32_t)tag hide:(BOOL)hide{
    UIImageView* imgView = (UIImageView*)[self viewWithTag:tag];
    if (imgView) {
        [imgView removeFromSuperview];
    }
    imgView = [[UIImageView alloc] initWithImage:img];
    imgView.tag = tag;
    [imgView setHidden:hide];
    imgView.center = CGPointMake(self.frame.size.width - imgView.frame.size.width,
                                 (self.frame.size.height - imgView.frame.size.height) / 2 + KCellOffset * 2);
    [self.contentView addSubview:imgView];
}
@end
