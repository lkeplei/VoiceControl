//
//  MAViewAudioPlayControl.h
//  VoiceControl
//
//  Created by ken on 13-7-26.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define KAudioPlayViewHeight        (70)

@interface MAViewAudioPlayControl : UIView<AVAudioPlayerDelegate>

-(void)playWithPath:(NSString*)path array:(NSArray*)array;

@end
