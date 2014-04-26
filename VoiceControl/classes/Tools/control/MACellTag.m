//
//  MACellTag.m
//  VoiceControl
//
//  Created by 刘坤 on 14-4-26.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import "MACellTag.h"

@implementation MACellTag

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
