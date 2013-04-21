//
//  NotificationCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import "DTCoreText.h"

@interface NotificationCell : UITableViewCell
{
	UIImageView *_thumbnailView;
	DTAttributedLabel *_descriptionLabel;
	UILabel *_timeLabel;
}

@property (nonatomic, readonly) Notification *notification;
@property (nonatomic, readonly) NSIndexPath *indexPath;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setNotification:(Notification *)notification atIndexPath:(NSIndexPath *)indexPath;

@end
