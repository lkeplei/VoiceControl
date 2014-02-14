//
//  MAViewAddPlanDuration.h
//  VoiceControl
//
//  Created by apple on 14-2-14.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewBase.h"
#import "MAModel.h"

typedef void (^AddPlanDurationCallBack)(NSDictionary* resDic, MAViewType type);

@interface MAViewAddPlanDuration : MAViewBase<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, copy)AddPlanDurationCallBack durationCallBack;

@end
