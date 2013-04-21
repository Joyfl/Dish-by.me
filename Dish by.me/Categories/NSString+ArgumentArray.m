//
//  NSString+ArgumentArray.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "NSString+ArgumentArray.h"

@implementation NSString (ArgumentArray)

+ (NSString *)stringWithFormat:(NSString *)format arguments:(NSArray *)arguments
{
	NSRange range = NSMakeRange( 0, [arguments count] );
	NSMutableData *data = [NSMutableData dataWithLength: sizeof(id) * [arguments count]];
	[arguments getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
	return [[NSString alloc] initWithFormat:format  arguments:data.mutableBytes];
}

@end
