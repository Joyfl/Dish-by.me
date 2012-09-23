//
//  RecipeView.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeView : UIView
{
	UITextView *recipeView;
}

@property (nonatomic, retain) UITextView *recipeView;

- (id)initWithTitle:(NSString *)title recipe:(NSString *)recipe closeButtonTarget:(id)target closeButtonAction:(SEL)action;

@end
