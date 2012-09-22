//
//  CommentCell.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 22..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"
#import "Const.h"
#import "Utils.h"

@implementation CommentCell

- (id)initWithComment:(Comment *)_comment
{
	self = [super init];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	comment = _comment;
	
	profileImageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	profileImageButton.frame = CGRectMake( 10, 10, 30, 30 );
	[profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
	[self addSubview:profileImageButton];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50, 2, 270, 30 )];
	nameLabel.text = comment.name;
	nameLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1.0];
	nameLabel.font = [UIFont boldSystemFontOfSize:14];
	nameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
	nameLabel.shadowOffset = CGSizeMake( 0, 1 );
	nameLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:nameLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 260, 0, 50, 30 )];
#warning 임시 날짜
	timeLabel.text = @"10분 전에";
	timeLabel.textColor = [Utils colorWithHex:0xAAA4A1 alpha:1.0];
	timeLabel.font = [UIFont systemFontOfSize:10];
	timeLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
	timeLabel.shadowOffset = CGSizeMake( 0, 1 );
	timeLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:timeLabel];
	
	UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake( 43, 16, 270, 30 )];
	messageView.text = comment.message;
	messageView.textColor = [Utils colorWithHex:0x6B6663 alpha:1.0];
	messageView.backgroundColor = [UIColor clearColor];
	messageView.font = [UIFont systemFontOfSize:13];
	messageView.editable = NO;
	messageView.scrollEnabled = NO;
	[messageView sizeToFit];
	[self addSubview:messageView];
	
	[self loadProfileImage];
	
	return self;
}

- (void)loadProfileImage
{
	dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{
		NSString *rootURL = WEB_ROOT_URL;
		NSLog( @"%d", comment.userId );
		NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/thumbnail/profile/%d.jpg", rootURL, comment.userId]]];
		if( data == nil )
			return;
		
		dispatch_async( dispatch_get_main_queue(), ^{
			[profileImageButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
		} );
		
		[data release];
	});
}

@end
