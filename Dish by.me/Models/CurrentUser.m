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
		self.loggedIn = [[userInfo objectForKey:@"logged_in"] boolValue];
		self.email = [userInfo objectForKey:@"email"];
		self.accessToken = [userInfo objectForKey:@"access_token"];
	}
	
	return self;
}

- (void)updateToDictionary:(NSDictionary *)dictionary
{
	self.userId = [[dictionary objectForKey:@"id"] integerValue];
	self.name = [dictionary objectForKey:@"name"];
	self.photoURL = [dictionary objectForKey:@"photo_url"];
	self.thumbnailURL = [dictionary objectForKey:@"thumbnail_url"];
	self.bio = [dictionary objectForKey:@"bio"];
	self.dishCount = [[dictionary objectForKey:@"dish_count"] integerValue];
	self.bookmarkCount = [[dictionary objectForKey:@"bookmark_count"] integerValue];
	self.followingCount = [[dictionary objectForKey:@"following_count"] integerValue];
	self.followersCount = [[dictionary objectForKey:@"followers_count"] integerValue];
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
	self.photo = nil;
	self.thumbnailURL = nil;
	self.thumbnail = nil;
	self.bio = nil;
	self.dishCount = 0;
	self.bookmarkCount = 0;
	self.followingCount = 0;
	self.followersCount = 0;
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:DMUserDefaultsKeyCurrentUser];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
