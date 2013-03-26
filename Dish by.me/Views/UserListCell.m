//
//  UserListCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 22..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "UserListCell.h"
#import "CurrentUser.h"
#import "UIButton+ActivityIndicatorView.h"

@implementation UserListCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_lineView = [[UIImageView alloc] init];
	[self.contentView addSubview:_lineView];
	
	_profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_profileImageButton.frame = CGRectMake( 10, 10, 33, 33 );
	_profileImageButton.userInteractionEnabled = NO;
	[_profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
	[self.contentView addSubview:_profileImageButton];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 170, 20 )];
	_nameLabel.textColor = [UIColor colorWithHex:0x2E2C2A alpha:1.0];
	_nameLabel.font = [UIFont boldSystemFontOfSize:14];
	_nameLabel.shadowColor = [UIColor whiteColor];
	_nameLabel.shadowOffset = CGSizeMake( 0, 1 );
	_nameLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:_nameLabel];
	
	_bioLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 170, 20 )];
	_bioLabel.textColor = [UIColor colorWithHex:0x514F4D alpha:1.0];
	_bioLabel.backgroundColor = [UIColor clearColor];
	_bioLabel.font = [UIFont boldSystemFontOfSize:12];
	_bioLabel.shadowColor = [UIColor whiteColor];
	_bioLabel.shadowOffset = CGSizeMake( 0, 1 );
	[self.contentView addSubview:_bioLabel];
	
	_followButton = [[UIButton alloc] initWithFrame:CGRectMake( 235, 9, 75, 30 )];
	_followButton.titleLabel.font = [UIFont systemFontOfSize:12];
	_followButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_followButton setTitleColor:[UIColor colorWithHex:0x514F4D alpha:1] forState:UIControlStateNormal];
	[_followButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	_followButton.imageEdgeInsets = UIEdgeInsetsMake( 0, 0, 0, 10 );
	[_followButton setBackgroundImage:[UIImage imageNamed:@"button_follow.png"] forState:UIControlStateNormal];
	[_followButton setBackgroundImage:[UIImage imageNamed:@"button_follow_selected.png"] forState:UIControlStateHighlighted];
	[_followButton addTarget:self action:@selector(followButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	_followButton.adjustsImageWhenHighlighted = NO;
	_followButton.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self.contentView addSubview:_followButton];
	
	return self;
}

- (void)setUser:(User *)user atIndexPath:(NSIndexPath *)indexPath
{
	_user = user;
	_indexPath = indexPath;
	
	[self fillContents];
	[self layoutContentView];
}

- (void)fillContents
{
	if( _user.thumbnail )
	{
		[_profileImageButton setBackgroundImage:_user.thumbnail forState:UIControlStateNormal];
	}
	else
	{
		[_profileImageButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
		[DMAPILoader loadImageFromURL:[NSURL URLWithString:_user.thumbnailURL] context:_indexPath success:^(UIImage *image, NSIndexPath *indexPath) {
			_user.thumbnail = image;
			
			if( [_indexPath isEqual:indexPath] )
				[_profileImageButton setBackgroundImage:_user.thumbnail forState:UIControlStateNormal];
		}];
	}
	_nameLabel.text = _user.name;
	_bioLabel.text = _user.bio;
	
	if( _user.userId == [CurrentUser user].userId )
	{
		_followButton.hidden = YES;
	}
	else
	{
		_followButton.hidden = NO;
		
		if( !_user.following )
		{
			[_followButton setImage:nil forState:UIControlStateNormal];
			[_followButton setTitle:NSLocalizedString( @"FOLLOW", nil ) forState:UIControlStateNormal];
		}
		else
		{
			[_followButton setImage:[UIImage imageNamed:@"icon_checkmark.png"] forState:UIControlStateNormal];
			[_followButton setTitle:NSLocalizedString( @"FOLLOWING", nil ) forState:UIControlStateNormal];
		}
	}
}

- (void)layoutContentView
{
	[_nameLabel sizeToFit];
	_nameLabel.frame = CGRectMake( 53, 8, 170, _nameLabel.frame.size.height );
	
	[_bioLabel sizeToFit];
	_bioLabel.frame = CGRectMake( 53, 27, 170, _nameLabel.frame.size.height );
}

- (void)followButtonDidTouchUpInside
{
	_followButton.showsActivityIndicatorView = YES;
	
	if( !_user.following )
	{
		[self.delegate userListCell:self didTouchFollowButtonAtIndexPath:_indexPath];
	}
	else
	{
		[self.delegate userListCell:self didTouchFollowingButtonAtIndexPath:_indexPath];
	}
}

@end
