//
//  MAViewRecorderFile.h
//  VoiceControl
//
//  Created by apple on 14-4-25.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewBase.h"
#import <AVFoundation/AVFoundation.h>

@interface MAViewRecorderFile : MAViewBase<UITextFieldDelegate, UITextViewDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate>

-(void)initResource:(uint16_t)index array:(NSArray*)array;

@end
