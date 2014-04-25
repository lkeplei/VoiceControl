//
//  MAViewFileManager.h
//  VoiceControl
//
//  Created by 刘坤 on 13-8-2.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewBase.h"

#import "MACellFile.h"

//#import "MAViewAudioPlayControl.h"

@interface MAViewFileManager : MAViewBase<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MACellFileDelegate>

@end
