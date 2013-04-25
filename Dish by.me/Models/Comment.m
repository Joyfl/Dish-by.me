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
	comment.commentId = [[dictionary objectForKeyNotNull:@"id"] integerValue];
	comment.userId = [[[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"id"] integerValue];
	comment.userName = [[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"name"];
	comment.userPhotoURL = [[dictionary objectForKeyNotNull:@"user"] objectForKeyNotNull:@"photo_url"];
	comment.message = [dictionary objectForKeyNotNull:@"message"];
	comment.createdTime = [Utils dateFromString:[dictionary objectForKeyNotNull:@"created_time"]];
	comment.updatedTime = [Utils dateFromString:[dictionary objectForKeyNotNull:@"updated_time"]];
	[comment updateRelativeTime];
	[comment calculateMessageHeight];
	
	return comment;
}

- (void)setMessage:(NSString *)msg
{
	_message = msg;
	[self calculateMessageHeight];
}

- (void)updateRelativeTime
{
	self.relativeCreatedTime = [Utils relativeDateString:self.createdTime withTime:YES];
	self.relativeUpdatedTime = [Utils relativeDateString:self.updatedTime withTime:YES];
}

- (void)calculateMessageHeight
{
	CGFloat height = [self.message sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake( 263, NSIntegerMax ) lineBreakMode:NSLineBreakByWordWrapping].height;
	if( height < 16 ) height = 16;
	self.messageHeight = height;
}

@end
