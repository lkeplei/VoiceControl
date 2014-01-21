//
//  MAViewAddPlan.m
//  VoiceControl
//
//  Created by apple on 14-1-21.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAddPlan.h"
#import "MAModel.h"
#import "MAConfig.h"

@implementation MAViewAddPlan

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAddPlan;
        self.viewTitle = MyLocal(@"view_title_add_plan");

        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTopBtn:MyLocal(@"plan_add_top_left") rightBtn:MyLocal(@"plan_add_top_right")];
}

#pragma mark - other
-(void)eventTopBtnClicked:(BOOL)left{
    if (left) {
        
    } else {
        
    }
}
@end
