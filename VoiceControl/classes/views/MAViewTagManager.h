//
//  MAViewTagManager.h
//  VoiceControl
//
//  Created by apple on 14-4-25.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewBase.h"
#import <AVFoundation/AVFoundation.h>

@class MAVoiceFiles;

@interface MAViewTagManager : MAViewBase<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

-(void)initTagObject:(MAVoiceFiles*)file;

@end
