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
	NSString *dishName;
	NSInteger userId;
	NSString *userName;
	NSString *message;
	NSInteger forkedFrom;
	NSString *forkedFromName;
	NSInteger forkCount;
	NSDate *time;
	BOOL hasRecipe;
	NSString *recipe;
	NSInteger yumCount;
	NSInteger commentCount;
	UIImage *thumbnail;
	UIImage *photo;
}

@property (nonatomic, assign) NSInteger dishId;
@property (nonatomic, retain) NSString *dishName;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) NSInteger forkedFrom;
@property (nonatomic, retain) NSString *forkedFromName;
@property (nonatomic, assign) NSInteger forkCount;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, assign) BOOL hasRecipe;
@property (nonatomic, retain) NSString *recipe;
@property (nonatomic, assign) NSInteger yumCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UIImage *photo;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
