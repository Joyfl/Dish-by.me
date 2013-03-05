//
//  PhotoEditingViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class RecipeView;

@interface WritingViewController : GAITrackedViewController <UIScrollViewDelegate>
{
	UIImage *_photo;
	UIScrollView *_scrollView;
	UITextField *_nameInput;
	UITextView *_messageInput;
	
	RecipeView *_recipeView;
	CGRect _recipeViewOriginalFrame;
}

- (id)initWithPhoto:(UIImage *)photo;

@end
