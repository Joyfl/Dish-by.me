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
	NSString *userPhotoURL;
	UIImage *userPhoto;
	NSString *description;
	NSString *recipe;
	NSString *photoURL;
	UIImage *photo;
	NSString *thumbnailURL;
	UIImage *thumbnail;
	NSInteger forkedFromId;
	NSString *forkedFromName;
	NSInteger forkCount;
	NSInteger bookmarkCount;
	NSInteger commentCount;
	BOOL bookmarked;
	NSDate *createdTime;
	NSString *relativeCreatedTime;
	NSDate *updatedTime;
	NSString *relativeUpdatedTime;
}

@property (nonatomic, assign) NSInteger dishId;
@property (nonatomic, retain) NSString *dishName;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userPhotoURL;
@property (nonatomic, retain) UIImage *userPhoto;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *recipe;
@property (nonatomic, retain) NSString *photoURL;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, assign) NSInteger forkedFromId;
@property (nonatomic, retain) NSString *forkedFromName;
@property (nonatomic, assign) NSInteger forkCount;
@property (nonatomic, assign) NSInteger bookmarkCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) BOOL bookmarked;
@property (nonatomic, retain) NSDate *createdTime;
@property (nonatomic, retain) NSString *relativeCreatedTime;
@property (nonatomic, retain) NSDate *updatedTime;
@property (nonatomic, retain) NSString *relativeUpdatedTime;

+ (id)dishFromDictionary:(NSDictionary *)dictionary;
- (void)updateRelativeTime;

@end
