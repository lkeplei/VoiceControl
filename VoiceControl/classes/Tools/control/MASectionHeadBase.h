//
//  MASectionHeadBase.h
//  VoiceControl
//
//  Created by 刘坤 on 13-8-25.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KTableBaseHeaderHeight          (40)

@class MASectionHeadBase;

@protocol MASectionHeadDelegate <NSObject>

@required
-(void)headSelected:(MASectionHeadBase*)head;

@end


@interface MASectionHeadBase : UIView

@property (assign) BOOL isExpanded;
@property (assign) BOOL enabled;
@property (nonatomic, strong) id<MASectionHeadDelegate> delegate;

-(void)setHeadResource:(NSDictionary*)resDic;

@end
