/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseConvertToCommonEmoticonsHelper.h"
#import "EaseEmoji.h"

@implementation EaseConvertToCommonEmoticonsHelper

#pragma mark - emotics
#pragma mark smallpngface
+ (NSArray*)emotionsArray
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *em = nil;
    for (int i=1; i<=35; i++) {
        em = [NSString stringWithFormat:@"[:%d]",i];
        [array addObject:em];
    }
    
    return array;
    
}
#pragma mark smallpngface
+ (NSDictionary *)emotionsDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"ee_1" forKey:@"[:1]"];
    [dic setObject:@"ee_2" forKey:@"[:2]"];
    [dic setObject:@"ee_3" forKey:@"[:3]"];
    [dic setObject:@"ee_4" forKey:@"[:4]"];
    [dic setObject:@"ee_5" forKey:@"[:5]"];
    [dic setObject:@"ee_6" forKey:@"[:6]"];
    [dic setObject:@"ee_7" forKey:@"[:7]"];
    [dic setObject:@"ee_8" forKey:@"[:8]"];
    [dic setObject:@"ee_9" forKey:@"[:9]"];
    [dic setObject:@"ee_10" forKey:@"[:10]"];
    [dic setObject:@"ee_11" forKey:@"[:11]"];
    [dic setObject:@"ee_12" forKey:@"[:12]"];
    [dic setObject:@"ee_13" forKey:@"[:13]"];
    [dic setObject:@"ee_14" forKey:@"[:14]"];
    [dic setObject:@"ee_15" forKey:@"[:15]"];
    [dic setObject:@"ee_16" forKey:@"[:16]"];
    [dic setObject:@"ee_17" forKey:@"[:17]"];
    [dic setObject:@"ee_18" forKey:@"[:18]"];
    [dic setObject:@"ee_19" forKey:@"[:19]"];
    [dic setObject:@"ee_20" forKey:@"[:20]"];
    [dic setObject:@"ee_21" forKey:@"[:21]"];
    [dic setObject:@"ee_22" forKey:@"[:22]"];
    [dic setObject:@"ee_23" forKey:@"[:23]"];
    [dic setObject:@"ee_24" forKey:@"[:24]"];
    [dic setObject:@"ee_25" forKey:@"[:25]"];
    [dic setObject:@"ee_26" forKey:@"[:26]"];
    [dic setObject:@"ee_27" forKey:@"[:27]"];
    [dic setObject:@"ee_28" forKey:@"[:28]"];
    [dic setObject:@"ee_29" forKey:@"[:29]"];
    [dic setObject:@"ee_30" forKey:@"[:30]"];
    [dic setObject:@"ee_31" forKey:@"[:31]"];
    [dic setObject:@"ee_32" forKey:@"[:32]"];
    [dic setObject:@"ee_33" forKey:@"[:33]"];
    [dic setObject:@"ee_34" forKey:@"[:34]"];
    [dic setObject:@"ee_35" forKey:@"[:35]"];
    
    return dic;
}

+ (NSString *)convertToCommonEmoticons:(NSString *)text
{
//    if (![text isKindOfClass:[NSString class]]) {
//        return @"";
//    }
//
//    if ([text length] == 0) {
//        return @"";
//    }
//    NSDictionary* dic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emotionDB" ofType:@"plist"]];
//    int allEmoticsCount = (int)dic.count;
//    NSMutableString *retText = [[NSMutableString alloc] initWithString:text];
//    for(int i=0; i<allEmoticsCount; ++i) {
//        NSRange range;
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:[dic objectForKey:[dic allKeys][i]]
//                                 withString:[dic allKeys][i]
//                                    options:NSLiteralSearch
//                                      range:range];
//    }
//
//    return retText;
    return text;
}

+ (NSString *)convertToSystemEmoticons:(NSString *)text
{
//    if (![text isKindOfClass:[NSString class]]) {
//        return @"";
//    }
//
//    if ([text length] == 0) {
//        return @"";
//    }
//    NSDictionary* dic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emotionDB" ofType:@"plist"]];
//    int allEmoticsCount = (int)dic.count;
//    NSMutableString *retText = [[NSMutableString alloc] initWithString:text];
//    for(int i=0; i<allEmoticsCount; ++i) {
//        NSRange range;
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:[dic allKeys][i]
//                                 withString:[dic objectForKey:[dic allKeys][i]]
//                                    options:NSLiteralSearch
//                                      range:range];
//    }
//
//    return retText;
    return text;
}

@end
