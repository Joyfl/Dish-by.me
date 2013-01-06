//
//  Comment.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@synthesize commentId, userId, userName, userPhotoURL, userPhoto, message, createdTime, updatedTime;

+ (Comment *)commentFromDictionary:(NSDictionary *)dictionary
{
	Comment *comment = [[Comment alloc] init];
	comment.commentId = [[dictionary objectForKey:@"commentId"] integerValue];
	comment.userId = [[[dictionary objectForKey:@"user"] objectForKey:@"id"] integerValue];
	comment.userName = [[dictionary objectForKey:@"user"] objectForKey:@"name"];
	comment.userPhotoURL = [[dictionary objectForKey:@"user"] objectForKey:@"photo_url"];
	comment.message = [dictionary objectForKey:@"message"];
	comment.createdTime = [dictionary objectForKey:@"created_time"];
	comment.updatedTime = [dictionary objectForKey:@"updated_time"];
	return comment;
}

@end
