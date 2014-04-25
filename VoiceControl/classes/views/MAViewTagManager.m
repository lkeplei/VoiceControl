//
//  MAViewTagManager.m
//  VoiceControl
//
//  Created by apple on 14-4-25.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewTagManager.h"
#import "MAConfig.h"

@implementation MAViewTagManager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MaviewTypeTagManager;
        self.viewTitle = MyLocal(@"view_title_tag_manager");
    }
    return self;
}

@end
