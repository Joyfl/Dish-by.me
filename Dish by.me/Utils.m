//
//  Utils.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 20..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (id)parseJSON:(NSString *)json
{
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	return [[parser autorelease] objectWithString:json];
}

+ (NSString *)writeJSON:(id)object
{
	SBJsonWriter *writer = [[SBJsonWriter alloc] init];
	return [[writer autorelease] stringWithObject:object];
}

+ (UIColor *)colorWithHex:(NSInteger)color alpha:(CGFloat)alpha
{
	NSInteger red = ( color >> 16 ) & 0xFF;
	NSInteger green = ( color >> 8 ) & 0xFF;
	NSInteger blue = color & 0xFF;
	return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

@end
