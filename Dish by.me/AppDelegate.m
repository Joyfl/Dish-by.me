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

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[GAI sharedInstance].trackUncaughtExceptions = YES;
	[GAI sharedInstance].dispatchInterval = 20;
//	[GAI sharedInstance].debug = YES;
	[[GAI sharedInstance] trackerWithTrackingId:@"UA-38348585-3"];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.delegate = self;
	self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tab_bar_bg.png"];
	self.tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tab_bar_bg_selected.png"];
	
	self.dishListViewController = [[DishListViewController alloc] init];
	DMNavigationController *dishNavigationController = [[DMNavigationController alloc] initWithRootViewController:self.dishListViewController];
//	dishNavigationController.title = NSLocalizedString( @"DISHES", @"" );
	dishNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_dish.png"];
	dishNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	SearchViewController *searchViewController = [[SearchViewController alloc] init];
	DMNavigationController *searchNavigationController = [[DMNavigationController alloc] initWithRootViewController:searchViewController];
	searchNavigationController.navigationBar.shadowImage = [[UIImage alloc] init];
	[searchNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_no_border.png"] forBarMetrics:UIBarMetricsDefault];
//	searchNavigationController.title = NSLocalizedString( @"SEARCH", @"" );
	searchNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_search.png"];
	searchNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	self.profileViewController = [[ProfileViewController alloc] init];
	DMNavigationController *profileNavigationController = [[DMNavigationController alloc] initWithRootViewController:self.profileViewController];
//	meNavigationController.title = NSLocalizedString( @"ME", @"" );
	self.profileViewController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_me.png"];
	self.profileViewController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	self.settingsViewController = [[SettingsViewController alloc] init];
	DMNavigationController *settingsNavigationController = [[DMNavigationController alloc] initWithRootViewController:self.settingsViewController];
//	settingsNavigationController.title = NSLocalizedString( @"SETTINGS", @"" );
	settingsNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_settings.png"];
	settingsNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:
										dishNavigationController,
										searchNavigationController,
										[[UIViewController alloc] init],
										profileNavigationController,
										settingsNavigationController,
										nil];
	self.window.rootViewController = self.tabBarController;
	
	UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cameraButton.frame = CGRectMake( 128, -1, 64, 50 );
	[cameraButton setImage:[UIImage imageNamed:@"tab_camera.png"] forState:UIControlStateNormal];
	[cameraButton setImage:[UIImage imageNamed:@"tab_camera_highlighted.png"] forState:UIControlStateHighlighted];
	[cameraButton addTarget:self action:@selector(cameraButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.tabBarController.tabBar addSubview:cameraButton];
	
	if( [CurrentUser user].loggedIn )
	{
		[self.profileViewController loadUserId:[CurrentUser user].userId];
	}
	else
	{
		[AuthViewController presentAuthViewControllerWithoutClosingCoverFromViewController:self.tabBarController delegate:self];
	}
	
    return YES;
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
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if( [url.absoluteString hasPrefix:@"dishbyme://"] )
	{
		JLLog( @"Launch from URL : %@", url );
		NSInteger dishId = [[url.absoluteString substringFromIndex:11] integerValue];
		if( dishId )
		{
			DishDetailViewController *detailViewController = [[DishDetailViewController alloc] initWithDishId:dishId dishName:nil];
			[self.dishListViewController.navigationController pushViewController:detailViewController animated:NO];
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
		WritingViewController *writingViewController = [[WritingViewController alloc] init];
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
			[AuthViewController presentAuthViewControllerFromViewController:self.tabBarController delegate:self];
		}
		
	}] showInView:self.window];
}


#pragma mark -
#pragma mark AuthViewControllerDelegate

- (void)authViewControllerDidSucceedLogin:(AuthViewController *)authViewController
{
	JLLog( @"loginViewControllerDidSucceedLogin (userId : %d)", [CurrentUser user].userId );
	[self.dishListViewController updateDishes];
	[self.profileViewController loadUserId:[CurrentUser user].userId];
}

@end
