//
//  UserManager.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject
{
	UIImage *_userPhoto;
}

@property (nonatomic, assign) BOOL loggedIn;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) UIImage *userPhoto;

+ (UserManager *)manager;
- (void)logout;

@end
