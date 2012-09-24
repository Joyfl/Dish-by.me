//
//  AppDelegate.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "AppDelegate.h"
#import "DishByMeNavigationController.h"
#import "DishListViewController.h"
#import "SearchViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "WritingViewController.h"
#import "CameraOverlayViewController.h"
#import "LoginViewController.h"
#import "UserManager.h"

@implementation AppDelegate

@synthesize window = _window, currentWritingForkedFrom;

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
	tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tab_bar_bg.png"];
	tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tab_bar_bg_selected.png"];
	
	DishListViewController *dishListViewController = [[DishListViewController alloc] init];
	DishByMeNavigationController *dishNavigationController = [[DishByMeNavigationController alloc] initWithRootViewController:dishListViewController];
//	dishNavigationController.title = NSLocalizedString( @"DISHES", @"" );
	dishNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_dish.png"];
	dishNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	[dishListViewController release];
	
	SearchViewController *searchViewController = [[SearchViewController alloc] init];
	UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
	searchNavigationController.navigationBar.shadowImage = [[[UIImage alloc] init] autorelease];
	[searchNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_no_border.png"] forBarMetrics:UIBarMetricsDefault];
//	searchNavigationController.title = NSLocalizedString( @"SEARCH", @"" );
	searchNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_search.png"];
	searchNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	[searchViewController release];
	
	profileViewController = [[ProfileViewController alloc] init];
	DishByMeNavigationController *profileNavigationController = [[DishByMeNavigationController alloc] initWithRootViewController:profileViewController];
//	meNavigationController.title = NSLocalizedString( @"ME", @"" );
	profileViewController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_me.png"];
	profileViewController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	[profileViewController release];
	
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
	DishByMeNavigationController *settingsNavigationController = [[DishByMeNavigationController alloc] initWithRootViewController:settingsViewController];
//	settingsNavigationController.title = NSLocalizedString( @"SETTINGS", @"" );
	settingsNavigationController.tabBarItem.image = [UIImage imageNamed:@"tab_icon_settings.png"];
	settingsNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake( 5, 0, -5, 0 );
	[settingsViewController release];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:
										dishNavigationController,
										searchNavigationController,
										[[[UIViewController alloc] init] autorelease],
										profileNavigationController,
										settingsNavigationController,
										nil];
	self.window.rootViewController = tabBarController;
	[dishNavigationController release];
	[searchNavigationController release];
	[profileNavigationController release];
	[settingsNavigationController release];
	
	UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cameraButton.frame = CGRectMake( 128, -1, 64, 50 );
	[cameraButton setImage:[UIImage imageNamed:@"tab_camera.png"] forState:UIControlStateNormal];
	[cameraButton setImage:[UIImage imageNamed:@"tab_camera_highlighted.png"] forState:UIControlStateHighlighted];
	[cameraButton addTarget:self action:@selector(cameraButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[tabBarController.tabBar addSubview:cameraButton];
	
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

#pragma mark -
#pragma mark UITabBarDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	// ProfileView 선택시
	if( [[(UINavigationController *)viewController viewControllers] objectAtIndex:0] == profileViewController )
	{
		// 로그인이 되어있지 않으면 LoginView를 띄움
		if( ![UserManager loggedIn] )
		{
			[self presentLoginViewController];
			return NO;
		}
	}
	
	return YES;
}


#pragma mark -
#pragma mark Selectors

- (void)cameraButtonDidTouchUpInside
{
	if( [UserManager loggedIn] )
		[self presentActionSheet];
	else
		[self presentLoginViewController];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)presentActionSheet
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString( @"CANCEL", @"" ) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString( @"TAKE_A_PHOTO", @"" ), NSLocalizedString( @"FROM_LIBRARY", @"" ), nil];
	[actionSheet showInView:self.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	
	if( buttonIndex == 0 ) // Camera
	{
		@try
		{
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		}
		@catch( NSException *exception )
		{
			[[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", @"" ) message:NSLocalizedString( @"MESSAGE_NO_SUPPORT_CAMERA", @"" ) delegate:self cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"" ) otherButtonTitles:nil] autorelease] show];
			return;
		}
		
		CameraOverlayViewController *overlayViewController = [[CameraOverlayViewController alloc] initWithPicker:picker];
		picker.cameraOverlayView = overlayViewController.view;
		picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
	}
	else if( buttonIndex == 1 ) // Album
	{
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	else
	{
		return;
	}
	
	picker.delegate = self;
	picker.allowsEditing = YES;
	[tabBarController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog( @"Album : %@", info );
	UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	
	// 카메라로 찍은 경우 앨범에 저장
//	if( picker.sourceType == UIImagePickerControllerSourceTypeCamera )
//		UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
	
	[self performSelector:@selector(presentWritingViewControllerWithImage:) withObject:image afterDelay:0.5];
}

- (void)presentWritingViewControllerWithImage:(UIImage *)image
{
	[tabBarController dismissViewControllerAnimated:NO completion:nil];
	
	WritingViewController *writingViewController = [[WritingViewController alloc] initWithPhoto:image];
	DishByMeNavigationController *navController = [[DishByMeNavigationController alloc] initWithRootViewController:writingViewController];
	[tabBarController presentViewController:navController animated:NO completion:nil];
	
	[writingViewController release];
	[navController release];
}

- (void)presentLoginViewController
{
	LoginViewController *loginViewController = [[LoginViewController alloc] initWithTarget:self action:@selector(loginDidFinish)];
	DishByMeNavigationController *navController = [[DishByMeNavigationController alloc] initWithRootViewController:loginViewController];
	[tabBarController presentViewController:navController animated:YES completion:nil];
	
	[loginViewController release];
	[navController release];
}

- (void)loginDidFinish
{
	[profileViewController activateWithUserId:[UserManager userId]];
}

@end
