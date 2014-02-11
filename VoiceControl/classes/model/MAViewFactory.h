//
//  MAViewFactory.h
//  VoiceControl
//
//  Created by apple on 14-2-8.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAViewBase.h"

@interface MAViewFactory : NSObject

-(MAViewBase*)getView:(MAViewType)type frame:(CGRect)frame;
-(void)removeView:(MAViewType)type;

@end