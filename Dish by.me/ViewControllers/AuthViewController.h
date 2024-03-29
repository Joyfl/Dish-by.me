//
//  FirstViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"

@protocol AuthViewControllerDelegate;


@interface AuthViewController : GAITrackedViewController

@property (nonatomic, weak) id<AuthViewControllerDelegate> delegate;

- (void)openBookCover;
- (void)openBookCoverAfterDelay:(NSTimeInterval)delay;
- (void)closeBookCoverCompletion:(void (^)(UIImageView *coverView))completion;

- (void)getUser;

@end


@protocol AuthViewControllerDelegate

- (void)authViewControllerDidSucceedLogin:(AuthViewController *)authViewController;

@end