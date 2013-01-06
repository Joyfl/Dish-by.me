//
//  User.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
	NSInteger userId;
	NSString *name;
	NSString *photoURL;
	UIImage *photo;
	NSString *thumbnailURL;
	UIImage *thumbnail;
	NSString *bio;
	NSInteger dishCount;
	NSInteger bookmarkCount;
	NSInteger followingCount;
	NSInteger followersCount;
}

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *photoURL;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, assign) NSInteger dishCount;
@property (nonatomic, assign) NSInteger bookmarkCount;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) NSInteger followersCount;

+ (User *)userFromDictionary:(NSDictionary *)dictionary;

@end
