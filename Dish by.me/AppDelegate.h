//
//  AppDelegate.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthViewController.h"
#import "DishListViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, AuthViewControllerDelegate>
{
	UITabBarController *tabBarController;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) DishListViewController *dishListViewController;
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;

- (void)cameraButtonDidTouchUpInside;

@end
