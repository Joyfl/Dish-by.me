//
//  Dish.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 20..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dish : NSObject

@property (nonatomic, assign) NSInteger dishId;
@property (nonatomic, strong) NSString *dishName;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPhotoURL;
@property (nonatomic, strong) UIImage *userPhoto;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *recipe;
@property (nonatomic, assign) NSInteger photoWidth;
@property (nonatomic, assign) NSInteger photoHeight;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) UIImage *croppedThumbnail;
@property (nonatomic, assign) NSInteger forkedFromId;
@property (nonatomic, strong) NSString *forkedFromName;
@property (nonatomic, assign) NSInteger forkCount;
@property (nonatomic, assign) NSInteger bookmarkCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) BOOL bookmarked;
@property (nonatomic, strong) NSDate *createdTime;
@property (nonatomic, strong) NSString *relativeCreatedTime;
@property (nonatomic, strong) NSDate *updatedTime;
@property (nonatomic, strong) NSString *relativeUpdatedTime;

+ (id)dishFromDictionary:(NSDictionary *)dictionary;
- (void)updateRelativeTime;

@end
