//
//  MAUtils.h
//  VoiceControl
//
//  Created by ken on 13-4-16.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <string.h>
#import "MBProgressHUD.h"

@interface MAUtils : NSObject<UIAlertViewDelegate>

-(void)showWeakRemind:(NSString *)message time:(NSTimeInterval)time;

-(MBProgressHUD*)showProgressHUD:(UIView*)view text:(NSString*)text;
-(void)hideProgressHUD:(UIView*)view;

+(MAUtils*)shareUtils;

//获取设备的mac地址
+(NSString *)getMacAddress;

+(UIButton*)buttonWithImg:(NSString*)buttonText off:(int)off zoomIn:(BOOL)zoomIn image:(UIImage*)image
                 imagesec:(UIImage*)imagesec target:(id)target action:(SEL)action;

+(UILabel*)labelWithTxt:(NSString *)buttonText frame:(CGRect)frame
                   font:(UIFont*)font color:(UIColor*)color;

+(UITextField*)textFieldInit:(CGRect)frame color:(UIColor*)color bgcolor:(UIColor*)bgcolor
                        secu:(BOOL)secu font:(UIFont*)font text:(NSString*)text;

+(UINavigationBar*)navigationWithImg:(UIImage*)image;

+(const CGFloat*)getRGBAFromColor:(UIColor*)color;

+(void)showRemindMessage:(NSString*)message;

+(NSNumber*)getNumberByBool:(BOOL)value;
+(NSNumber*)getNumberByInt:(int)value;

+(NSString*)getStringByStdString:(const char*)string;
+(NSString*)getStringByInt:(int)number;
+(NSString*)getStringByFloat:(float)number decimal:(int)decimal;

+(void)openUrl:(NSString*)url;

+(NSString*)getAppVersion;
+(NSString*)getAppName;

+(void)callPhoneNumber:(NSString*)number view:(UIView*)view;

+(CGSize)getFontSize:(NSString*)text font:(UIFont*)font;
+(NSArray*)getArrayFromStrByCharactersInSet:(NSString*)strResource character:(NSString*)character;

+(NSString*)getTimeString:(double)time format:(NSString*)format second:(BOOL)second;
+(NSDate*)getDateFromString:(NSString*)time format:(NSString*)format;
+(NSString*)getStringFromDate:(NSDate*)date format:(NSString*)format;
+(NSDateComponents*)getComponentsFromDate:(NSDate*)date;
+(NSDateComponents*)getSubFromTwoDate:(NSDate*)from to:(NSDate*)to;

+(NSString*)getFilePathInDocument:(NSString*)fileName;

//打电话发邮件
+ (void) makeCall:(NSString *)phoneNumber msg:(NSString *)msg;
+ (void) sendSms:(NSString *)phoneNumber msg:(NSString *)msg;
+ (void) sendEmail:(NSString *)phoneNumber;
+ (void) sendEmail:(NSString *)to cc:(NSString*)cc subject:(NSString*)subject body:(NSString*)body;

//file
+(unsigned long long)getFileSize:(NSString*)filePath;
+(unsigned long long)getFolderSize:(NSString*)folderPath;
+(void)deleteFileWithPath:(NSString*)path;

//zip
+(BOOL)zipFiles:(NSString*)zipPath resourceArr:(NSArray*)resourceArr;
+(BOOL)unzipFiles:(NSString*)zipPath unZipFielPath:(NSString*)path;

//voice
+(float)getCurrentVoice;
+(void)setVoice:(float)value;
@end
