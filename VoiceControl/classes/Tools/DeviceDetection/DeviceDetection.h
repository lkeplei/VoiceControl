//
//  DeviceDetection.h
//  VoiceControl
//
//  Created by apple on 14-1-16.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

enum {
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
    MODEL_IPHONE,
    MODEL_IPHONE_3G,
    MODEL_IPAD
};


@interface DeviceDetection : NSObject

+ (uint) detectDevice;
+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;
+ (BOOL) isIPodTouch;
+ (BOOL) isOS4;
+ (BOOL) canSendSms;

@end
