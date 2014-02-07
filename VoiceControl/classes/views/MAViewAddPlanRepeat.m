//
//  MAViewAddPlanRepeat.m
//  VoiceControl
//
//  Created by apple on 14-2-7.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAddPlanRepeat.h"
#import "MAConfig.h"
#import "MAModel.h"

@implementation MAViewAddPlanRepeat

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAddPlanRepeat;
        self.viewTitle = MyLocal(@"view_title_add_plan_repeat");
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_back") rightBtn:nil];
}

#pragma mark -others
-(void)eventTopBtnClicked:(BOOL)left{
    if (left) {
        [SysDelegate.viewController changeToViewByType:MAViewTypeAddPlan];
    } else {
    }
}
@end
