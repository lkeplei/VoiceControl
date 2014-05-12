//
//  MAViewRecorderMoreFile.h
//  VoiceControl
//
//  Created by apple on 14-5-12.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RecorderMoreFileBlock)(int);

@interface MAViewRecorderMoreFile : UIView<UITableViewDataSource, UITableViewDelegate>

-(void)showView;
-(void)hideView;
-(void)setResource:(NSString*)title array:(NSArray*)array;

@property(nonatomic, copy) RecorderMoreFileBlock recorderMoreFileBlock;

@end
