//
//  PhotoEditingViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APILoader.h"

@class RecipeView;

@interface WritingViewController : UIViewController <UIScrollViewDelegate, APILoaderDelegate>
{
	UIImage *photo;
	UIScrollView *scrollView;
	UITextField *nameInput;
	UITextView *messageInput;
	
	UIImageView *dim;
	RecipeView *recipeView;
	CGRect recipeViewOriginalFrame;
	
	APILoader *loader;
}

- (id)initWithPhoto:(UIImage *)photo;

@end
