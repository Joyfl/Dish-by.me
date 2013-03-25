//
//  DishByMeBarButtonItem.h
//  I'm Traveling
//
//  Created by 전 수열 on 12. 3. 18..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	DMBarButtonItemTypeNormal = 0,
};

@interface DMBarButtonItem : UIBarButtonItem
{
	UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic) UIButton *button;

+ (id)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (void)setBackButtonToViewController:(UIViewController *)viewController;
+ (void)setBackButtonToViewController:(UIViewController *)viewController viewControllerWillBePopped:(void (^)(void))viewControllerWillBePopped;
- (void)updateFrame;

@end
