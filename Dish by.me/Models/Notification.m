//
//  Notification.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "Notification.h"
#import "NSString+ArgumentArray.h"

@implementation Notification

+ (id)notificationFromDictionary:(NSDictionary *)dictionary
{
	Notification *notification = [[Notification alloc] init];
	notification.notificationId = [[dictionary objectForKey:@"id"] integerValue];
	notification.photoURL = [dictionary objectForKey:@"photo_url"];
	notification.description = [NSString stringWithFormat:NSLocalizedString( [dictionary objectForKey:@"loc-key"], nil ) arguments:[dictionary objectForKey:@"loc-args"]];
	notification.url = [dictionary objectForKey:@"url"];
	notification.createdTime = [Utils dateFromString:[dictionary objectForKey:@"created_time"]];
	return notification;
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:YES];
}

@end
