//
//  Public.h
//  xiaoyixiu
//
//  Created by 柯南 on 16/6/12.
//  Copyright © 2016年 柯南. All rights reserved.
//

#ifndef Public_h
#define Public_h

#pragma mark Log
#ifdef DEBUG

#define DLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define DLog(format, ...)
#endif

#pragma mark ScreenWH

#define SCREEN_BOUNDS            [[UIScreen mainScreen] bounds]
#define WIDTH                    [[UIScreen mainScreen] bounds].size.width

#define HEIGHT                   ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? [UIScreen mainScreen].bounds.size.height - 34 : [UIScreen mainScreen].bounds.size.height)
#define Rect(x, y, w, h)             CGRectMake(x * WIDTH / 1242, y * HEIGHT / 2208, w * WIDTH / 1242, h * HEIGHT / 2208)
#define IS_IPHONE_X              [[UIApplication sharedApplication] statusBarFrame].size.height > 20

#define kSCRATIO(x)                  ceil(((x) * ([UIScreen mainScreen].bounds.size.width / 375)))
#define KSCHEIGHT(x)                  ceil(((x) * ([UIScreen mainScreen].bounds.size.height / 667)))

#define k750Scale                (WIDTH / 375.0)
#define k750AdaptationFont(size)     ([UIFont systemFontOfSize:size * k750Scale])
#define k750AdaptationBoldFont(size) ([UIFont boldSystemFontOfSize:size * k750Scale])
#define k750AdaptationWidth(a)       ((a / 2.0) * k750Scale)
#define BOTTOM_HEIGHT            (IS_IPHONE_X ? 34 : 0)

#define kNavHeight               (IS_IPHONE_X ? 88 : 64)
#define kTabHeight               (IS_IPHONE_X ? 83 : 49)
#define kStatusBarHeight         (IS_IPHONE_X ? 44 : 20)
#define kAvatar_Size             50
#define kGAP                     10
#define kFONT(x) [UIFont fontWithName:@"PingFangSC-Regular" size:kSCRATIO(x)]
#pragma clang diagnostic ignored"-Wdeprecated"

#pragma mark Color

#define kColorFromARGBHex(value, a) [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0 green:((float)((value & 0xFF00) >> 8)) / 255.0 blue:((float)(value & 0xFF)) / 255.0 alpha:a] //a:透明度
#define kColorFromRGBHex(value)     [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0 green:((float)((value & 0xFF00) >> 8)) / 255.0 blue:((float)(value & 0xFF)) / 255.0 alpha:1.0]
#define kColorFromRGB(r, g, b)      [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]
#define kColorFromRGBA(r, g, b, a)  [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]
#define Color130A29              kColorFromRGBHex(0xFFFFFF)
#define Color1C152F              kColorFromRGBHex(0x1C152F)
#define ColorFF2762              kColorFromRGBHex(0xFF2762)
#define Color1B142E              kColorFromRGBHex(0x1B142E)
#define AppBaseColor             kColorFromRGBHex(0xfec74c)
#define ColorWhite               kColorFromRGBHex(0xFFFFFF)
#define ColorE6E6E6              kColorFromRGBHex(0xE6E6E6)
#define ColorBlack               kColorFromRGBHex(0x000000)
#define Color333333               kColorFromRGBHex(0x333333)
#define Color999999              kColorFromRGBHex(0x999999)
#define ColorFFE131            kColorFromRGBHex(0xFFE131)
#define Color8E57FF            kColorFromRGBHex(0x8E57FF)
#define Color191A19           kColorFromRGBHex(0x191A19)

	

#define AppPageColor             kColorFromRGB(235, 235, 241) //灰色
#define AppThemeBackColor        [UIColor colorWithRed:229.0 / 255 green:229.0 / 255 blue:229.0 / 255 alpha:1]
#define AppBackColor             [UIColor colorWithRed:10.0 / 255 green:96.0 / 255 blue:254.0 / 255 alpha:1]
#define AppButtonbackgroundColor Color130A29//app  按钮颜色
#define AppThemeColor            kColorFromRGBHex(0xFCAA1B)//
#define BaseColor                kColorFromRGBHex(0xF3F3F3) //app  底色
#define PageColor                kColorFromRGB(186, 186, 186)
#define LineColor                kColorFromRGBHex(0xafafaf)
#define fontLightGray            kColorFromRGBHex(0xc6c6c6)
#define TableViewBGcolor         kColorFromRGBHex(0xECECEC)
#define FontBlack                kColorFromRGBHex(0x646464)
#define RedBackGround            kColorFromRGBHex(0xFF4D4D)
#define AppBlue                  kColorFromRGBHex(0x1786e2)

#pragma mark 系统文件位置

#define DOCUMENT_FOLDER(fileName) [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:fileName]
#define CACHE_FOLDER(fileName)    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]
#define kUserDefaults            [NSUserDefaults standardUserDefaults]

#define WS(weakSelf)              __weak typeof(self)weakSelf = self

#pragma mark 其它

#define Context                  [UserInfoContext sharedContext]

#define POSITION                 @"position"
#define TRANSFORM_SCALE          @"transform.scale"


//View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

#endif /* Public_h */
