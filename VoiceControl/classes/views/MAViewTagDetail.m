//
//  MAViewTagDetail.m
//  VoiceControl
//
//  Created by apple on 14-4-1.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewTagDetail.h"

@interface MAViewTagDetail ()

@property (assign) MATagObject* tagObject;

@end

@implementation MAViewTagDetail

-(id)initWithTagObject:(MATagObject*)object frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blueColor]];
        
        _tagObject = object;
    }
    return self;
}
@end
