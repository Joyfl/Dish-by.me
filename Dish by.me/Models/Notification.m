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
	notification.notificationId = [[dictionary objectForKey:@"id"] integerValue];
	notification.photoURL = [dictionary objectForKey:@"photo_url"];
	notification.description = [NSString stringWithFormat:NSLocalizedString( [dictionary objectForKey:@"loc-key"], nil ) arguments:[dictionary objectForKey:@"loc-args"]];
	notification.url = [dictionary objectForKey:@"url"];
	notification.createdTime = [Utils dateFromString:[dictionary objectForKey:@"created_time"]];
	notification.read = [[dictionary objectForKey:@"checked"] boolValue];
	
	NSMutableArray *args = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"loc-args"]];
	for( NSInteger i = 0; i < args.count; i++ )
	{
		[args replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"<font style='color: #2E2C2A;'><b>%@</b></font>", [args objectAtIndex:i]]];
	}
	
	NSString *descriptionHTML = [NSString stringWithFormat:@"<font style='font-size: 13px; color: #514F4D; font-family: Helvetica; line-height: 16px; shadow-color: red; text-shadow: 0 0.5px white;'>%@</font>", [NSString stringWithFormat:NSLocalizedString( [dictionary objectForKey:@"loc-key"], nil ) arguments:args]];
	NSLog( @"descriptionHTML : %@", descriptionHTML );
	notification.attributedDescription = [[NSAttributedString alloc] initWithHTMLData:[descriptionHTML dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:NULL];
	
	[notification updateRelativeTime];
	
	return notification;
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:YES];
}

@end
