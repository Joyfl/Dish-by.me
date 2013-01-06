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
#import "JLHTTPLoader.h"

@implementation CommentCell

- (id)initWithResueIdentifier:(NSString *)resueIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_profileImageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_profileImageButton.frame = CGRectMake( 10, 10, 30, 30 );
	[_profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
	[self addSubview:_profileImageButton];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50, 2, 270, 30 )];
	_nameLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1.0];
	_nameLabel.font = [UIFont boldSystemFontOfSize:14];
	_nameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
	_nameLabel.shadowOffset = CGSizeMake( 0, 1 );
	_nameLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_nameLabel];
	
	_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 260, 0, 50, 30 )];
	_timeLabel.textColor = [Utils colorWithHex:0xAAA4A1 alpha:1.0];
	_timeLabel.font = [UIFont systemFontOfSize:10];
	_timeLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
	_timeLabel.shadowOffset = CGSizeMake( 0, 1 );
	_timeLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_timeLabel];
	
	_messageView = [[UITextView alloc] initWithFrame:CGRectMake( 43, 16, 270, 30 )];
	_messageView.textColor = [Utils colorWithHex:0x6B6663 alpha:1.0];
	_messageView.backgroundColor = [UIColor clearColor];
	_messageView.font = [UIFont systemFontOfSize:13];
	_messageView.editable = NO;
	_messageView.scrollEnabled = NO;
	[self addSubview:_messageView];
	
	return self;
}

- (void)setComment:(Comment *)comment atIndexPath:(NSIndexPath *)indexPath
{
	_comment = [comment retain];
	_indexPath = [indexPath retain];
	[self fillContents];
	
	[_profileImageButton setBackgroundImage:_comment.userPhoto forState:UIControlStateNormal];
}

- (void)fillContents
{
	if( _comment.userPhoto )
	{
		[_profileImageButton setBackgroundImage:_comment.userPhoto forState:UIControlStateNormal];
	}
	else
	{
		[_profileImageButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
		[JLHTTPLoader loadAsyncFromURL:_comment.userPhotoURL withObject:_indexPath completion:^(id indexPath, NSData *data)
		{
			_comment.userPhoto = [UIImage imageWithData:data];
			
			if( [_indexPath isEqual:indexPath] )
				[_profileImageButton setBackgroundImage:_comment.userPhoto forState:UIControlStateNormal];
		}];
	}
	
	_nameLabel.text = _comment.userName;
#warning 임시 날짜
	_timeLabel.text = @"10분 전에";
#warning message가 길어질 경우 예외처리 필요
	_messageView.text = _comment.message;
}

- (void)layoutContentView
{
	[_messageView sizeToFit];
}

- (void)loadProfileImage
{
	dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{
		NSString *rootURL = WEB_ROOT_URL;
		NSLog( @"%d", _comment.userId );
		NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/thumbnail/profile/%d.jpg", rootURL, _comment.userId]]];
		if( data == nil )
			return;
		
		dispatch_async( dispatch_get_main_queue(), ^{
			_comment.userPhoto = [UIImage imageWithData:data];
			[_profileImageButton setBackgroundImage:_comment.userPhoto forState:UIControlStateNormal];
		} );
		
		[data release];
	});
}

@end
