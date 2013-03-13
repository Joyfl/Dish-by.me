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

- (id)initWithType:(NSInteger)type title:(NSString *)title target:(id)target action:(SEL)action
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	button.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[button setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[button setTitle:title forState:UIControlStateNormal];
	
	UIImage *bg;
	switch( type )
	{
		case DMBarButtonItemTypeNormal:
			bg = [UIImage imageNamed:@"button.png"];
			button.frame = CGRectMake( 0, 0, 60, 30 );
			break;
	}
	
	[button setBackgroundImage:bg forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	return [super initWithCustomView:button];
}

+ (void)setBackButtonToViewController:(UIViewController *)viewController
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	button.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[button setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.2] forState:UIControlStateNormal];
	[button setTitle:NSLocalizedString( @"BACK", nil ) forState:UIControlStateNormal];
	
	UIImage *bg = [UIImage imageNamed:@"navigation_bar_button_back.png"];
	button.frame = CGRectMake( 0, 0, 60, 30 );
	button.titleEdgeInsets = UIEdgeInsetsMake( -1, 8, 0, 0 );
	[button setBackgroundImage:bg forState:UIControlStateNormal];
	
	[button addTargetBlock:^(id sender) {
		[viewController.navigationController popViewControllerAnimated:YES];
	} forControlEvents:UIControlEventTouchUpInside];
	
	viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)asd
{
	
}


#pragma mark -
#pragma mark Getter/Setter

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
