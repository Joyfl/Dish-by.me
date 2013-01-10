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
	
	_lineView = [[UIImageView alloc] init];
	[self addSubview:_lineView];
	
	_profileImageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_profileImageButton.frame = CGRectMake( 10, 10, 30, 30 );
	[_profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
	[self addSubview:_profileImageButton];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 47, 2, 150, 30 )];
	_nameLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1.0];
	_nameLabel.font = [UIFont boldSystemFontOfSize:14];
	_nameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
	_nameLabel.shadowOffset = CGSizeMake( 0, 1 );
	_nameLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_nameLabel];
	
	_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 260, 8, 50, 30 )];
	_timeLabel.textColor = [Utils colorWithHex:0xAAA4A1 alpha:1.0];
	_timeLabel.font = [UIFont systemFontOfSize:10];
	_timeLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
	_timeLabel.shadowOffset = CGSizeMake( 0, 1 );
	_timeLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_timeLabel];
	
	_messageLabel = [[UILabel alloc] init];
	_messageLabel.textColor = [Utils colorWithHex:0x6B6663 alpha:1.0];
	_messageLabel.backgroundColor = [UIColor clearColor];
	_messageLabel.font = [UIFont systemFontOfSize:13];
	_messageLabel.numberOfLines = 0;
	[self addSubview:_messageLabel];
	
	return self;
}

- (void)setComment:(Comment *)comment atIndexPath:(NSIndexPath *)indexPath
{
	_comment = [comment retain];
	_indexPath = [indexPath retain];
	[self fillContents];
	[self layoutContentView];
	[_profileImageButton setBackgroundImage:_comment.userPhoto forState:UIControlStateNormal];
}

- (void)fillContents
{
	if( _indexPath.row == 0 )
		_lineView.image = [UIImage imageNamed:@"line_dotted.png"];
	else
		_lineView.image = [UIImage imageNamed:@"line.png"];
	
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
	_timeLabel.text = _comment.relativeCreatedTime;
	_messageLabel.text = _comment.message;
}

- (void)layoutContentView
{
	if( _indexPath.row == 0 )
		_lineView.frame = CGRectMake( 8, 0, 304, 2 );
	else
		_lineView.frame = CGRectMake( 0, 0, 320, 2 );
	
	[_timeLabel sizeToFit];
	CGRect frame = _timeLabel.frame;
	frame.origin.x = 310 - _timeLabel.frame.size.width;
	_timeLabel.frame = frame;
	
	_messageLabel.frame = CGRectMake( 47, 25, 263, _comment.messageHeight );
}

@end
