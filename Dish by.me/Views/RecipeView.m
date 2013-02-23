//
//  RecipeView.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "RecipeView.h"
#import "Utils.h"

@implementation RecipeView

@synthesize recipeView;


- (id)initWithTitle:(NSString *)title recipe:(NSString *)recipe closeButtonTarget:(id)target closeButtonAction:(SEL)action
{
	self = [super init];
	
	UIImageView *topShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_bg_top_shadow.png"]];
	[self addSubview:topShadow];
	
	UIImageView *centerShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_bg_center_shadow.png"]];
	[self addSubview:centerShadow];
	
	UIImageView *bottomShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_bg_bottom_shadow.png"]];
	[self addSubview:bottomShadow];
	
	UIImageView *topView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_bg_top.png"]];
	topView.frame = CGRectMake( 3, 4, 300, 50 );
	[self addSubview:topView];
	
	UIImageView *bottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_bg_bottom.png"]];
	[self addSubview:bottomView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 103, 20, 100, 20 )];
	titleLabel.text = title;
	titleLabel.textColor = [Utils colorWithHex:0x5B5046 alpha:1];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.8];
	titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:15];
	[self addSubview:titleLabel];
	
	UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake( 272, 23, 18, 18 )];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"recipe_close_button.png"] forState:UIControlStateNormal];
	[closeButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:closeButton];
	
	recipeView = [[UITextView alloc] initWithFrame:CGRectMake( 10, 60, 280, 200 )];
	recipeView.text = recipe;
	recipeView.textColor = [Utils colorWithHex:0x6B6663 alpha:1.0];
	recipeView.textAlignment = NSTextAlignmentCenter;
	recipeView.backgroundColor = [UIColor clearColor];
	recipeView.font = [UIFont systemFontOfSize:14];
	recipeView.editable = NO;
	[recipeView sizeToFit];
	[self addSubview:recipeView];
	
	bottomView.frame = CGRectMake( 3, 54, 300, recipeView.frame.size.height + 30 );
	centerShadow.frame = CGRectMake( 0, 54, 306, recipeView.frame.size.height + 26 );
	bottomShadow.frame = CGRectMake( 0, 80 + recipeView.frame.size.height, 306, 6 );
	
	NSInteger height = bottomShadow.frame.origin.y + bottomShadow.frame.size.height;
	self.frame = CGRectMake( 7, ( 367 - height ) / 2, 306, height );
	
	return self;
}

@end
