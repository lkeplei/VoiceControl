//
//  MAViewAboutWeRecorder.m
//  VoiceControl
//
//  Created by 刘坤 on 14-3-23.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAboutWeRecorder.h"
#import "MAConfig.h"

@implementation MAViewAboutWeRecorder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];

        self.viewType = MAViewTypeAboutWeRcorder;
        self.viewTitle = MyLocal(@"view_title_about_werecorder");
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
