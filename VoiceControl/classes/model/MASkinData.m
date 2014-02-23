//
//  MASkinData.m
//  VoiceControl
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MASkinData.h"
#import "MAConfig.h"
#import "MADataManager.h"

@interface MASkinData ()
@property (nonatomic, strong) NSDictionary* skinSetDic;
@end

@implementation MASkinData

-(id)init{
    self = [super init];
    if (self) {
        [self setSkinDic];
    }
    return self;
}

-(UIColor*)getColorByType:(MAType)type default:(BOOL)defult{
    int bgType = -1;
    if (defult || [MADataManager getDataByKey:KUserDefaultSetSkin] == nil) {
        bgType = MATypeSkinDefault;
    } else {
        bgType = [[MADataManager getDataByKey:KUserDefaultSetSkin] intValue];
    }
    
    NSDictionary* skinDic = [self getSkinDicByType:bgType];
    NSString* colorStr = (NSString*)[[[skinDic objectForKey:KSkinSetDicColor] objectForKey:[self getKeyFromType:type]] objectForKey:@"color"];

    if (colorStr) {
        NSArray* rgbArr = [colorStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        if (rgbArr && [rgbArr count] >= 4) {
            return RGBACOLOR([[rgbArr objectAtIndex:0] intValue], [[rgbArr objectAtIndex:1] intValue],
                             [[rgbArr objectAtIndex:2] intValue], [[rgbArr objectAtIndex:3] intValue]);
        } else if ([rgbArr count] == 1){
            return [UIColor clearColor];
        }
    } else {
        return nil;
    }
    return nil;
}

-(UIImage*)getImageByType:(MAType)type default:(BOOL)defult{
    int bgType = -1;
    if (defult || [MADataManager getDataByKey:KUserDefaultSetSkin] == nil) {
        bgType = MATypeSkinDefault;
    } else {
        bgType = [[MADataManager getDataByKey:KUserDefaultSetSkin] intValue];
    }
    
    NSDictionary* skinDic = [self getSkinDicByType:bgType];
    NSString* image = (NSString*)[[[skinDic objectForKey:KSkinSetDicImage] objectForKey:[self getKeyFromType:type]] objectForKey:@"image"];
    
    if (image) {
        return [UIImage imageNamed:image];
    } else {
        return nil;
    }
    return nil;
}

-(void)setSkinDic{
    if (_skinSetDic) {
        _skinSetDic = nil;
    }
    _skinSetDic = LOADDIC(@"skin_set", @"plist");
}

-(NSDictionary*)getSkinDicByType:(int)type{
    if (type == MATypeSkinDefault) {
        return [_skinSetDic objectForKey:KSkinSetDefault];
    } else {
        return [_skinSetDic objectForKey:KSkinSetDefault];
    }
}
-(NSString*)getKeyFromType:(MAType)type{
    switch (type) {
        case MATypeColorDefWhite:
            return KSkinSetColorDefWhite;
            break;
        case MATypeColorDefBlack:
            return KSkinSetColorDefBlack;
            break;
        case MATypeColorDefGray:
            return KSkinSetColorDefGray;
            break;
        case MATypeColorDefBlue:
            return KSkinSetColorDefBlue;
            break;
        case MATypeColorHomeBg:
            return KSkinSetColorHomeBg;
            break;
        case MATypeColorTableLabel:
            return KSkinSetColorTableLabel;
            break;
        case MATypeColorDropBG:
            return KSkinSetColorDropBG;
            break;
        case MATypeColorDropCellBG:
            return KSkinSetColorDropCellBG;
            break;
        case MATypeColorBtnGreen:
            return KSkinSetColorBtnGreen;
            break;
        case MATypeColorBtnDarkGreen:
            return KSkinSetColorBtnDarkGreen;
            break;
        case MATypeColorBtnRed:
            return KSkinSetColorBtnRed;
            break;
        case MATypeColorBtnDarkRed:
            return KSkinSetColorBtnDarkRed;
            break;
        case MATypeColorBtnGray:
            return KSkinSetColorBtnGray;
            break;
            
        case MATypeImgHomePhone:
            return KSkinSetImgHomePhone;
            break;
        case MATypeImgHomeMenu:
            return KSkinSetImgHomeMenu;
            break;
        case MATypeImgPlayPlay:
            return KSkinSetImgPlayPlay;
            break;
        case MATypeImgPlayNext:
            return KSkinSetImgPlayNext;
            break;
        case MATypeImgPlayPause:
            return KSkinSetImgPlayPause;
            break;
        case MATypeImgPlayPre:
            return KSkinSetImgPlayPre;
            break;
        case MATypeImgBtnGreenCircleSec:
            return KSkinSetImgBtnGreenCircleSec;
            break;
        case MATypeImgBtnGreenCircle:
            return KSkinSetImgBtnGreenCircle;
            break;
        case MATypeImgBtnRedCircleSec:
            return KSkinSetImgBtnRedCircleSec;
            break;
        case MATypeImgBtnRedCircle:
            return KSkinSetImgBtnRedCircle;
            break;
        case MATypeImgBtnGrayCircle:
            return KSkinSetImgBtnGrayCircle;
            break;
        case MATypeImgAddPlanReSec:
            return KSkinSetImgAddPlanReSec;
            break;
        case MATypeImgCellIndicator:
            return KSkinSetImgCellIndicator;
            break;
        default:
            return nil;
            break;
    }
}
@end
