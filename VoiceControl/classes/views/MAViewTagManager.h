//
//  MAViewTagManager.h
//  VoiceControl
//
//  Created by apple on 14-4-25.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MAViewBase.h"

@interface MAViewTagManager : MAViewBase<UITableViewDataSource, UITableViewDelegate>

-(void)initTagObject:(NSArray*)tagArray;

@end
