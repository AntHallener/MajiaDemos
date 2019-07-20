//
//  Macros.h
//  YunFengSi
//
//  Created by 杨科军 on 2018/9/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

// 输出日志 (格式: [时间] [哪个方法] [哪行] [输出内容])
#ifdef DEBUG
#define NSLog(format, ...)printf("\n[%s] %s [第%d行] 🤨🤨 %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

// 日记输出宏
#ifdef DEBUG // 调试状态, 打开LOG功能
#define KJLog(...)NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define KJLog(...)
#endif

/// 适配iPhone X + iOS 11
#define  KJAdjustsScrollViewInsets_Never(__scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([__scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]){\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = __scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)

#define _weakself __weak typeof(self)weakself = self

#pragma mark *******    iPhoneX   *********/
#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

// tabBar height
#define kTABBAR_HEIGHT (iPhoneX?(49.f+34.f):49.f)

// statusBar height.
#define kSTATUSBAR_HEIGHT (iPhoneX?44.0f:20.f)

// navigationBar height.
#define kNAVIGATION_HEIGHT (44.f)

// (navigationBar + statusBar) height.
#define kSTATUSBAR_NAVIGATION_HEIGHT (iPhoneX?88.0f:64.f)

/**
 Return 没有tabar 距 底边高度
 */
#define BOTTOM_SPACE_HEIGHT (iPhoneX?34.0f:0.0f)

#pragma mark *******    屏幕的宽高   *********/
// 屏幕总尺寸
#define SCREEN_WIDTH        [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT       [[UIScreen mainScreen] bounds].size.height
#define kScreenW    ([UIScreen mainScreen].bounds.size.width)
#define kScreenH    ([UIScreen mainScreen].bounds.size.height)
#define Handle_width(w)  ((w)*SCREEN_SCALE)
#define Handle_height(h) ((h)*SCREEN_SCALE)
// 等比例缩放系数
#define SCREEN_SCALE  ((SCREEN_WIDTH > 414)? (SCREEN_HEIGHT/375.0): (SCREEN_WIDTH/375.0))
#define Handle(x)    ((x)*SCREEN_SCALE)

#pragma mark *******    颜色   *********/
#define UIColorFromHEXA(hex,a)    [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]
#define UIColorFromRGBA(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]  // rgb颜色+透明度
#define UIColorHexFromRGB(hex)    UIColorFromHEXA(hex,1.0)


#define MainColor(a)          UIColorFromHEXA(0x022850,a)   // app 主色调
#define BtnUnEnableBgColor    UIColorFromHEXA(0xbbbbbb,1.0) // 按钮不可点击状态
#define BtnBgColor            UIColorFromHEXA(0xFFD308,1.0) // 按钮可点击状态
#define DefaultTitleColor     UIColorFromHEXA(0x343434,1.0) // 字体颜色
#define DefaultBackgroudColor UIColorFromHEXA(0xf9f6f6,1.0) // 视图里面的背景颜色
#define DefaultLineColor      UIColorFromHEXA(0x000000,0.5) // 边框线的颜色
// 填充颜色,获取的是父视图Table背景颜色
#define KJTableFillColor      [UIColor groupTableViewBackgroundColor]


#pragma mark *******    图片资源相关   *********
#define GetImage(imageName)  [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]
#define DefaultHeaderImage   GetImage(@"me_no_header")    // 头像占位图
#define DefaultCoverImage    GetImage(@"me_no_cover")     // 封面占位图
#define DefaultBGImage       GetImage(@"Home_background")

#pragma mark *******    系统默认字体设置和自选字体设置   *********/
#define SystemFontSize(fontsize)[UIFont systemFontOfSize:(fontsize)]
#define SystemBoldFontSize(fontsize)[UIFont boldSystemFontOfSize:(fontsize)]
#define CustomFontSize(fontname,fontsize)[UIFont fontWithName:fontname size:fontsize]

#pragma mark ********** 工程相关 ************/
/** 获取APP名称 */
#define APP_NAME ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"])
/** 程序版本号 */
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
/** 获取APP build版本 */
#define APP_BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

#define kAppName  [KJTools appName]
//#define kIDName   @"星云号"
#define kAppIcon  GetImage(@"LOGOstore_1024pt")
#define kAppID    @"1440454006"

#pragma mark *******    语言相关   *********/
#define SetLocationLanauage     @"setLocationLanauage"  //  设置语言
// 判断系统语言
#define CURR_LANG ([[NSLocale preferredLanguages] objectAtIndex:0])
#define LanguageIsEnglish ([CURR_LANG isEqualToString:@"en-US"] || [CURR_LANG isEqualToString:@"en-CA"] || [CURR_LANG isEqualToString:@"en-GB"] || [CURR_LANG isEqualToString:@"en-CN"] || [CURR_LANG isEqualToString:@"en"])   // 是否为英文
#define En                @"en"     // 英文请求头
#define Zh                @"zh-CN"  // 中文请求头

#pragma mark *******    需要存入UserDefaults相关   *********
#define UserDefault     [NSUserDefaults standardUserDefaults]

//#pragma mark ********** 通知消息的名字相关 ************/
//#define NotificationCenter(name,dict)    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:dict]
//#define NotificationModel(name)     [name modelWithJSON:info.userInfo[@"data"]]
//#define Register_Tag_Push_Home      @"Register_Tag_Push_Home"          // 从注册位置的选择标签之后跳转到首页
//#define Me_changed_info_data        @"Me_changed_info_data"            // 更改了资料
//#define Me_changed_info_tag_data    @"Me_changed_info_tag_data"        // 更改了标签资料
//#define Check_login_status          @"Check_login_status"              // 检查登陆状态
//#define Login_Register_sucess       @"Login_Register_sucess"           // 登陆或者注册成功,  为了开启长连接


#endif /* Macros_h */
