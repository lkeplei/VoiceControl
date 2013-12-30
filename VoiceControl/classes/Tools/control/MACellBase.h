//
//  MACellBase.h
//  VoiceControl
//
//  Created by 刘坤 on 13-8-11.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MACellBase : UITableViewCell

-(void)setCellResource:(NSDictionary*)resDic offset:(float)offset;

@property (nonatomic, strong)UIColor* separatorLineColor;
@property (nonatomic, strong)UIColor* normalBackgroundColor;
@property (nonatomic, strong)UIImage* normalBackgroundImage;
@property (nonatomic, strong)UIColor* selectBackgroundColor;
@property (nonatomic, strong)UIImage* selectBackgroundImage;

@end
