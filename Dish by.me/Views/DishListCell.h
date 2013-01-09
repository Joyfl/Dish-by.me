//
//  DishListCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 6..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@class DishListCell;
@protocol DishListCellDelegate

- (void)dishListCell:(DishListCell *)dishListCell didTouchPhotoViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)dishListCell:(DishListCell *)dishListCell didBookmarkAtIndexPath:(NSIndexPath *)indexPath;
- (void)dishListCell:(DishListCell *)dishListCell didUnbookmarkAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface DishListCell : UITableViewCell
{
	id<DishListCellDelegate> delegate;
	Dish *_dish;
	NSIndexPath *_indexPath;
	
	UIImageView *_photoView;
	UIImageView *_commentIconView;
	UILabel *_commentCountLabel;
	UIImageView *_bookmarkIconView;
	UILabel *_bookmarkCountLabel;
	UILabel *_dishNameLabel;
	UILabel *_userNameLabel;
	UILabel *_bookmarkLabel;
	UIButton *_bookmarkButton;
	UIView *_bookmarkButtonContainer;
}

@property (nonatomic, retain) id<DishListCellDelegate> delegate;
@property (nonatomic, readonly) Dish *dish;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setDish:(Dish *)dish atIndexPath:(NSIndexPath *)indexPath;

@end
