//
//  PhotoEditingViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLHTTPLoader.h"

@class RecipeView;

@interface WritingViewController : UIViewController <UIScrollViewDelegate, JLHTTPLoaderDelegate>
{
	UIImage *_photo;
	UIScrollView *_scrollView;
	UITextField *_nameInput;
	UITextView *_messageInput;
	
	UIImageView *_dim;
	RecipeView *_recipeView;
	CGRect _recipeViewOriginalFrame;
	
	JLHTTPLoader *_loader;
}

- (id)initWithPhoto:(UIImage *)photo;

@end
