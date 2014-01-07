//
//  MAViewController.m
//  VoiceControl
//
//  Created by 刘坤 on 13-7-9.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#import "MAViewController.h"
#import "MAUtils.h"
#import "MAConfig.h"
#import "MAModel.h"

#import "MAViewSelectMenu.h"
#import "MAViewHome.h"
#import "MAViewFileManager.h"
#import "MAViewAboutUs.h"
#import "MAViewSetting.h"
#import "MAViewSettingFile.h"

#define KTopViewHeight      (44)

@interface MAViewController (){
    float   preTransX;
    BOOL    isMenuOpening;
}

@property (nonatomic, strong) UIView* topView;
@property (nonatomic, strong) UIButton* menuBtn;
@property (nonatomic, strong) UIButton* homeBtn;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic) UIPanGestureRecognizer* panGestureRecongnize;
@property (nonatomic, strong) MAViewBase* currentShowView;
@property (nonatomic, strong) MAViewBase* preShowView;
@property (nonatomic, strong) MAViewSelectMenu* selectMenu;
@property (nonatomic, strong) MAViewHome* homeView;
@property (nonatomic, strong) MAViewFileManager* fileManagerView;
@property (nonatomic, strong) MAViewAboutUs* aboutUsView;
@property (nonatomic, strong) MAViewSetting* settingView;
@property (nonatomic, strong) MAViewSettingFile* settingFileView;

@end

@implementation MAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initView];
    [self setupGestures];
    
    isMenuOpening = NO;
}

#pragma mark - init area
-(void)initView{
    [self initTopView];

    _selectMenu = [[MAViewSelectMenu alloc] initWithFrame:CGRectMake(0, KTopViewHeight, KViewMenuWidth,
                                                                     self.view.frame.size.height - KTopViewHeight)];
    [self.view addSubview:_selectMenu];
    
    _currentShowView = [self getView:MAViewTypeHome];
    [_titleLabel setText:_currentShowView.viewTitle];
}

-(void)initTopView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KTopViewHeight)];
    [_topView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [self.view addSubview:_topView];
    
    _titleLabel = [MAUtils laeblWithTxt:nil
                                  frame:_topView.frame
                                   font:[UIFont fontWithName:KLabelFontArial size:KLabelFontSize18]
                                  color:[[MAModel shareModel] getColorByType:MATypeColorDefWhite default:NO]];
    [_topView addSubview:_titleLabel];
    
    _homeBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                 image:[[MAModel shareModel] getImageByType:MATypeImgHomeMenu default:NO]
                              imagesec:[[MAModel shareModel] getImageByType:MATypeImgHomeMenu default:NO]
                               target:self
                                action:@selector(homeBtnClicked:)];
    float off = (_topView.frame.size.height - _homeBtn.frame.size.height) / 2;
    _homeBtn.frame = CGRectMake(_topView.frame.size.width - _homeBtn.frame.size.width - off, off,
                                _homeBtn.frame.size.width, _homeBtn.frame.size.height);
    [_topView addSubview:_homeBtn];
    
    _menuBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                 image:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                              imagesec:[[MAModel shareModel] getImageByType:MATypeImgPlayPlay default:NO]
                                target:self
                                action:@selector(menuBtnClicked:)];
    _menuBtn.frame = CGRectMake(off, 0, KTopViewHeight, KTopViewHeight);
    [_topView addSubview:_menuBtn];
}

#pragma mark - btn clicked
-(void)menuBtnClicked:(id)sender{
    isMenuOpening = !isMenuOpening;
    if (isMenuOpening) {
        [self showMenu];
    } else {
        [self hideMenu];
    }
}

-(void)homeBtnClicked:(id)sender{
    [self changeToViewByType:MAViewTypeHome];
}
#pragma mark - about panel
-(void)hideMenu {
	[UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _currentShowView.frame = CGRectMake(0, _currentShowView.frame.origin.y, _currentShowView.frame.size.width,
                                            _currentShowView.frame.size.height);
        _menuBtn.transform = CGAffineTransformRotate(_menuBtn.transform, -M_PI_2);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
}

-(void)showMenu {
    [UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _currentShowView.frame = CGRectMake(KViewMenuWidth, _currentShowView.frame.origin.y,
                                            _currentShowView.frame.size.width, _currentShowView.frame.size.height);
        _menuBtn.transform = CGAffineTransformRotate(_menuBtn.transform, M_PI_2);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
}

#pragma mark Swipe Gesture Setup/Actions
-(void)setupGestures {
	_panGestureRecongnize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
	[_panGestureRecongnize setMinimumNumberOfTouches:1];
	[_panGestureRecongnize setMaximumNumberOfTouches:1];
    [self.view setUserInteractionEnabled:YES];
	[self.view addGestureRecognizer:_panGestureRecongnize];
}

-(void)movePanel:(id)sender {
//	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];

	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        preTransX = 0;
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        BOOL change = _selectMenu.center.x  ? YES : NO;
        
        if (change) {
            if ((translatedPoint.x > 0 && !isMenuOpening) || (translatedPoint.x < 0 && isMenuOpening)) {
                isMenuOpening = !isMenuOpening;
            }
            if (isMenuOpening) {
                [self showMenu];
            } else {
                [self hideMenu];
            }
        }
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if (_selectMenu) {
            float offx = translatedPoint.x - preTransX;
            float x = _currentShowView.frame.origin.x + offx;
            if (x >= 0 && x <= KViewMenuWidth) {
                _currentShowView.frame = CGRectOffset(_currentShowView.frame, offx, 0);
                preTransX = translatedPoint.x;
            }
        }
	}
}

#pragma mark - other methods
-(void)setGestureEnabled:(BOOL)enabled{
    [_panGestureRecongnize setEnabled:enabled];
}

-(void)changeToViewByType:(MAViewType)type{
    if (_preShowView) {
        [self removeView:_preShowView.viewType];
    }
    [self removeView:_currentShowView.viewType];

    MAViewType currentType = _currentShowView.viewType;
    _currentShowView = [self getView:type];
    _preShowView = [self getView:currentType];
    [[MAModel shareModel] changeView:_preShowView
                                  to:_currentShowView
                                type:MATypeChangeViewFlipFromLeft
                            delegate:self
                            selector:@selector(animationFinished:)];
    
    [_currentShowView showView];
    
    [_titleLabel setText:_currentShowView.viewTitle];
    //添加百度页面统计
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobPageStart eventName:_currentShowView.viewTitle label:nil];
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobPageEnd eventName:_preShowView.viewTitle label:nil];
    
    //hide menu
    if (isMenuOpening) {
        [self menuBtnClicked:nil];   
    }
}

-(void)animationFinished:(id)sender{
    if (_preShowView && _preShowView.viewType != _currentShowView.viewType) {
        [self removeView:_preShowView.viewType];
    }
}

#pragma mark - about view manager
-(MAViewBase*)getView:(MAViewType)type{
    MAViewBase* view = nil;
    switch (type) {
        case MAViewTypeHome:
        {
            if (_homeView == nil) {
                _homeView = [[MAViewHome alloc] initWithFrame:CGRectMake(0, KTopViewHeight, self.view.frame.size.width,
                                                                         self.view.frame.size.height - KTopViewHeight)];
                [self.view addSubview:_homeView];
            }
            view = _homeView;
        }
            break;

        case MAViewTypeFileManager:
        {
            if (_fileManagerView == nil) {
                _fileManagerView = [[MAViewFileManager alloc] initWithFrame:CGRectMake(0, KTopViewHeight,
                                                                                       self.view.frame.size.width,
                                                                                       self.view.frame.size.height - KTopViewHeight)];
                [self.view addSubview:_fileManagerView];
            }
            view = _fileManagerView;
        }
            break;
        case MAViewTypeSetting:
        {
            if (_settingView == nil) {
                _settingView = [[MAViewSetting alloc] initWithFrame:CGRectMake(0, KTopViewHeight,
                                                                               self.view.frame.size.width,
                                                                               self.view.frame.size.height - KTopViewHeight)];
                [self.view addSubview:_settingView];
            }
            view = _settingView;
        }
            break;
        case MAViewTypeSettingFile:
        {
            if (_settingFileView == nil) {
                _settingFileView = [[MAViewSettingFile alloc] initWithFrame:CGRectMake(0, KTopViewHeight,
                                                                               self.view.frame.size.width,
                                                                               self.view.frame.size.height - KTopViewHeight)];
                [self.view addSubview:_settingFileView];
            }
            view = _settingFileView;
        }
            break;
        case MAViewTypeAboutUs:
        {
            if (_aboutUsView == nil) {
                _aboutUsView = [[MAViewAboutUs alloc] initWithFrame:CGRectMake(0, KTopViewHeight,
                                                                               self.view.frame.size.width,
                                                                               self.view.frame.size.height - KTopViewHeight)];
                [self.view addSubview:_aboutUsView];
            }
            view = _aboutUsView;
        }
            break;
            
        default:
            break;
    }
    
    return view;
}

-(void)removeView:(MAViewType)type{
    switch (type) {
        case MAViewTypeHome:
        {
            if (_homeView) {
                [_homeView removeFromSuperview];
                _homeView = nil;
            }
        }
            break;
        case MAViewTypeFileManager:
        {
            if (_fileManagerView) {
                [_fileManagerView removeFromSuperview];
                _fileManagerView = nil;
            }
        }
            break;
        case MAViewTypeSetting:
        {
            if (_settingView) {
                [_settingView removeFromSuperview];
                _settingView = nil;
            }
        }
            break;
        case MAViewTypeSettingFile:
        {
            if (_settingFileView) {
                [_settingFileView removeFromSuperview];
                _settingFileView = nil;
            }
        }
            break;
        case MAViewTypeAboutUs:
        {
            if (_aboutUsView) {
                [_aboutUsView removeFromSuperview];
                _aboutUsView = nil;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - email
//点击按钮后，触发这个方法
-(void)sendEMail:(NSArray*)fileArray{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil){
        if ([mailClass canSendMail]){
            [self displayComposerSheet:fileArray];
        }
        else{
            [self launchMailAppOnDevice];
        }
    }
    else{
        [self launchMailAppOnDevice];
    }
}

//可以发送邮件的话
-(void)displayComposerSheet:(NSArray*)fileArray{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject:MyLocal(@"mail_body")];
    
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObject: @"first@example.com"];
    //NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com", nil];
    [mailPicker setToRecipients: toRecipients];
    //[picker setCcRecipients:ccRecipients];
    //[picker setBccRecipients:bccRecipients];
    
    // 添加附件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docspath = [paths objectAtIndex:0];
    for (NSString* file in fileArray) {
        NSData* data = [NSData dataWithContentsOfFile:[docspath stringByAppendingFormat:@"/%@.zip", file]];
        // NSData *imageData = UIImageJPEGRepresentation(addPic, 1);    // jpeg
        [mailPicker addAttachmentData:data mimeType:@"" fileName:file];
    }
    
    NSString *emailBody = MyLocal(@"mail_body");
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController: mailPicker animated:YES];
}

-(void)launchMailAppOnDevice{
    NSString *recipients = @"mailto:first@example.com&subject=my email!";
    //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=my email!";
    NSString *body = @"&body=email body!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"mail_cancel") time:1];
            break;
        case MFMailComposeResultSaved:
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"mail_save_succeed") time:1];
            break;
        case MFMailComposeResultSent:
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"mail_send_succeed") time:1];
            break;
        case MFMailComposeResultFailed:
            [[MAUtils shareUtils] showWeakRemind:MyLocal(@"mail_send_failed") time:1];
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}
@end


#pragma mark - autorotate
@implementation UINavigationController (Autorotate)

//返回最上层的子Controller的shouldAutorotate
//子类要实现屏幕旋转需重写该方法
- (BOOL)shouldAutorotate{
//    return self.topViewController.shouldAutorotate;
    return NO;
}

//返回最上层的子Controller的supportedInterfaceOrientations
- (NSUInteger)supportedInterfaceOrientations{
    return self.topViewController.supportedInterfaceOrientations;
}
@end