//
//  DishTileItem.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dish.h"

@protocol DishTileItemDelegate;

@interface DishTileItem : UIView
{
	UIButton *_photoButton;
	UIImageView *_borderView;
}

@property (nonatomic, weak) id<DishTileItemDelegate> delegate;
@property (nonatomic, strong) Dish *dish;

@end


@protocol DishTileItemDelegate

- (void)dishTileItemDidTouchUpInside:(DishTileItem *)dishTileItem;

@end