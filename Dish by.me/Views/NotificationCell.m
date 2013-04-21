//
//  NotificationCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "NotificationCell.h"
#import "DTCoreText.h"

@implementation NotificationCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 75 )];
	self.selectedBackgroundView.backgroundColor = [UIColor colorWithHex:0xE6E2DB alpha:1];
	
	_thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 75, 75 )];
	_thumbnailView.image = [UIImage imageNamed:@"placeholder.png"];
	[self.contentView addSubview:_thumbnailView];
	
	_descriptionLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake( 84, 9, 227, 70 )];
	_descriptionLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:_descriptionLabel];
	
	_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 84, 50, 227, 15 )];
	_timeLabel.backgroundColor = [UIColor clearColor];
	_timeLabel.font = [UIFont systemFontOfSize:10];
	_timeLabel.textColor = [UIColor colorWithHex:0xAAA5A3 alpha:1];
	[self.contentView addSubview:_timeLabel];
	
	UIImageView *profileLine = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 75, 2 )];
	profileLine.image = [UIImage imageNamed:@"line_notification_profile.png"];
	[self.contentView addSubview:profileLine];
	
	UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 75, 0, 244, 2 )];
	lineView.image = [UIImage imageNamed:@"line_notification.png"];
	[self.contentView addSubview:lineView];
	
	UIImageView *verticalLine = [[UIImageView alloc] initWithFrame:CGRectMake( 74, 0, 2, 75 )];
	verticalLine.image = [UIImage imageNamed:@"line_notification_vertical.png"];
	[self.contentView addSubview:verticalLine];
	
	_bottomLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 75, 320, 2 )];
	_bottomLineView.image = [UIImage imageNamed:@"line_notification.png"];
	_bottomLineView.hidden = YES;
	[self.contentView addSubview:_bottomLineView];
	
	return self;
}

- (void)setNotification:(Notification *)notification atIndexPath:(NSIndexPath *)indexPath
{
	_notification = notification;
	_indexPath = indexPath;
	
	if( notification.photo )
	{
		_thumbnailView.image = notification.photo;
	}
	else
	{
		[DMAPILoader loadImageFromURLString:notification.photoURL context:_indexPath success:^(UIImage *image, id context) {
			notification.photo = image;
			if( [_indexPath isEqual:context] )
			{
				_thumbnailView.image = notification.photo;
			}
		}];
	}
	
	_descriptionLabel.attributedString = notification.attributedDescription;
	_timeLabel.text = notification.relativeCreatedTime;
	[_timeLabel sizeToFit];
	
	self.contentView.backgroundColor = notification.read ? [UIColor clearColor] : [UIColor colorWithHex:0xEEDCC6 alpha:1];
}

@end
