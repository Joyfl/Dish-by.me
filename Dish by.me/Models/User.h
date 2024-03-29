//
//  User.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, assign) NSInteger dishCount;
@property (nonatomic, assign) NSInteger bookmarkCount;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) NSInteger followersCount;
@property (nonatomic, assign) BOOL following;
@property (nonatomic, assign) BOOL activated;

+ (id)userFromDictionary:(NSDictionary *)dictionary;
- (id)dictionary;

@end
