//
//  MACellTag.h
//  VoiceControl
//
//  Created by 刘坤 on 14-4-26.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MATagObject;
@class MACellTag;

@protocol MACellTagDelegate <NSObject>
-(void)MACellTagBack:(MACellTag*)cell object:(MATagObject*)tagObject;
-(void)MACellTagBackSave:(MACellTag *)cell object:(MATagObject *)tagObject;
@end

@interface MACellTag : UITableViewCell

-(void)setCellResource:(MATagObject*)object index:(NSInteger)index;
-(void)setPlayBtnStatus:(BOOL)play;

@property (nonatomic, assign) id<MACellTagDelegate> delegate;

@end
