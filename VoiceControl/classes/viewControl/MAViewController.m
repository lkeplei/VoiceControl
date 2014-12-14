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
#import "MAViewFactory.h"

#import "MAViewSelectMenu.h"

#import "AdMoGoInterstitialManager.h"

#define KTopButtonWidth     (80)

@interface MAViewController (){
    float   preTransX;
    BOOL    isMenuOpening;
}

@property (nonatomic, strong) UIView* topView;
@property (nonatomic, strong) UIButton* menuBtn;
@property (nonatomic, strong) UIButton* homeBtn;
@property (nonatomic, strong) UILabel* menuLabel;
@property (nonatomic, strong) UILabel* homeLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic) UIPanGestureRecognizer* panGestureRecongnize;
@property (nonatomic, strong) MAViewBase* currentShowView;
@property (nonatomic, strong) MAViewBase* preShowView;

@property (nonatomic, strong) MAViewSelectMenu* selectMenu;

@end

@implementation MAViewController

@synthesize viewFactory = _viewFactory;
@synthesize adView = _adView;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //初始全屏广告
    [self initFullMogo];
    
    _viewFactory = [[MAViewFactory alloc] init];
    [self initView];
    [self setupGestures];
    
    isMenuOpening = NO;
}

#pragma mark - init area
- (void)initView {
    _selectMenu = [[MAViewSelectMenu alloc] initWithFrame:CGRectMake(0, 0, KViewMenuWidth, self.view.height)];
    [self.view addSubview:_selectMenu];
    
    [self initTopView];
    
    _currentShowView = [self addView:MAViewTypeHome];
    [_currentShowView showView];
    [_titleLabel setText:_currentShowView.viewTitle];
}

- (void)initTopView {
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, KNavigationHeight + KStatusBarHeight)];
    [_topView setBackgroundColor:[[MAModel shareModel] getColorByType:MATypeColorTopView default:NO]];
    [self.view addSubview:_topView];
    
    UIImageView* separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_separator_line.png"]];
    separatorLine.frame = CGRectMake(0, CGRectGetHeight(_topView.frame) - separatorLine.frame.size.height,
                                     CGRectGetWidth(_topView.frame), separatorLine.frame.size.height);
    [_topView addSubview:separatorLine];
    
    _titleLabel = [MAUtils labelWithTxt:nil
                                  frame:CGRectMake(0, KStatusBarHeight, _topView.frame.size.width, KNavigationHeight)
                                   font:[UIFont fontWithName:KLabelFontArial size:IsPad ? KLabelFontSize22 : KLabelFontSize18]
                                  color:[[MAModel shareModel] getColorByType:MATypeColorDefBlack default:NO]];
    [_topView addSubview:_titleLabel];
    
    //right btn
    _homeBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                         image:nil imagesec:nil
                                        target:self action:@selector(homeBtnClicked:)];
    _homeBtn.frame = CGRectMake(_topView.frame.size.width - KTopButtonWidth, KStatusBarHeight, KTopButtonWidth, KNavigationHeight);
    [_topView addSubview:_homeBtn];
    
    _homeLabel = [MAUtils labelWithTxt:nil
                                 frame:CGRectMake(0, 0, _homeBtn.frame.size.width, _homeBtn.frame.size.height)
                                  font:[[MAModel shareModel] getLabelFontSize:KLabelFontHelvetica size:IsPad ? KLabelFontSize32 : KLabelFontSize22]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorBtnRed default:NO]];
    [_homeBtn addSubview:_homeLabel];
    
    //left btn
    _menuBtn = [MAUtils buttonWithImg:nil off:0 zoomIn:NO
                                         image:nil imagesec:nil
                                        target:self action:@selector(menuBtnClicked:)];
    _menuBtn.frame = CGRectMake(0, KStatusBarHeight, KTopButtonWidth, KNavigationHeight);
    [_topView addSubview:_menuBtn];
    
    _menuLabel = [MAUtils labelWithTxt:MyLocal(@"home_top_left")
                                 frame:CGRectMake(0, 0, _menuBtn.frame.size.width, _menuBtn.frame.size.height)
                                  font:[[MAModel shareModel] getLabelFontSize:KLabelFontHelvetica size:IsPad ? KLabelFontSize28 : KLabelFontSize22]
                                 color:[[MAModel shareModel] getColorByType:MATypeColorBtnRed default:NO]];
    [_menuBtn addSubview:_menuLabel];
}

#pragma mark - btn clicked
- (void)menuBtnClicked:(id)sender {
    if ([_currentShowView subEventLeft]) {
        [_currentShowView eventTopBtnClicked:YES];
    } else {
        [self resetMenu];
    }
}

- (void)resetMenu {
    isMenuOpening = !isMenuOpening;
    if (isMenuOpening) {
        [self showMenu];
    } else {
        [self hideMenu];
    }
}

- (void)homeBtnClicked:(id)sender {
    if ([_currentShowView subEventRight]) {
        [_currentShowView eventTopBtnClicked:NO];
    } else {
        [self changeToViewByType:MAViewTypeHome changeType:MATypeTransitionRippleEffect];
    }
}
#pragma mark - about panel
- (void)hideMenu {
	[UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _currentShowView.frame = (CGRect){0, _currentShowView.originY, _currentShowView.size};
//        _menuBtn.transform = CGAffineTransformRotate(_menuBtn.transform, -M_PI_2);
        _topView.frame = (CGRect){CGPointZero, _topView.size};
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
}

- (void)showMenu {
    [UIView animateWithDuration:KAnimationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _currentShowView.frame = (CGRect){KViewMenuWidth, _currentShowView.originY, _currentShowView.size};
//        _menuBtn.transform = CGAffineTransformRotate(_menuBtn.transform, M_PI_2);
        _topView.frame = (CGRect){KViewMenuWidth, _topView.originY, _topView.size};
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
}

#pragma mark Swipe Gesture Setup/Actions
- (void)setupGestures {
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
                _topView.frame = CGRectOffset(_topView.frame, offx, 0);
                preTransX = translatedPoint.x;
            }
        }
	}
}

#pragma mark - about view control
- (MAViewBase*)getView:(MAViewType)type {
    return [_viewFactory getView:type frame:CGRectMake(0, KNavigationHeight + KStatusBarHeight, self.view.frame.size.width,
                                                                   self.view.frame.size.height - KNavigationHeight - KStatusBarHeight)];
}

- (MAViewBase*)addView:(MAViewType)type {
    MAViewBase* view = [_viewFactory getView:type frame:CGRectMake(0, KNavigationHeight + KStatusBarHeight, self.view.frame.size.width,
                                                                   self.view.frame.size.height - KNavigationHeight - KStatusBarHeight)];
    [self.view addSubview:view];
    return view;
}

- (void)pushView:(MAViewBase*)subView animatedType:(MAType)type {
    _preShowView = _currentShowView;
    _currentShowView = subView;
    
    [[MAModel shareModel] changeView:_preShowView
                                  to:_currentShowView
                                type:MATypeChangeViewCurlDown
                            delegate:self];
    [_currentShowView showView];
    [_titleLabel setText:_currentShowView.viewTitle];
    [self.view addSubview:_currentShowView];
    
    //页面已切换
    [_currentShowView viewDidAppear:YES];
    [_preShowView viewDidDisappear:YES];
}

- (void)popView:(MAViewBase*)lastView preView:(MAViewBase*)preView animatedType:(MAType)type {
    _currentShowView = preView;
    
    [[MAModel shareModel] changeView:lastView
                                  to:preView
                                type:MATypeChangeViewCurlUp
                            delegate:self];
    
    [_titleLabel setText:_currentShowView.viewTitle];
    
    //页面已切换
    [preView viewDidAppear:YES];
    [lastView viewDidDisappear:YES];
    
    [_viewFactory removeView:lastView.viewType];
}

- (void)changeToViewByType:(MAViewType)type changeType:(MAType)changeType {
    //旧页面将切换
    [_preShowView viewWillDisappear:YES];
    
    if (_preShowView) {
        [_viewFactory removeView:_preShowView.viewType];
    }
    [_viewFactory removeView:_currentShowView.viewType];
    
    MAViewType currentType = _currentShowView.viewType;
    _currentShowView = [self addView:type];
    _preShowView = [self addView:currentType];
    
    //新页面将显示
    [_currentShowView viewWillAppear:YES];
    
    //旧页面移除
    if (_preShowView && _preShowView.viewType != _currentShowView.viewType) {
        [_viewFactory removeView:_preShowView.viewType];
    }
    
    [[MAModel shareModel] changeView:_preShowView
                                  to:_currentShowView
                                type:changeType
                            delegate:self];
    //新页面show
    [_currentShowView showView];
    
    [_titleLabel setText:_currentShowView.viewTitle];
    
    //添加百度页面统计
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobPageStart eventName:_currentShowView.viewTitle label:nil];
    [[MAModel shareModel] setBaiduMobStat:MATypeBaiduMobPageEnd eventName:_preShowView.viewTitle label:nil];
    
    //hide menu
    if (isMenuOpening) {
        [self resetMenu];
    }
    
    //页面已切换
    [_currentShowView viewDidAppear:YES];
    [_preShowView viewDidDisappear:YES];
}

#pragma mark - other methods
- (void)setGestureEnabled:(BOOL)enabled {
    [_panGestureRecongnize setEnabled:enabled];
}

- (void)setTopBtn:(NSString*)leftBtn rightBtn:(NSString*)rightBtn enabled:(BOOL)enabled {
    if (enabled) {
        [_homeLabel setText:rightBtn];
        [_menuLabel setText:leftBtn];
    } else {
        if (leftBtn) {
            [_menuLabel setText:leftBtn];
        } else {
            [_menuLabel setText:MyLocal(@"home_top_left")];
        }
        
        if (rightBtn) {
            [_homeLabel setText:rightBtn];
        } else {
            [_homeLabel setText:MyLocal(@"home_top_right")];
        }
    }
}

#pragma mark - email
//点击按钮后，触发这个方法
- (void)sendEMail:(NSDictionary*)mailDic {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil && mailDic){
        if ([mailClass canSendMail]){
            MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
            
            mailPicker.mailComposeDelegate = self;

            //设置主题
            NSString* subject = [mailDic objectForKey:KMailSubject];
            if (subject) {
                [mailPicker setSubject:subject];
            }
            
            //添加收件人
            NSArray* toRecipients = [mailDic objectForKey:KMailToRecipients];
            if (toRecipients) {
                [mailPicker setToRecipients:toRecipients];
            }
            
            //添加抄送人
            NSArray* ccRecipients = [mailDic objectForKey:KMailCcRecipients];
            if (ccRecipients) {
                [mailPicker setCcRecipients:ccRecipients];
            }
            
            //添加bcc
            NSArray* bccRecipients = [mailDic objectForKey:KMailBccRecipients];
            if (bccRecipients) {
                [mailPicker setBccRecipients:bccRecipients];
            }
            
            //添加附件
            NSArray* attachments = [mailDic objectForKey:KMailAttachment];
            if (attachments) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docspath = [paths objectAtIndex:0];
                for (NSString* file in attachments) {
                    NSData* data = [NSData dataWithContentsOfFile:[docspath stringByAppendingFormat:@"/%@.zip", file]];
                    // NSData *imageData = UIImageJPEGRepresentation(addPic, 1);    // jpeg
                    [mailPicker addAttachmentData:data mimeType:@"" fileName:file];
                }
            }
            
            //添加消息体
            NSString* body = [mailDic objectForKey:KMailBody];
            if (body) {
                [mailPicker setMessageBody:body isHTML:YES];
            }
            
            [self presentViewController:mailPicker animated:YES completion:^{
                DebugLog(@"present mail view")
            }];
        }
    }
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
    
    [self dismissViewControllerAnimated:YES completion:^{
        DebugLog(@"dismiss mail view");
    }];
}



#pragma mark - 广告相关内容
#pragma mark - full admogo
-(void)initFullMogo{
    NSString* mogoId = KADIphoneId;
    if (IsPad) {
        mogoId = KADIpadId;
    }
    [AdMoGoInterstitialManager setAppKey:mogoId];
    //初始化(必须先设置默认的AppKey才能通过此方法初始化SDK)
    [[AdMoGoInterstitialManager shareInstance] initDefaultInterstitial];
    [AdMoGoInterstitialManager setRootViewController:self];
    
    [AdMoGoInterstitialManager setDefaultDelegate:self];
}

-(void)showFullAd{
    [[AdMoGoInterstitialManager shareInstance] interstitialShow:NO];
}

- (void)cancelFullAd{
    [[AdMoGoInterstitialManager shareInstance] interstitialCancel];
}

/*
 返回广告rootViewController
 */
- (UIViewController *)viewControllerForPresentingInterstitialModalView{
    return self;
}

/*
 全屏广告开始请求
 */
- (void)adsMoGoInterstitialAdDidStart{
    NSLog(@"MOGO Full Screen Start");
}

/*
 全屏广告准备完毕
 */
- (void)adsMoGoInterstitialAdIsReady{
    NSLog(@"MOGO Full Screen IsReady");
}

/*
 全屏广告接收成功
 */
- (void)adsMoGoInterstitialAdReceivedRequest{
    NSLog(@"MOGO Full Screen Received");
}

/*
 全屏广告将要展示
 */
- (void)adsMoGoInterstitialAdWillPresent{
    NSLog(@"MOGO Full Screen Will Present");
}

/*
 全屏广告接收失败
 */
- (void)adsMoGoInterstitialAdFailedWithError:(NSError *) error{
    NSLog(@"MOGO Full Screen Failed");
}

/*
 全屏广告消失
 */
- (void)adsMoGoInterstitialAdDidDismiss{
    NSLog(@"MOGO Full Screen Dismiss");
}

#pragma mark - AdMoGoDelegate delegate
-(void)clearAllAd{
    [self removeAd];
    [[AdMoGoInterstitialManager shareInstance] interstitialCancel];
}

-(void)removeAd{
    if (_adView) {
        [_adView removeFromSuperview];
        _adView = nil;
    }
}

-(void)resetAd{
    [self removeAd];
    
    NSString* mogoId = KADIphoneId;
    if (IsPad) {
        mogoId = KADIpadId;
    }

    if (IsPad) {
        _adView = [[AdMoGoView alloc] initWithAppKey:mogoId adType:AdViewTypeLargeBanner adMoGoViewDelegate:self];
//        _adView.frame = CGRectMake(0.0, _currentShowView.height - (KADViewHeight - 10), self.view.width, KADViewHeight - 10);
        _adView.frame = CGRectOffset(_adView.frame, 0, -110);
    } else {
        _adView = [[AdMoGoView alloc] initWithAppKey:mogoId adType:AdViewTypeNormalBanner adMoGoViewDelegate:self];
        _adView.frame = CGRectMake(0.0, _currentShowView.height - (KADViewHeight - 10), self.view.width, KADViewHeight - 10);
    }
    _adView.adWebBrowswerDelegate = self;
    [_currentShowView addSubview:_adView];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [_currentShowView bringSubviewToFront:_adView];
}

/*
 返回广告rootViewController
 */
- (UIViewController *)viewControllerForPresentingModalView{
    return self;
}

/**
 * 广告开始请求回调
 */
- (void)adMoGoDidStartAd:(AdMoGoView *)adMoGoView{
    NSLog(@"广告开始请求回调");
}
/**
 * 广告接收成功回调
 */
- (void)adMoGoDidReceiveAd:(AdMoGoView *)adMoGoView{
    NSLog(@"广告接收成功回调");
    if (IsPad) {
        _adView.frame = CGRectOffset(_adView.frame,
                                    ([UIScreen mainScreen].bounds.size.width - _adView.frame.size.width) / 2,
                                    [UIScreen mainScreen].bounds.size.height - _adView.frame.size.height);
    }
}
/**
 * 广告接收失败回调
 */
- (void)adMoGoDidFailToReceiveAd:(AdMoGoView *)adMoGoView didFailWithError:(NSError *)error{
    NSLog(@"广告接收失败回调");
}
/**
 * 点击广告回调
 */
- (void)adMoGoClickAd:(AdMoGoView *)adMoGoView{
    NSLog(@"点击广告回调");
}
/**
 *You can get notified when the user delete the ad
 广告关闭回调
 */
- (void)adMoGoDeleteAd:(AdMoGoView *)adMoGoView{
    NSLog(@"广告关闭回调");
}

#pragma mark -
#pragma mark AdMoGoWebBrowserControllerUserDelegate delegate

/*
 浏览器将要展示
 */
- (void)webBrowserWillAppear{
    NSLog(@"浏览器将要展示");
}

/*
 浏览器已经展示
 */
- (void)webBrowserDidAppear{
    NSLog(@"浏览器已经展示");
}

/*
 浏览器将要关闭
 */
- (void)webBrowserWillClosed{
    NSLog(@"浏览器将要关闭");
}

/*
 浏览器已经关闭
 */
- (void)webBrowserDidClosed{
    NSLog(@"浏览器已经关闭");
}
/**
 *直接下载类广告 是否弹出Alert确认
 */
-(BOOL)shouldAlertQAView:(UIAlertView *)alertView{
    return NO;
}

- (void)webBrowserShare:(NSString *)url{
    
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