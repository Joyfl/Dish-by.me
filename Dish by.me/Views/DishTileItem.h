//
//  DishTileItem.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dish.h"

@interface DishTileItem : UIButton
{
	Dish *dish;
}

@property (nonatomic, retain) Dish *dish;

- (void)loadThumbnail;
- (void)loadPhoto;

@end
