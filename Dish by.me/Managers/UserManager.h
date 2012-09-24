//
//  UserManager.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

+ (BOOL)loggedIn;
+ (NSString *)accessToken;
+ (NSInteger)userId;
+ (NSNumber *)userIdNumber;
+ (NSString *)userName;
+ (NSString *)email;
+ (NSString *)password;
+ (void)logout;

@end
