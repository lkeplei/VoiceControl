//
//  MASkinData.h
//  VoiceControl
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAModel.h"

@interface MASkinData : NSObject

-(void)setSkinDic;
-(UIColor*)getColorByType:(MAType)type default:(BOOL)defult;
-(UIImage*)getImageByType:(MAType)type default:(BOOL)defult;

@end
