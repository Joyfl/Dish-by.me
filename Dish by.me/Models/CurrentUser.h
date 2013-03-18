//
//  UserManager.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CurrentUser : User

@property (nonatomic, assign) BOOL loggedIn;
@property (nonatomic, strong) NSString *accessToken;

+ (CurrentUser *)user;
- (void)updateToDictionary:(NSDictionary *)dictionary;
- (void)save;
- (void)logout;

@end
