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

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) AuthViewController *authViewController;
@property (nonatomic, strong) DishListViewController *dishListViewController;
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, assign) BOOL isLastNotificationLoaded;

- (void)cameraButtonDidTouchUpInside;
- (void)presentAuthViewControllerWithClosingAnimation:(BOOL)withClosingAnimation;
- (void)updateNotificationsSuccess:(void (^)(void))success failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure;
- (void)loadMoreNotificationsSuccess:(void (^)(void))success failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure;

@end
