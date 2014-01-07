//
//  MAViewBase.m
//  VoiceControl
//
//  Created by 刘坤 on 13-8-6.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewBase.h"

@implementation MAViewBase

@synthesize viewTitle = _viewTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _viewType = MAViewTypeBase;
    }
    return self;
}

#pragma mark - other
-(void)showView{
}
@end
