//
//  NotificationCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	return self;
}

- (void)setNotification:(Notification *)notification atIndexPath:(NSIndexPath *)indexPath
{
	_notification = notification;
	_indexPath = indexPath;
	
	if( notification.photo )
	{
		self.imageView.image = notification.photo;
	}
	else
	{
		[DMAPILoader loadImageFromURLString:notification.photoURL context:_indexPath success:^(UIImage *image, id context) {
			notification.photo = image;
			if( [_indexPath isEqual:context] )
			{
				self.imageView.image = notification.photo;
			}
		}];
	}
	
	self.textLabel.text = notification.description;
	self.detailTextLabel.text = @"2분 전";
}

@end
