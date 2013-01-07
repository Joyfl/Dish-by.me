//
//  AppDelegate.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DishListViewController;
@class ProfileViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UITabBarController *tabBarController;
	
	DishListViewController *dishListViewController;
	ProfileViewController *profileViewController;
	
	NSInteger currentWritingForkedFrom;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) NSInteger currentWritingForkedFrom;

- (void)cameraButtonDidTouchUpInside;

@end
