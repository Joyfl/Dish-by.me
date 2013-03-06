//
//  JLHangulUtils.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 7..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "JLHangulUtils.h"

@implementation JLHangulUtils

+ (NSArray *)separateHangul:(NSString *)hangul
{
	unichar unicode = [hangul characterAtIndex:0] - 0xAC00;
	
	unichar jongsungIndex = unicode % 28;
	unichar jungsungIndex = ( ( unicode - jongsungIndex ) / 28 ) % 21;
	unichar chosungIndex = ( unicode - jongsungIndex - 28 * jungsungIndex ) / 588;
	
	NSString *chosung = [JLHangulChosungs objectAtIndex:chosungIndex];
	NSString *jungsung = [JLHangulJungsungs objectAtIndex:jungsungIndex];
	NSString *jongsung = [JLHangulJongsungs objectAtIndex:jongsungIndex];
	
	return @[chosung, jungsung, jongsung];
}

@end
