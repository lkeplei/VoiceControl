//
//  MAViewAudioPlayControl.h
//  VoiceControl
//
//  Created by ken on 13-7-26.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    MaAudioPlayNext = 0,
    MaAudioPlayPre,
    MaAudioPlayHide,
    MaAudioPlayShow
} MAAudioPlayType;

#define KAudioPlayViewHeight        (100)

typedef BOOL (^audioPlayCallBack)(MAAudioPlayType type);

@interface MAViewAudioPlayControl : UIView<AVAudioPlayerDelegate>

-(void)playWithPath:(NSDictionary*)resDic array:(NSArray*)array;

@property(nonatomic, copy)audioPlayCallBack audioPlayCallBack;

@end
