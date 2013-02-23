//
//  Comment.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "Comment.h"
#import "Utils.h"

@implementation Comment

+ (Comment *)commentFromDictionary:(NSDictionary *)dictionary
{
	Comment *comment = [[Comment alloc] init];
	comment.commentId = [[dictionary objectForKey:@"id"] integerValue];
	comment.userId = [[[dictionary objectForKey:@"user"] objectForKey:@"id"] integerValue];
	comment.userName = [[dictionary objectForKey:@"user"] objectForKey:@"name"];
	comment.userPhotoURL = [[dictionary objectForKey:@"user"] objectForKey:@"photo_url"];
	comment.message = [dictionary objectForKey:@"message"];
	comment.createdTime = [Utils dateFromString:[dictionary objectForKey:@"created_time"]];
	comment.updatedTime = [Utils dateFromString:[dictionary objectForKey:@"updated_time"]];
	[comment updateRelativeTime];
	[comment calculateMessageHeight];
	
	return comment;
}

- (void)setMessage:(NSString *)msg
{
	self.message = msg;
	[self calculateMessageHeight];
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:NO];
	self.relativeUpdatedTime = [Utils relativeDateString:self.updatedTime withTime:NO];
}

- (void)calculateMessageHeight
{
	self.messageHeight = [self.message sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake( 263, NSIntegerMax ) lineBreakMode:NSLineBreakByWordWrapping].height;
}

@end
