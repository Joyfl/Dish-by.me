//
//  Common.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 20..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#define VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define BUILD [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]

#define WEB_ROOT_URL	@"http://www.dishby.me"
#define API_ROOT_URL	@"http://dev.dishby.me/api"

#define SETTING_KEY_LOGGED_IN		@"loggedIn"
#define SETTING_KEY_ACCESS_TOKEN	@"accessToken"
#define SETTING_KEY_USER_ID			@"userId"
#define SETTING_KEY_USER_NAME		@"userName"

#define DMUserDefaultsKeyCurrentUser @"DMUserDefaultsKeyCurrentUser"

#define showErrorAlert() [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Status Code : %d\nError Code : %d\nMessage : %@", statusCode, errorCode, message] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
