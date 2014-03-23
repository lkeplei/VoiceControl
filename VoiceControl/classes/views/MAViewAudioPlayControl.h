//
//  MAViewAudioPlayControl.h
//  VoiceControl
//
//  Created by ken on 13-7-26.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class MAVoiceFiles;

typedef enum {
    MAAudioPlayNext = 0,
    MAAudioPlayPre,
    MAAudioPlayHide,
    MAAudioPlayShow
} MAAudioPlayType;

#define KAudioPlayViewHeight        (100)

@protocol MAAudioPlayDelegate <NSObject>
-(BOOL)MAAudioPlayBack:(MAAudioPlayType)type;
@end

@interface MAViewAudioPlayControl : UIView<AVAudioPlayerDelegate>

-(void)playWithPath:(MAVoiceFiles*)resDic array:(NSArray*)array;

@property (nonatomic, assign) id<MAAudioPlayDelegate> audioPlayDelegate;

@end
