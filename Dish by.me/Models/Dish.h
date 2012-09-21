//
//  Dish.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 20..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dish : NSObject
{
	NSInteger dishId;
	NSInteger userId;
	NSString *name;
	NSString *message;
	NSDate *time;
	NSInteger yumCount;
	NSInteger commentCount;
}

@property (nonatomic, assign) NSInteger dishId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, assign) NSInteger yumCount;
@property (nonatomic, assign) NSInteger commentCount;

@end
