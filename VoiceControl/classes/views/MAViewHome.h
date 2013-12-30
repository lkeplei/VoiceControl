//
//  MAViewHome.h
//  VoiceControl
//
//  Created by ken on 13-8-2.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewBase.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface MAViewHome : MAViewBase<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@end
