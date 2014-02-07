//
//  MACellPlan.m
//  VoiceControl
//
//  Created by apple on 14-2-7.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MACellPlan.h"
#import "MAUtils.h"
#import "MAConfig.h"
#import "MAModel.h"

#define KTimeLabelTag       (1000)
#define KTitleLableTag      (1001)
#define KPlanLabelTag       (1002)
#define KSwitchTag          (1003)

#define KSwitchWidth        (60)
#define KSwitchHeight       (16)

@implementation MACellPlan

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

}

-(void)setCellResource:(NSDictionary*)resDic{
    int offset = 10;
    float heightRate = 0.75;
    //time
    UILabel* label = (UILabel*)[self.contentView viewWithTag:KTimeLabelTag];
    if (label) {
        label.text = [resDic objectForKey:KTime];
    } else {
        label = [MAUtils labelWithTxt:[resDic objectForKey:KTime]
                                frame:CGRectMake(offset, 0,
                                                 self.frame.size.width,
                                                 self.frame.size.height * heightRate)
                                 font:[UIFont fontWithName:KLabelFontArial
                                                      size:KLabelFontSize30]
                                color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        label.textAlignment = KTextAlignmentLeft;
        label.tag = KTimeLabelTag;
        [self.contentView addSubview:label];
    }
    
    //title
    UILabel* title = (UILabel*)[self.contentView viewWithTag:KTitleLableTag];
    if (title) {
        title.text = [resDic objectForKey:KTitle];
    } else {
        title = [MAUtils labelWithTxt:[resDic objectForKey:KTitle]
                                frame:CGRectMake(offset, label.frame.origin.y + label.frame.size.height,
                                                 self.frame.size.width,
                                                 self.frame.size.height - label.frame.size.height)
                                 font:[UIFont fontWithName:KLabelFontArial
                                                      size:KLabelFontSize12]
                                color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        title.textAlignment = KTextAlignmentLeft;
        title.tag = KTitleLableTag;
        [self.contentView addSubview:title];
    }
    
    //plan time
    UILabel* planTime = (UILabel*)[self.contentView viewWithTag:KPlanLabelTag];
    if (planTime) {
        planTime.text = [self getPlanTimeString:[resDic objectForKey:KPlanTime]];
    } else {
        planTime = [MAUtils labelWithTxt:[self getPlanTimeString:[resDic objectForKey:KPlanTime]]
                                   frame:CGRectMake(title.frame.origin.x + [MAUtils getFontSize:[resDic objectForKey:KTitle]
                                                                                           font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]].width,
                                                 title.frame.origin.y, self.frame.size.width, title.frame.size.height)
                                 font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize12]
                                color:[[MAModel shareModel] getColorByType:MATypeColorTableLabel default:NO]];
        planTime.textAlignment = KTextAlignmentLeft;
        planTime.tag = KPlanLabelTag;
        [self.contentView addSubview:planTime];
    }
    
    //on/off
    UISwitch* switcher = (UISwitch*)[self.contentView viewWithTag:KSwitchTag];
    if (switcher) {
        [switcher setOn:[[resDic objectForKey:KStatus] boolValue]];
    } else {
        switcher = [[UISwitch alloc] initWithFrame:CGRectMake((self.frame.size.width - KSwitchWidth) - offset / 2,
                                                              (self.frame.size.height - KSwitchHeight) / 2,
                                                              KSwitchWidth, KSwitchHeight)];
        switcher.tag = KSwitchTag;
        [switcher setOn:[[resDic objectForKey:KStatus] boolValue]];
        [switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:switcher];
    }
}

-(NSString*)getPlanTimeString:(NSString*)str{
    NSString* string = nil;
    
    NSArray* resArr = [MAUtils getArrayFromStrByCharactersInSet:str character:@","];
    if (resArr && [resArr count] > 0) {
        string = @", ";
        if ([resArr count] >= 7) {
            string = [string stringByAppendingString:MyLocal(@"plan_time_0")];
        } else {
            for (int i = 0; i < [resArr count]; i++) {
                NSString* res = (NSString*)[resArr objectAtIndex:i];
                if ([res compare:@"0"] == NSOrderedSame) {
                    string = @"";
                    break;
                } else if ([res compare:@"1"] == NSOrderedSame) {
                    string = [string stringByAppendingString:MyLocal(@"plan_time_1")];
                } else if ([res compare:@"2"] == NSOrderedSame) {
                    string = [string stringByAppendingString:MyLocal(@"plan_time_2")];
                } else if ([res compare:@"3"] == NSOrderedSame) {
                    string = [string stringByAppendingString:MyLocal(@"plan_time_3")];
                } else if ([res compare:@"4"] == NSOrderedSame) {
                    string = [string stringByAppendingString:MyLocal(@"plan_time_4")];
                } else if ([res compare:@"5"] == NSOrderedSame) {
                    string = [string stringByAppendingString:MyLocal(@"plan_time_5")];
                } else if ([res compare:@"6"] == NSOrderedSame) {
                    string = [string stringByAppendingString:MyLocal(@"plan_time_6")];
                } else if ([res compare:@"7"] == NSOrderedSame) {
                    string = [string stringByAppendingString:MyLocal(@"plan_time_7")];
                }
            }
        }
    }
    
    return string;
}

#pragma mark - switch
-(void)switchAction:(id)sender{
    DebugLog(@"kajsdlfjaskfdjaskjflasdfads");
}
@end
