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
	NSString *_originalTitle; // set title to nil when showsActivityIndicatorView is set to YES.
	UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic) UIButton *button;
@property (nonatomic, assign) BOOL showsActivityIndicatorView;

- (id)initWithType:(NSInteger)type title:(NSString *)title target:(id)target action:(SEL)action;
+ (id)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (void)setBackButtonToViewController:(UIViewController *)viewController;
+ (void)setBackButtonToViewController:(UIViewController *)viewController viewControllerWillBePopped:(void (^)(void))viewControllerWillBePopped;
- (void)updateFrame;

@end
