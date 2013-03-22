//
//  DishByMeBarButtonItem.m
//  I'm Traveling
//
//  Created by 전 수열 on 12. 3. 18..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DMBarButtonItem.h"
#import "HTBlock.h"

@implementation DMBarButtonItem

#warning Deprecated
- (id)initWithType:(NSInteger)type title:(NSString *)title target:(id)target action:(SEL)action
{
	JLLog( @"This method is deprecated." );
	return [DMBarButtonItem barButtonItemWithTitle:title target:target action:action];
}

+ (id)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
	UIButton *button = [[UIButton alloc] init];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	button.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[button setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	
	button.adjustsImageWhenHighlighted = NO;
	[button setBackgroundImage:[UIImage imageNamed:@"bar_button.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"bar_button_selected.png"] forState:UIControlStateHighlighted];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	DMBarButtonItem *barButtonItem = [[DMBarButtonItem alloc] initWithCustomView:button];
	barButtonItem.title = title;
	[barButtonItem updateFrame];
	return barButtonItem;
}

+ (void)setBackButtonToViewController:(UIViewController *)viewController
{
	[self setBackButtonToViewController:viewController viewControllerWillBePopped:nil];
}

+ (void)setBackButtonToViewController:(UIViewController *)viewController viewControllerWillBePopped:(void (^)(void))viewControllerWillBePopped
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	button.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[button setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	
	button.titleEdgeInsets = UIEdgeInsetsMake( -1, 8, 0, 0 );
	[button setBackgroundImage:[UIImage imageNamed:@"navigation_bar_button_back.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"navigation_bar_button_back_selected.png"] forState:UIControlStateHighlighted];
	
	[button addTargetBlock:^(id sender) {
		if( viewControllerWillBePopped ) viewControllerWillBePopped();
		[viewController.navigationController popViewControllerAnimated:YES];
	} forControlEvents:UIControlEventTouchUpInside];
	
	DMBarButtonItem *backButton = [[DMBarButtonItem alloc] initWithCustomView:button];
	backButton.title = NSLocalizedString( @"BACK", nil );
	[backButton updateFrame];
	viewController.navigationItem.leftBarButtonItem = backButton;
}

- (void)updateFrame
{
	CGSize constraintSize = CGSizeMake( 80, 30 );
	CGFloat width = [self.title sizeWithFont:self.button.titleLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping].width;
	if( width < 35 ) width = 35; // 최소 너비 55
	
	UIImage *image = [self.button imageForState:UIControlStateNormal];
	if( image )
	{
		width += image.size.width;
	}
	
	self.button.frame = CGRectMake( 0, 0, width + 20, 30 );
}


#pragma mark -
#pragma mark Getter/Setter

- (UIButton *)button
{
	return (UIButton *)self.customView;
}

- (NSString *)title
{
	UIButton *button = (UIButton *)self.customView;
	return [button titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title
{
	UIButton *button = (UIButton *)self.customView;
	[button setTitle:title forState:UIControlStateNormal];
}

@end
