//
//  MAViewAboutWeRecorder.m
//  VoiceControl
//
//  Created by 刘坤 on 14-3-23.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewAboutWeRecorder.h"
#import "MAConfig.h"
#import "MAModel.h"

#define KAboutOffset        (6)
@implementation MAViewAboutWeRecorder

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeAboutWeRcorder;
        self.viewTitle = MyLocal(@"view_title_about_werecorder");
    }
    return self;
}

-(void)showView{
    UITextView* textview=[[UITextView alloc]initWithFrame:CGRectMake(KAboutOffset, KAboutOffset,
                                                                     self.frame.size.width - KAboutOffset * 2,
                                                                     self.frame.size.height - KAboutOffset * 3)];
    textview.font = [[MAModel shareModel] getLaberFontSize:KLabelFontArial size:KLabelFontSize16];
    textview.backgroundColor = [[MAModel shareModel] getColorByType:MATypeColorDefault default:NO];
    textview.text = MyLocal(@"about_us_content");
    textview.editable = NO;
    [self addSubview:textview];
}

@end
