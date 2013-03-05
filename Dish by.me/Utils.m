//
//  Utils.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 20..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "Utils.h"
#import "CommonCrypto/CommonDigest.h"

@implementation Utils

#warning deprecated.
+ (id)parseJSON:(NSString *)jsonString
{
	return [self parseJSONString:jsonString];
}

+ (id)parseJSONString:(NSString *)jsonString
{
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	return [self parseJSONData:jsonData];
}

+ (id)parseJSONData:(NSData *)jsonData
{
	return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
}

+ (NSString *)writeJSON:(id)object
{
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (UIColor *)colorWithHex:(NSInteger)color alpha:(CGFloat)alpha
{
	NSInteger red = ( color >> 16 ) & 0xFF;
	NSInteger green = ( color >> 8 ) & 0xFF;
	NSInteger blue = color & 0xFF;
	return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

+ (NSString *)sha1:(NSString *)input
{
	NSData *data = [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1( data.bytes, data.length, digest );
	
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	for( int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++ )
		[output appendFormat:@"%02x", digest[i]];
	
	return output;
}

+ (NSDate *)dateFromString:(NSString *)string
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"eee, dd MMM yyyy HH:mm:ss ZZZZ";
	return [formatter dateFromString:string];
}

+ (NSDate *)dateToLocalTimeZone:(NSDate *)date
{
	NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:seconds sinceDate:date];
}

+ (NSDate *)dateToGlobalTimeZone:(NSDate *)date
{
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger seconds = [timeZone secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:seconds sinceDate:date];
}

// date : Local timezone date
+ (NSString *)relativeDateString:(NSDate *)date withTime:(BOOL)withTime
{
	NSDate *now = [NSDate date];
	NSInteger interval = [now timeIntervalSinceDate:date];
	
	// n < 10초 : 몇 초 전
	if( interval < 10 )
	{
		return NSLocalizedString( @"A_FEW_SECONDS_AGO", @"몇 초 전" );
	}
	
	// 10초 <= n < 60초 : n초 전
	else if( interval < 60 )
	{
		return [NSString stringWithFormat:NSLocalizedString( @"N_SECONDS_AGO", @"%d초 전" ), interval];
	}
	
	// 1분
	else if( interval == 60 )
	{
		return NSLocalizedString( @"A_MINUTE_AGO", @"1분 전" );
	}
	
	// 1분 < n < 60분 : n분 전
	else if( interval < 60 * 60 )
	{
		return [NSString stringWithFormat:NSLocalizedString( @"N_MINUTES_AGO", @"%d분 전" ), interval / 60];
	}
	
	else if( interval == 60 )
	{
		return NSLocalizedString( @"AN_HOUR_AGO", @"1시간 전" );
	}
	
	// 1시간 < n < 24시간 : n시간 전
	else if( interval < 24 * 60 * 60 )
	{
		return [NSString stringWithFormat:NSLocalizedString( @"N_HOURS_AGO", @"%d시간 전" ), interval / ( 60 * 60 )];
	}
	
	
	// From here, return date with time if withTime is YES
	NSString *string = nil;
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:date];
	NSInteger year = components.year;
	
	components = [calendar components:NSYearCalendarUnit fromDate:now];
	NSInteger thisYear = components.year;
	
	// 올해
	if( year == thisYear )
	{
		components = [calendar components:NSUIntegerMax fromDate:date toDate:now options:0];
		NSInteger dayInterval = components.day;
		
		// 1일 : 어제
		if( dayInterval == 1 )
		{
			string = NSLocalizedString( @"YESTERDAY", @"어제" );
		}
		
		// 1일 <= n < 7일 : n일 전
		else if( dayInterval < 7 )
		{
			string = [NSString stringWithFormat:NSLocalizedString( @"N_DAYS_AGO", @"%d일 전" ), dayInterval];
		}
		
		// 7일 : 일주일 전
		else if( dayInterval == 7 )
		{
			string = NSLocalizedString( @"A_WEEK_AGO", @"일주일 전" );
		}
		
		// 올해 8일 <= n : M월 d일
		else if( year == thisYear )
		{
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = NSLocalizedString( @"DATE_FORMAT_WITH_MONTH_DAY", @"M월 d일" );
			string = [formatter stringFromDate:date];
		}
	}
	
	// 나머지 : YYYY년 M월 d일
	else
	{
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = NSLocalizedString( @"DATE_FORMAT_WITH_YEAR_MONTH_DAY", @"yyyy년 M월 d일" );
		string = [formatter stringFromDate:[Utils dateToLocalTimeZone:date]];
	}
	
	if( withTime )
	{
		NSString *timeString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		string = [NSString stringWithFormat:@"%@ %@", string, timeString];
	}
	
	return string;
}

+ (UIImage *)cropImage:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return croppedImage;
}

@end
