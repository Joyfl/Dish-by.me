//
//  AppDelegate.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "AppDelegate.h"
#import "DishListViewController.h"
#import "SearchViewController.h"
#import "MeViewController.h"
#import "SettingsViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
	[_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	tabBarController = [[UITabBarController alloc] init];
	tabBarController.delegate = self;
//	tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tab_bar.png"];
	
	DishListViewController *dishListViewController = [[DishListViewController alloc] init];
	UINavigationController *dishNavigationController = [[UINavigationController alloc] initWithRootViewController:dishListViewController];
	dishNavigationController.title = NSLocalizedString( @"DISHES", @"" );
//	dishNavigationController.tabBarItem.image = [UIImage imageNamed:@".png"];
	[dishListViewController release];
	
	SearchViewController *searchViewController = [[SearchViewController alloc] init];
	UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
	searchNavigationController.title = NSLocalizedString( @"SEARCH", @"" );
//	searchNavigationController.tabBarItem.image = [UIImage imageNamed:@".png"];
	[searchViewController release];
	
	MeViewController *meViewController = [[MeViewController alloc] init];
	UINavigationController *meNavigationController = [[UINavigationController alloc] initWithRootViewController:meViewController];
	meNavigationController.title = NSLocalizedString( @"ME", @"" );;
//	meNavigationController.tabBarItem.image = [UIImage imageNamed:@".png"];
	[meViewController release];
	
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
	UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	settingsNavigationController.title = NSLocalizedString( @"SETTINGS", @"" );
//	settingsNavigationController.tabBarItem.image = [UIImage imageNamed:@".png"];
	[settingsViewController release];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:
										dishNavigationController,
										searchNavigationController,
										[[[UIViewController alloc] init] autorelease],
										meNavigationController,
										settingsNavigationController,
										nil];
	[self.window addSubview:tabBarController.view];
	[dishNavigationController release];
	[searchNavigationController release];
	[meNavigationController release];
	[settingsNavigationController release];
	
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

@end
