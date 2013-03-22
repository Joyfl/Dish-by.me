//
//  UserListCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 22..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol UserListCellDelegate;

@interface UserListCell : UITableViewCell
{
	User *_user;
	NSIndexPath *_indexPath;
	
	UIImageView *_lineView;
	UIButton *_profileImageButton;
	UILabel *_nameLabel;
	UILabel *_bioLabel;
}

@property (nonatomic, weak) id<UserListCellDelegate> delegate;
@property (nonatomic, readonly) User *user;
@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) UIButton *followButton;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setUser:(User *)user atIndexPath:(NSIndexPath *)indexPath;

@end


@protocol UserListCellDelegate

- (void)userListCell:(UserListCell *)userListCell didTouchProfilePhotoViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)userListCell:(UserListCell *)userListCell didTouchFollowButtonAtIndexPath:(NSIndexPath *)indexPath;
- (void)userListCell:(UserListCell *)userListCell didTouchFollowingButtonAtIndexPath:(NSIndexPath *)indexPath;

@end