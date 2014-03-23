//
//  MAUtils.m
//  VoiceControl
//
//  Created by ken on 13-4-16.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAUtils.h"
#import "MAConfig.h"
#import "ZipArchive.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#define KShowWeakBtnHeight          (40)
#define KShowWeakRemind             (1000)

@implementation MAUtils

static MAUtils* _shareUtils = nil;

+(MAUtils*)shareUtils{
	if (!_shareUtils) {
        _shareUtils = [[self alloc]init];
	}
    
	return _shareUtils;
};

-(void)showWeakRemind:(NSString *)message time:(NSTimeInterval)time{
    UIAlertView* promptAlert = [[UIAlertView alloc] initWithTitle:MyLocal(@"prompting")
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:nil];
    promptAlert.tag = KShowWeakRemind;
    if (time <= 0) {
        time = 2.5;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:time
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:NO];
    
    [promptAlert show];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (alertView.tag != KShowWeakRemind) {
        return;
    }
    for(UIView *subview in alertView.subviews)
    {
        if ([[subview class] isSubclassOfClass:[UIImageView class]]) {
            UIImageView *view = (UIImageView*)subview;
            view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - KShowWeakBtnHeight);
        }
    }
}

- (void)timerFireMethod:(id)sender
{
    UIAlertView *promptAlert = (UIAlertView*)[(NSTimer*)sender userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
}

-(MBProgressHUD*)showProgressHUD:(UIView*)view text:(NSString*)text{
    MBProgressHUD* hud = (MBProgressHUD*)[view viewWithTag:9999];
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        
        hud.tag = 9999;
        hud.labelText = text;
        [hud show:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:60
                                         target:self
                                       selector:@selector(netTimeMethod:)
                                       userInfo:view
                                        repeats:NO];
    }
    
    return hud;
}

- (void)netTimeMethod:(id)sender
{
    UIView* view = (UIView*)[(NSTimer*)sender userInfo];
    MBProgressHUD* hud = (MBProgressHUD*)[view viewWithTag:9999];
    if (hud) {
        [hud removeFromSuperview];
        hud = nil;
        
        [MAUtils showRemindMessage:MyLocal(@"net_wrong")];
    }
}

-(void)hideProgressHUD:(UIView*)view{
    MBProgressHUD* hud = (MBProgressHUD*)[view viewWithTag:9999];
    if (hud) {
        [hud removeFromSuperview];
        hud = nil;
    }
}

#pragma mark MAC
+(NSString *)getMacAddress{
	int                    mib[6];
	size_t                len;
	char                *buf;
	unsigned char        *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl    *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = (char*)malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

#pragma mark - static
+(UIButton*)buttonWithImg:(NSString*)buttonText off:(int)off zoomIn:(BOOL)zoomIn image:(UIImage*)image
                 imagesec:(UIImage*)imagesec target:(id)target action:(SEL)action{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    
    if (buttonText != nil) {
        NSString* text = [NSString stringWithFormat:@"%@", buttonText];
        if (off > 0) {
            for (int i = 0; i < off; i++) {
                text = [NSString stringWithFormat:@" %@", text];
            }
        }
        [button setTitle:text forState:UIControlStateNormal];
        
        if (image == nil && imagesec == nil) {
            float width = [self getFontSize:buttonText font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]].width;
            float height = [self getFontSize:buttonText font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]].height;
            
            button.frame = CGRectMake(0.0, 0.0, width, height);
        }
    }
    
    if (zoomIn) {
        [button setImage:image forState:UIControlStateNormal];
        if (imagesec != nil) {
            [button setImage:imagesec forState:UIControlStateHighlighted];
            [button setImage:imagesec forState:UIControlStateSelected];
        }
    } else {
        [button setBackgroundImage:image forState:UIControlStateNormal];
        if (imagesec != nil) {
            [button setBackgroundImage:imagesec forState:UIControlStateHighlighted];
            [button setBackgroundImage:imagesec forState:UIControlStateSelected];
        }
    }

    button.adjustsImageWhenHighlighted = NO;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(UILabel*)labelWithTxt:(NSString *)buttonText frame:(CGRect)frame
                   font:(UIFont*)font color:(UIColor*)color{
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = buttonText;
    label.font = font;
    label.textAlignment = KTextAlignmentCenter;   //first deprecated in IOS 6.0
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

+(UITextField*)textFieldInit:(CGRect)frame color:(UIColor*)color bgcolor:(UIColor*)bgcolor
                        secu:(BOOL)secu font:(UIFont*)font text:(NSString*)text{
    UITextField* textField = [[UITextField alloc] initWithFrame:frame];
    textField.textColor = color;
    textField.font = font;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.backgroundColor = bgcolor;
    textField.placeholder = text;
    [textField setSecureTextEntry:secu];
    textField.returnKeyType = UIReturnKeyDone;
    
    return textField;
}

+(UINavigationBar*)navigationWithImg:(UIImage*)image{
    UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320,
                                                                                KNavigationHeight)];
    
    //设置导般栏背景
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:navBar.frame];
    imageView.contentMode = UIViewContentModeLeft;
    imageView.image = image;
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [navBar insertSubview:imageView atIndex:0];
    } else {
        [navBar addSubview:imageView];
    }
    
    return navBar;
}

+(const CGFloat*)getRGBAFromColor:(UIColor *)color{
    CGColorRef colorRef = [color CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(colorRef);
    
    if (numComponents >= 4){
        return CGColorGetComponents(colorRef);
    } else {
        return NULL;
    }
}

+(void)showRemindMessage:(NSString *)message{
    [[[UIAlertView alloc] initWithTitle:MyLocal(@"more_user_management_title")
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:MyLocal(@"ok"), nil] show];
}

+(NSNumber*)getNumberByBool:(BOOL)value{
    return [NSNumber numberWithBool:value];
}

+(NSNumber*)getNumberByInt:(int)value{
    return [NSNumber numberWithInt:value];
}

+(NSString*)getStringByStdString:(const char*)string{
    if (string) {
        return [NSString stringWithCString:string encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

+(NSString*)getStringByInt:(int)number{
    return [NSString stringWithFormat:@"%d", number];
}

+(NSString*)getStringByFloat:(float)number decimal:(int)decimal{
    if (decimal == -1) {
        return [@"" stringByAppendingFormat:@"%f",number];
    }else {
        NSString *format=[@"%." stringByAppendingFormat:@"%df", decimal];
        return [@"" stringByAppendingFormat:format,number];
    }
}

+(void)openUrl:(NSString*)url{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+(NSString*)getAppVersion{
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
    return versionNum;
}

+(NSString*)getAppName{
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* appName =[infoDict objectForKey:@"CFBundleDisplayName"];
    return appName;
}

+(void)callPhoneNumber:(NSString *)number view:(UIView*)view{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    UIWebView* phoneCallWebView = nil;
    
    if ( !phoneCallWebView ) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];// 这个webView只是一个后台的容易 不需要add到页面上来  效果跟方法二一样 但是这个方法是合法的
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
    [view addSubview:phoneCallWebView];
}

+(NSString*)getTimeString:(double)time format:(NSString*)format second:(BOOL)second{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:format];
    
    NSDate* date = nil;
    if (second) {
        date = [NSDate dateWithTimeIntervalSince1970:time];
    } else {
        date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    }
    
    return [dateFormatter stringFromDate:date];
}

+(NSDate*)getDateFromString:(NSString*)time format:(NSString*)format{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter dateFromString:time];
}

+(NSString*)getStringFromDate:(NSDate*)date format:(NSString*)format{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

+(NSDateComponents*)getComponentsFromDate:(NSDate*)date{
    return [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit |
                                                    NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit
                                           fromDate:date];
}

+(NSDateComponents*)getSubFromTwoDate:(NSDate*)from to:(NSDate*)to{
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ;
    return [cal components:unitFlags fromDate:from toDate:to options:0];
}

+(NSString*)getFilePathInDocument:(NSString*)fileName{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
}

+(unsigned long long)getFileSize:(NSString*)filePath{
    unsigned long long fileSize = 0;
#if 1
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        fileSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
#else 
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        fileSize = st.st_size;
    }
#endif
    return fileSize;
}

+(unsigned long long)getFolderSize:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    unsigned long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self getFileSize:fileAbsolutePath];
    }
    return folderSize;
}

+(BOOL)deleteFileWithPath:(NSString*)path{
    if (path) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        return [fileManager removeItemAtPath:path error:nil];
    }
    
    return NO;
}

+(BOOL)fileExistsAtPath:(NSString*)path{
    if (path) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        return [fileManager fileExistsAtPath:path];
    }
    
    return NO;
}

+(BOOL)zipFiles:(NSString*)zipPath resourceArr:(NSArray*)resourceArr{
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:zipPath];
    
    for (NSDictionary* resDic in resourceArr) {
        NSString* name = [resDic objectForKey:KName];
        if (name == nil) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:KNameFormat];
            name = [NSString stringWithFormat:@"%@.aac", [formatter stringFromDate:[NSDate date]]];
        }
        
        [za addFileToZip:[resDic objectForKey:KPath] newname:name];
    }
    
    return [za CloseZipFile2];
}

+(BOOL)unzipFiles:(NSString*)zipPath unZipFielPath:(NSString*)path{
    BOOL res = NO;
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile: zipPath]) {
        if (path == nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            path = [paths objectAtIndex:0];
        }
        [za UnzipFileTo: path overWrite: YES];  
        res = [za UnzipCloseFile];
    }
    
    return res;
}

+(float)getCurrentVoice{
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"];
}

+(void)setVoice:(float)value{
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"PlayerVolume"];
}

+ (void)alert:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (NSString*) cleanPhoneNumber:(NSString*)phoneNumber
{
    NSString* number = [NSString stringWithString:phoneNumber];
    NSString* number1 = [[[number stringByReplacingOccurrencesOfString:@" " withString:@""]
                          //                        stringByReplacingOccurrencesOfString:@"-" withString:@""]
                          stringByReplacingOccurrencesOfString:@"(" withString:@""]
                         stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    return number1;
}

+ (void) makeCall:(NSString *)phoneNumber msg:(NSString *)msg
{
    NSString* numberAfterClear = [MAUtils cleanPhoneNumber:phoneNumber];
    
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", numberAfterClear]];
    NSLog(@"make call, URL=%@", phoneNumberURL);
    
    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}

+ (void) sendSms:(NSString *)phoneNumber msg:(NSString *)msg
{
    NSString* numberAfterClear = [MAUtils cleanPhoneNumber:phoneNumber];
    
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", numberAfterClear]];
    NSLog(@"send sms, URL=%@", phoneNumberURL);
    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}

+ (void) sendEmail:(NSString *)phoneNumber
{
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", phoneNumber]];
    NSLog(@"send sms, URL=%@", phoneNumberURL);
    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}

+ (void) sendEmail:(NSString *)to cc:(NSString*)cc subject:(NSString*)subject body:(NSString*)body
{
    //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=my email!";
    NSString* str = [NSString stringWithFormat:@"mailto:%@?cc=%@&subject=%@&body=%@",
                     to, cc, subject, body];
    
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}

+ (CGSize)getFontSize:(NSString*)text font:(UIFont*)font{
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil, NSForegroundColorAttributeName, nil];
    return [text sizeWithAttributes:attributes];
}

+ (NSArray*)getArrayFromStrByCharactersInSet:(NSString*)strResource character:(NSString*)character{
    return [strResource componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:character]];
}
@end
