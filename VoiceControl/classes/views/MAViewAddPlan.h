//
//  MAViewAddPlan.h
//  VoiceControl
//
//  Created by apple on 14-1-21.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewBase.h"

@interface MAViewAddPlan : MAViewBase<UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, MAViewBaseDelegate>

-(void)setResource:(NSDictionary*)resDic;

@end
