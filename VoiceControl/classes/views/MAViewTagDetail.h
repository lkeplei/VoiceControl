//
//  MAViewTagDetail.h
//  VoiceControl
//
//  Created by apple on 14-4-1.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MATagObject;

typedef void (^TagDetailBlock)(MATagObject*);

typedef enum {
    MATagDetailStartX = 0,
    MATagDetailEndX,
    MATagDetailTimeX,
} MATagDetailType;

@interface MAViewTagDetail : UIView<UITextFieldDelegate>

-(id)initWithTagObject:(MATagObject*)object;

-(void)show;

@property(nonatomic, copy) TagDetailBlock tagDetailBlock;

@end
