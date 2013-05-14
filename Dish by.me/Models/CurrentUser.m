//
//  UserManager.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "CurrentUser.h"
#import "AppDelegate.h"

@implementation CurrentUser

+ (CurrentUser *)user
{
	static CurrentUser *user = nil;
	if( !user )
	{
		user = [[CurrentUser alloc] init];
	}
	return user;
}

- (id)init
{
	self = [super init];
	
	NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:DMUserDefaultsKeyCurrentUser];
	if( userInfo )
	{
		[self updateToDictionary:userInfo];
		self.loggedIn = [[userInfo objectForKeyNotNull:@"logged_in"] boolValue];
		self.email = [userInfo objectForKeyNotNull:@"email"];
		self.accessToken = [userInfo objectForKeyNotNull:@"access_token"];
	}
	
	return self;
}

- (void)updateToDictionary:(NSDictionary *)dictionary
{
	self.userId = [[dictionary objectForKeyNotNull:@"id"] integerValue];
	self.name = [dictionary objectForKeyNotNull:@"name"];
	self.photoURL = [dictionary objectForKeyNotNull:@"photo_url"];
	self.thumbnailURL = [dictionary objectForKeyNotNull:@"thumbnail_url"];
	self.bio = [dictionary objectForKeyNotNull:@"bio"];
	self.dishCount = [[dictionary objectForKeyNotNull:@"dish_count"] integerValue];
	self.bookmarkCount = [[dictionary objectForKeyNotNull:@"bookmark_count"] integerValue];
	self.followingCount = [[dictionary objectForKeyNotNull:@"following_count"] integerValue];
	self.followersCount = [[dictionary objectForKeyNotNull:@"followers_count"] integerValue];
}

- (void)setLoggedIn:(BOOL)loggedIn
{
	_loggedIn = loggedIn;
	[self save];
}

- (void)setEmail:(NSString *)email
{
	_email = email;
	[self save];
}

- (void)setAccessToken:(NSString *)accessToken
{
	_accessToken = accessToken;
	[self save];
}

- (void)save
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[self dictionary]];
	[userInfo setObject:[NSNumber numberWithBool:self.loggedIn] forKey:@"logged_in"];
	if( self.email ) [userInfo setObject:self.email forKey:@"email"];
	if( self.accessToken ) [userInfo setObject:self.accessToken forKey:@"access_token"];
	
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:DMUserDefaultsKeyCurrentUser];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logout
{
	NSString *deviceToken = [(AppDelegate *)[UIApplication sharedApplication].delegate deviceToken];
	if( deviceToken )
	{
		[[DMAPILoader sharedLoader] api:@"/device" method:@"DELETE" parameters:@{@"device_token": deviceToken} success:^(id response) {
			
			JLLog( @"Deleted device." );
			
		} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
			
		}];
	}
	
	self.loggedIn = NO;
	self.email = nil;
	self.accessToken = nil;
	self.userId = 0;
	self.name = nil;
	self.photoURL = nil;
	self.thumbnailURL = nil;
	self.bio = nil;
	self.dishCount = 0;
	self.bookmarkCount = 0;
	self.followingCount = 0;
	self.followersCount = 0;
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:DMUserDefaultsKeyCurrentUser];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
