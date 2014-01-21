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
@synthesize subEvent = _subEvent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _viewType = MAViewTypeBase;
    }
    return self;
}

#pragma mark - view appear methods
-(void)viewDidAppear:(BOOL)animated{
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
}

#pragma mark - other
-(void)setTopBtn:(NSString*)leftBtn rightBtn:(NSString*)rightBtn{
    [self setSubEvent:YES];
    [SysDelegate.viewController setTopBtn:leftBtn rightBtn:rightBtn];
}

-(void)showView{
}

-(void)eventTopBtnClicked:(BOOL)left{
    
}
@end
