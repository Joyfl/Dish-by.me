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
	
	if( chosungIndex < 0 || chosungIndex >= JLHangulChosungs.count ) return nil;
	NSString *chosung = [JLHangulChosungs objectAtIndex:chosungIndex];
	
	if( jungsungIndex < 0 || jungsungIndex >= JLHangulJungsungs.count ) return @[chosung, @"", @""];
	NSString *jungsung = [JLHangulJungsungs objectAtIndex:jungsungIndex];
	
	if( jongsungIndex < 0 || jongsungIndex >= JLHangulJongsungs.count ) return @[chosung, jungsung, @""];
	NSString *jongsung = [JLHangulJongsungs objectAtIndex:jongsungIndex];
	
	return @[chosung, jungsung, jongsung];
}

@end
