//
//  MACellFile.h
//  VoiceControl
//
//  Created by apple on 14-3-17.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MACellFile;
@class MAVoiceFiles;

@protocol MACellFileDelegate <NSObject>
-(void)MACellFileBack:(MACellFile*)cell btn:(UIButton*)btn;
@end

@interface MACellFile : UITableViewCell

-(void)setCellResource:(MAVoiceFiles*)file editing:(BOOL)editing;
-(void)setCellEditing:(BOOL)editing;

@property (nonatomic, assign) id<MACellFileDelegate> delegate;

@end
