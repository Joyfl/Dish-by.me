//
//  Setting.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 17..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookSettings : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) BOOL og;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end



@interface NotificationSettings : NSObject

@property (nonatomic, assign) BOOL follow;
@property (nonatomic, assign) BOOL bookmark;
@property (nonatomic, assign) BOOL comment;
@property (nonatomic, assign) BOOL fork;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end



@interface Settings : NSObject

@property (nonatomic, strong) FacebookSettings *facebook;
@property (nonatomic, strong) NotificationSettings *notifications;

+ (id)sharedSettings;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end
