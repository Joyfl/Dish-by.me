//
//  PhotoEditingViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecipeView;

@interface WritingViewController : UIViewController <UIScrollViewDelegate>
{
	UIImage *photo;
	UIScrollView *scrollView;
	UIImageView *dim;
	RecipeView *recipeView;
	CGRect recipeViewOriginalFrame;
}

- (id)initWithPhoto:(UIImage *)photo;

@end
