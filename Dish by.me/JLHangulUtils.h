//
//  JLHangulUtils.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 7..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JLHangulChosungs @[ @"ㄱ", @"ㄲ", @"ㄴ", @"ㄷ", @"ㄸ", @"ㄹ", @"ㅁ", @"ㅂ", @"ㅃ", @"ㅅ", @"ㅆ", @"ㅇ", @"ㅈ", @"ㅉ", @"ㅊ", @"ㅋ", @"ㅌ", @"ㅍ", @"ㅎ" ]
#define JLHangulJungsungs @[ @"ㅏ", @"ㅐ", @"ㅑ", @"ㅒ", @"ㅓ", @"ㅔ", @"ㅕ", @"ㅖ", @"ㅗ", @"ㅘ", @"ㅙ", @"ㅚ", @"ㅛ", @"ㅜ", @"ㅝ", @"ㅞ", @"ㅟ", @"ㅠ", @"ㅡ", @"ㅢ", @"ㅣ" ]
#define JLHangulJongsungs @[ @"", @"ㄱ", @"ㄲ", @"ㄳ", @"ㄴ", @"ㄵ", @"ㄶ", @"ㄷ", @"ㄹ", @"ㄺ", @"ㄻ", @"ㄼ", @"ㄽ", @"ㄾ", @"ㄿ", @"ㅀ", @"ㅁ", @"ㅂ", @"ㅄ", @"ㅅ", @"ㅆ", @"ㅇ", @"ㅈ", @"ㅊ", @"ㅋ", @"ㅌ", @"ㅍ", @"ㅎ" ]

@interface JLHangulUtils : NSObject

+ (NSArray *)separateHangul:(NSString *)hangul;

@end
