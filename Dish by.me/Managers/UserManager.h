//
//  UserManager.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface UserManager : NSObject
{
	BOOL loggedIn;
	NSString *_accessToken;
	User *user;
}

@property (nonatomic, assign) BOOL loggedIn;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) User *user;

+ (UserManager *)manager;

@end
