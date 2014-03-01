//
//  JJHConfig.h
//  SanGameJJH
//
//  Created by ken on 13-4-15.
//  Copyright (c) 2013年 ken. All rights reserved.
//

#ifndef SanGameJJH_JJHConfig_h
#define SanGameJJH_JJHConfig_h

//#define KAppTest


#define IsPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)    //是否为pad判断
#define MyLocal(x, ...) NSLocalizedString(x, nil)       //定义国际化使用

//日志输出定义
#ifdef DEBUG
#   define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DebugLog(...)
#endif

#define KSafeRelease(a)     if(a){delete a;a = nil;}

//颜色取值宏
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//取图片宏
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//取字典宏
#define LOADDIC(file,ext) [[NSMutableDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//系统版本判断
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define KCellTag(a,b)           ((a) * 100 + (b) + 1000)

//字体、字号、颜色
#define KLabelFontArial         @"Arial"
#define KLabelFontStd           @"Std"
#define KLabelFontHelvetica     @"Helvetica"
#define KLabelFontSize12        (12)
#define KLabelFontSize14        (14)
#define KLabelFontSize16        (16)
#define KLabelFontSize18        (18)
#define KLabelFontSize22        (22)
#define KLabelFontSize30        (30)

//NSUserDefaults key
#define KUserDefaultFileTimeMax            @"default_file_time_max"
#define KUserDefaultFileTimeMin            @"default_file_time_min"
#define KUserDefaultClearRubbish           @"default_clear_rubbish"
#define KUserDefaultVoiceStartPos          @"default_voice_start_pos"
#define KUserDefaultSetSkin                @"default_set_skin"
#define KUserDefaultPassword               @"default_user_password"
#define KUserDefaultResetPassword          @"default_user_reset_password"
#define KUserDefaultPreClearTime           @"default_pre_clear_time"
#define KUserDefaultNextClearTime          @"default_next_clear_time"

//数据库部分
#define KSqliteDBName           @"SQLiteVoiceControl.db"
#define KTableVoiceFiles        @"tableVoiceFiles"
#define KTablePlan              @"tablePlan"

//数据库 字段定义
//tableVoiceFiles
#define KDataBaseId                 @"id"
#define KDataBaseFileName           @"name"
#define KDataBaseTime               @"time"
#define KDataBasePath               @"path"
#define KDataBaseDuration           @"duration"
#define KDataBaseDataEver           @"ever"
#define KDataBaseTitle              @"title"
#define KDataBasePlanTime           @"plantime"
#define KDataBaseStatus             @"status"
#define KDataBaseDate               @"date"

#define KNameFormat                 @"MMMddHHmmss"
#define KTimeFormat                 @"MM-dd HH:mm:ss"
#define KDateFormat                 @"YYYY-MM-dd"
#define KDateTimeFormat             @"YYYY-MM-dd HH:mm"

//其它
#define KCAPWidth               (5.0)
#define KNavigationHeight       (44)
#define KStatusBarHeight        (20)
#define KZipMinSize             (32 * 1024)       //kb
#define KAnimationTime          (0.5)  

//set color and image
#define KSkinSetDefault             @"skin_default"

#define KSkinSetDicColor            @"skin_set_color"
#define KSkinSetColorDefWhite       @"skin_color_def_white"
#define KSkinSetColorDefBlack       @"skin_color_def_black"
#define KSkinSetColorDefGray        @"skin_color_def_gray"
#define KSkinSetColorDefBlue        @"skin_color_def_blue"
#define KSkinSetColorHomeBg         @"skin_color_home_bg"
#define KSkinSetColorTableLabel     @"skin_color_table_label"
#define KSkinSetColorDropBG         @"skin_color_drop_bg"
#define KSkinSetColorDropCellBG     @"skin_color_drop_cell_bg"
#define KSkinSetColorBtnGreen       @"skin_color_def_btn_green"
#define KSkinSetColorBtnDarkGreen   @"skin_color_def_btn_dark_green"
#define KSkinSetColorBtnRed         @"skin_color_def_btn_red"
#define KSkinSetColorBtnDarkRed     @"skin_color_def_btn_dark_red"
#define KSkinSetColorBtnGray        @"skin_color_def_btn_gray"

#define KSkinSetDicImage            @"skin_set_image"
#define KSkinSetImgHomePhone        @"skin_image_home_phone"
#define KSkinSetImgHomeMenu         @"skin_image_home_menu"
#define KSkinSetImgPlayPlay         @"skin_image_play_play"
#define KSkinSetImgPlayNext         @"skin_image_play_next"
#define KSkinSetImgPlayPause        @"skin_image_play_pause"
#define KSkinSetImgPlayPre          @"skin_image_play_pre"
#define KSkinSetImgBtnGreenCircleSec    @"skin_image_btn_green_circle_sec"
#define KSkinSetImgBtnGreenCircle       @"skin_image_btn_green_circle_btn"
#define KSkinSetImgBtnRedCircleSec      @"skin_image_btn_red_circle_sec"
#define KSkinSetImgBtnRedCircle         @"skin_image_btn_red_circle_btn"
#define KSkinSetImgBtnGrayCircle        @"skin_image_btn_gray_circle"
#define KSkinSetImgAddPlanReSec         @"skin_image_addplan_repeat_sec"
#define KSkinSetImgCellIndicator        @"skin_image_cell_indicator"
#define KSkinSetImgScrubberKnob         @"skin_image_scrubber_knob"
#define KSkinSetImgScrubberLeft         @"skin_image_scrubber_left"
#define KSkinSetImgScrubberKnobRight    @"skin_image_scrubber_right"


//资源Key值宏定义
#define KID                     @"id"
#define KData                   @"data"
#define KName                   @"name"
#define KPath                   @"path"
#define KImage                  @"image"
#define KButton                 @"button"
#define KColor                  @"color"
#define KValue                  @"value"
#define KStatus                 @"status"
#define KType                   @"type"
#define KArray                  @"array"
#define KSwitch                 @"switch"
#define KText                   @"text"
#define KContent                @"content"
#define KTitle                  @"title"
#define KTime                   @"time"
#define KHeight                 @"height"
#define KWidth                  @"width"
#define KEnabled                @"enabled"

#define KPlanTime               @"plan_time"
#define KCanJump                @"can_jump"
#define KSwitchOn               @"switch_on"
#define KRightView              @"right_view"
#define KleftView               @"left_view"
#define KNorBgColor             @"normal_bg_color"
#define KNorBgImage             @"normal_bg_image"
#define KSecBgColor             @"select_bg_color"
#define KSecBgImage             @"select_bg_image"
#define KSecStyle               @"selection_style"
#define KTableProperty          @"table_property"
#define KSectionProperty        @"section_property"
#define KSectionArray           @"section_array"
#define KCellArray              @"cell_array"
#define KCellEnabled            @"cell_enabled"

#define KMenuTableView          @"menu_table_view"

//mail
#define KMailSubject            @"mail_subject"
#define KMailToRecipients       @"mail_to_recipients"
#define KMailCcRecipients       @"mail_cc_recipients"
#define KMailBccRecipients      @"mail_bcc_recipients"
#define KMailAttachment         @"mail_attachment"
#define KMailBody               @"mail_body"

#endif
