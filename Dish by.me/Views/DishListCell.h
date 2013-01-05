//
//  DishListCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 6..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@interface DishListCell : UITableViewCell
{
	Dish *_dish;
	
	UIImageView *_photoView;
	UILabel *_commentCountLabel;
	UILabel *_bookmarkCountLabel;
	UILabel *_dishNameLabel;
	UILabel *_userNameLabel;
	UIButton *_bookmarkButton;
}

@property (nonatomic, retain) Dish *dish;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
