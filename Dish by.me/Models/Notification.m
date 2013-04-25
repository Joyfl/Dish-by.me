//
//  Notification.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Notification.h"
#import "NSString+ArgumentArray.h"
#import "DTCoreText.h"

@implementation Notification

+ (id)notificationFromDictionary:(NSDictionary *)dictionary
{
	Notification *notification = [[Notification alloc] init];
	notification.notificationId = [[dictionary objectForKeyNotNull:@"id"] integerValue];
	notification.photoURL = [dictionary objectForKeyNotNull:@"photo_url"];
	notification.description = [NSString stringWithFormat:NSLocalizedString( [dictionary objectForKeyNotNull:@"loc-key"], nil ) arguments:[dictionary objectForKeyNotNull:@"loc-args"]];
	notification.url = [dictionary objectForKeyNotNull:@"url"];
	notification.createdTime = [Utils dateFromString:[dictionary objectForKeyNotNull:@"created_time"]];
	notification.read = [[dictionary objectForKeyNotNull:@"checked"] boolValue];
	
	NSMutableArray *args = [NSMutableArray arrayWithArray:[dictionary objectForKeyNotNull:@"loc-args"]];
	for( NSInteger i = 0; i < args.count; i++ )
	{
		[args replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"<font style='color: #2E2C2A;'><b>%@</b></font>", [args objectAtIndex:i]]];
	}
	
	NSString *descriptionHTML = [NSString stringWithFormat:@"<font style='font-size: 13px; color: #514F4D; font-family: Helvetica; line-height: 16px; shadow-color: red; text-shadow: 0 0.5px white;'>%@</font>", [NSString stringWithFormat:NSLocalizedString( [dictionary objectForKeyNotNull:@"loc-key"], nil ) arguments:args]];
	notification.attributedDescription = [[NSAttributedString alloc] initWithHTMLData:[descriptionHTML dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:NULL];
	
	[notification updateRelativeTime];
	
	return notification;
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:YES];
}

@end
