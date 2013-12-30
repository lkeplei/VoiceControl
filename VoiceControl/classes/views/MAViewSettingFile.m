//
//  MAViewSettingFile.m
//  VoiceControl
//
//  Created by ken on 13-9-11.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewSettingFile.h"
#import "MAModel.h"

@implementation MAViewSettingFile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = MAViewTypeSettingFile;
        
        [self setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefGray default:NO]];
    }
    return self;
}
@end
