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

#define KCellLabelNameTag       (1001)
#define KCellImgTag             (1002)
#define KCellImgSecTag          (1003)
#define KCellButtonTag          (1004)

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

-(void)setCellResource:(NSDictionary*)resDic editing:(BOOL)editing{
    if (resDic) {
        UILabel* name = (UILabel*)[self.contentView viewWithTag:KCellLabelNameTag];
        NSString* str = [@"" stringByAppendingFormat:@"%@ - (%@)", [resDic objectForKey:KDataBaseFileName],
                         [[MAModel shareModel] getStringTime:[[resDic objectForKey:KDataBaseDuration] intValue] type:MATypeTimeCh]];
        if (name == nil) {
            name = [MAUtils labelWithTxt:str
                                   frame:CGRectMake(5, 0, self.frame.size.width, self.frame.size.height)
                                    font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize14]
                                   color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
            name.tag = KCellLabelNameTag;
            name.textAlignment = KTextAlignmentLeft;
            [self.contentView addSubview:name];
        } else {
            name.text = str;
        }
        
        if (editing) {
            UIImageView* img = (UIImageView*)[self viewWithTag:KCellImgTag];
            if (img) {
                [img removeFromSuperview];
            }
            img = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgCheckBoxNormal default:NO]];
            img.tag = KCellImgTag;
            [img setHidden:[[resDic objectForKey:KStatus] boolValue]];
            img.center = CGPointMake(self.frame.size.width - img.frame.size.width, self.center.y);
            [self.contentView addSubview:img];
            
            UIImageView* imgSec = (UIImageView*)[self viewWithTag:KCellImgSecTag];
            if (imgSec) {
                [imgSec removeFromSuperview];
            }
            imgSec = [[UIImageView alloc] initWithImage:[[MAModel shareModel] getImageByType:MATypeImgCheckBoxSec default:NO]];
            imgSec.tag = KCellImgSecTag;
            [imgSec setHidden:![[resDic objectForKey:KStatus] boolValue]];
            imgSec.center = CGPointMake(self.frame.size.width - imgSec.frame.size.width, self.center.y);
            [self.contentView addSubview:imgSec];
        } else {
            UIButton* button = (UIButton*)[self.contentView viewWithTag:KCellButtonTag];
            if (button) {
                [button removeFromSuperview];
            }
            button = [MAUtils buttonWithImg:nil off:0 zoomIn:YES
                                      image:[[MAModel shareModel] getImageByType:MATypeImgHomeMenu default:NO]
                                   imagesec:[[MAModel shareModel] getImageByType:MATypeImgHomeMenu default:NO]
                                     target:self
                                     action:@selector(menuBtnClicked:)];
            button.tag = KCellButtonTag;
            button.frame = CGRectMake(self.frame.size.width - self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
            [self.contentView addSubview:button];
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

#pragma mark - btn clicked
-(void)menuBtnClicked:(id)sender{
    if (_delegate) {
        [_delegate MACellFileBack:self btn:sender];
    }
}
@end
