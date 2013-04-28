//
//  AppDelegate.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "AppDelegate.h"
#import "DMNavigationController.h"
#import "DishListViewController.h"
#import "DishDetailViewController.h"
#import "SearchViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "WritingViewController.h"
#import "CurrentUser.h"
#import "User.h"
#import "GAI.h"
#import <FacebookSDK/FacebookSDK.h>
#import "HTBlock.h"
#import "Notification.h"
#import "NotificationListViewController.h"
#import "CoverView.h"
#import "Settings.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	JLLog( @"Application launching option : %@", launchOptions );
	
	[GAI sharedInstance].trackUncaughtExceptions = YES;
	[GAI sharedInstance].dispatchInterval = 20;
	[[GAI sharedInstance] trackerWithTrackingId:@"UA-38348585-3"];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
	
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.delegate = self;
	self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tab_bar_bg.png"];
	self.tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tab_bar_bg_selected.png"];
	self.window.rootViewController = self.tabBarController;
	
	self.notifications = [NSMutableArray array];
	
	self.coverView = [[CoverView alloc] init];
	[self.window addSubview:self.coverView];
	
	if( [CurrentUser user].loggedIn )
	{
		JLLog( @"[TRY] Load settings" );
		
		[[DMAPILoader sharedLoader] api:@"/settings" method:@"GET" parameters:nil success:^(id response) {
			
			JLLog( @"[SUCCESS] Load settings : %@", response );
			
			[[Settings sharedSettings] updateFromDictionary:response];
			
			[self buildViewControllers];
			[self.profileViewController loadUserId:[CurrentUser user].userId];
			[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
			[self.coverView open];
			
		} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
			
			JLLog( @"[FAILED] Load settings." );
			
			// Invalid AccessToken
			if( errorCode == 4000 )
			{
				[self buildViewControllers];
				[self presentAuthViewControllerWithClosingAnimation:NO];
			}
		}];
	}
	else
	{
		JLLog( @"Not logged in." );
		
		[self buildViewControllers];
		[self presentAuthViewControllerWithClosingAnimation:NO];
	}
	
	[self handleRemoteNotificationFromLaunchOptions:launchOptions];
	
    return YES;
}

- (void)buildViewControllers
{
	self.dishListViewController = [[DishListViewController alloc] init];
	DMNavigationController *dishNavigationController = [[DMNavigationController alloc] initWithRootViewController:self.dishListViewController];
	dishNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_dish.png"];
	dishNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	SearchViewController *searchViewController = [[SearchViewController alloc] init];
	DMNavigationController *searchNavigationController = [[DMNavigationController alloc] initWithRootViewController:searchViewController];
	searchNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_search.png"];
	searchNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	self.profileViewController = [[ProfileViewController alloc] init];
	DMNavigationController *profileNavigationController = [[DMNavigationController alloc] initWithRootViewController:self.profileViewController];
	self.profileViewController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_me.png"];
	self.profileViewController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	self.settingsViewController = [[SettingsViewController alloc] init];
	DMNavigationController *settingsNavigationController = [[DMNavigationController alloc] initWithRootViewController:self.settingsViewController];
	settingsNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_settings.png"];
	settingsNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:
											 dishNavigationController,
											 searchNavigationController,
											 [[UIViewController alloc] init],
											 profileNavigationController,
											 settingsNavigationController,
											 nil];
	
	UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cameraButton.frame = CGRectMake( 128, -1, 64, 50 );
	[cameraButton setImage:[UIImage imageNamed:@"tab_camera.png"] forState:UIControlStateNormal];
	[cameraButton setImage:[UIImage imageNamed:@"tab_camera_highlighted.png"] forState:UIControlStateHighlighted];
	[cameraButton addTarget:self action:@selector(cameraButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.tabBarController.tabBar addSubview:cameraButton];
}

- (void)handleRemoteNotificationFromLaunchOptions:(NSDictionary *)launchOptions
{
	NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if( remoteNotification )
	{
		NSURL *url = [NSURL URLWithString:[remoteNotification objectForKey:@"url"]];
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	self.deviceToken = [[deviceToken.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
	JLLog( @"deviceToken : %@", self.deviceToken );
	
	NSDictionary *params = @{ @"device_token": self.deviceToken, @"device_os": @"iOS" };
	[[DMAPILoader sharedLoader] api:@"/device" method:@"POST" parameters:params success:^(id response) {
		
		JLLog( @"Registered deviceToken" );
		[self updateNotificationsSuccess:nil failure:nil];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		
	}];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	JLLog( @"Remote Notification 등록 실패 : %@", error );
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	JLLog( @"Received Remote Notification : %@", userInfo );
	JLLog( @"applicationState : %d", application.applicationState );
	
	// 앱이 active 상태일 경우
	if( application.applicationState == UIApplicationStateActive )
	{
		// 현재 NotificationListViewController를 보고 있었다면 updateNotifications
		if( [[self.profileViewController.navigationController.topViewController.class description] isEqualToString:@"NotificationListViewController"] )
		{
			[(NotificationListViewController *)self.profileViewController.navigationController.topViewController updateNotifications];
		}
		
		// 그렇지 않으면 뱃지만 올리기
		else
		{
			self.profileViewController.notificationsCount = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
		}
	}
	
	// 앱이 background에 있을 때 Remote Notification을 타고 들어왔을 경우
	else
	{
		NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"url"]];
		[application openURL:url];
		
		// Notification을 타고 들어온 것 하나를 제외하고 뱃지 설정
		self.profileViewController.notificationsCount = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue] - 1;
	}
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if( [url.absoluteString hasPrefix:@"dishbyme://"] )
	{
		JLLog( @"Launch from URL : %@ (source : %@)", url, sourceApplication );
		
		NSArray *components = [[url.absoluteString substringFromIndex:11] componentsSeparatedByString:@"?"];
		NSString *method = [components objectAtIndex:0];
		NSMutableDictionary *parameters = nil;
		if( components.count > 1 )
		{
			parameters = [NSMutableDictionary dictionary];
			
			NSArray *params = [[components objectAtIndex:1] componentsSeparatedByString:@"&"];
			for( NSString *param in params )
			{
				NSArray *keyAndObject = [param componentsSeparatedByString:@"="];
				NSString *key = [keyAndObject objectAtIndex:0];
				NSString *object = [keyAndObject objectAtIndex:1];
				[parameters setObject:object forKey:key];
			}
		}
		
		JLLog( @"method : %@", method );
		JLLog( @"parameters : %@", parameters );
		
		if( [method isEqualToString:@"user"] )
		{
			NSInteger userId = [[parameters objectForKey:@"user_id"] integerValue];
			if( userId )
			{
				ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
				[profileViewController loadUserId:userId];
				[(UINavigationController *)self.tabBarController.selectedViewController pushViewController:profileViewController animated:YES];
				
				if( self.authViewController )
				{
					[self.authViewController dismissViewControllerAnimated:YES completion:nil];
				}
			}
		}
		
		else if( [method isEqualToString:@"dish"] )
		{
			NSInteger dishId = [[parameters objectForKey:@"dish_id"] integerValue];
			if( dishId )
			{
				DishDetailViewController *detailViewController = [[DishDetailViewController alloc] initWithDishId:dishId dishName:nil];
				[(UINavigationController *)self.tabBarController.selectedViewController pushViewController:detailViewController animated:YES];
				
				if( self.authViewController )
				{
					[self.authViewController dismissViewControllerAnimated:YES completion:nil];
				}
			}
		}
		
		return YES;
	}
	
	return [[FBSession activeSession] handleOpenURL:url];
}

#pragma mark -
#pragma mark UITabBarDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	[(DMNavigationController *)viewController popToRootViewControllerAnimated:NO];
	
	if( ![CurrentUser user].loggedIn )
	{
		if( [(DMNavigationController *)viewController rootViewController] == self.profileViewController )
		{
			[self presentNeedLoginActionSheetWithTitle:NSLocalizedString( @"MESSAGE_NEED_ACCOUNT_TO_VIEW_PROFILE", nil )];
			return NO;
		}
		else if( [(DMNavigationController *)viewController rootViewController] == self.settingsViewController )
		{
			[self presentNeedLoginActionSheetWithTitle:NSLocalizedString( @"MESSAGE_NEED_ACCOUNT_TO_SET_SETTINGS", nil )];
			return NO;
		}
	}
	
	return YES;
}


#pragma mark -
#pragma mark Selectors

- (void)cameraButtonDidTouchUpInside
{
	if( [CurrentUser user].loggedIn )
	{
		WritingViewController *writingViewController = [[WritingViewController alloc] initWithNewDish];
		DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:writingViewController];
		[self.tabBarController presentViewController:navController animated:YES completion:nil];
	}
	else
	{
		[self presentNeedLoginActionSheetWithTitle:NSLocalizedString( @"MESSAGE_NEED_ACCOUNT_TO_UPLOAD", nil )];
	}
}

- (void)presentNeedLoginActionSheetWithTitle:(NSString *)title
{
	[[[UIActionSheet alloc] initWithTitle:title cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString( @"LOGIN_OR_SIGNUP", nil )] dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
		
		// 로그인
		if( buttonIndex == 0 )
		{
			[self presentAuthViewControllerWithClosingAnimation:YES];
		}
		
	}] showInView:self.window];
}


#pragma mark -

- (void)presentAuthViewControllerWithClosingAnimation:(BOOL)withClosingAnimation
{
	self.authViewController = [[AuthViewController alloc] init];
	self.authViewController.delegate = self;
	DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:self.authViewController];
	navController.navigationBarHidden = YES;
	
	if( withClosingAnimation )
	{
		[self.coverView closeCompletion:^(CoverView *coverView) {
			[self.tabBarController presentViewController:navController animated:NO completion:nil];
			[self.coverView openAfterDelay:0.25];
		}];
	}
	else
	{
		[self.tabBarController presentViewController:navController animated:NO completion:nil];
		[self.coverView open];
	}
}

- (void)authViewControllerDidSucceedLogin:(AuthViewController *)authViewController
{
	JLLog( @"loginViewControllerDidSucceedLogin (userId : %d)", [CurrentUser user].userId );
	
	[[DMAPILoader sharedLoader] api:@"/settings" method:@"GET" parameters:nil success:^(id response) {
		
		JLLog( @"[SUCCESS] Load settings : %@", response );
		
		[[Settings sharedSettings] updateFromDictionary:response];
		
		[self.dishListViewController updateDishes];
		[self.profileViewController loadUserId:[CurrentUser user].userId];
		[self updateNotificationsSuccess:nil failure:nil];
		[self.authViewController dismissViewControllerAnimated:YES completion:nil];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		
		JLLog( @"[FAILED] Load settings." );
		
		// Invalid AccessToken
		if( errorCode == 4000 )
		{
			[self buildViewControllers];
			[self presentAuthViewControllerWithClosingAnimation:NO];
		}
	}];
}


#pragma mark -

- (void)updateNotificationsSuccess:(void (^)(void))success failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	[[DMAPILoader sharedLoader] api:@"/notifications" method:@"GET" parameters:nil success:^(id response) {
		
		self.profileViewController.notificationsCount = [[response objectForKey:@"badge_count"] integerValue];
		
		[self.notifications removeAllObjects];
		
		NSArray *notifications = [response objectForKey:@"data"];
		if( notifications.count == 0 )
		{
			self.isLastNotificationLoaded = YES;
		}
		
		for( NSDictionary *dictionary in notifications )
		{
			Notification *notification = [Notification notificationFromDictionary:dictionary];
			[self.notifications addObject:notification];
		}
		
		if( success )
			success();
		
	} failure:failure];
}

- (void)loadMoreNotificationsSuccess:(void (^)(void))success failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	[[DMAPILoader sharedLoader] api:@"/notifications" method:@"GET" parameters:@{@"offset": [NSString stringWithFormat:@"%d", self.notifications.count]} success:^(id response) {
		
		self.profileViewController.notificationsCount = [[response objectForKey:@"badge_count"] integerValue];
		
		NSArray *notifications = [response objectForKey:@"data"];
		if( notifications.count == 0 )
		{
			self.isLastNotificationLoaded = YES;
		}
		
		for( NSDictionary *dictionary in notifications )
		{
			Notification *notification = [Notification notificationFromDictionary:dictionary];
			[self.notifications addObject:notification];
		}
		
		if( success )
			success();
		
	} failure:failure];
}

@end
