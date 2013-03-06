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

@interface WritingViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UITableView *_tableView;
	
	UIButton *_photoButton;
	UIImageView *_borderView;
	UITextField *_nameInput;
	UITextView *_messageInput;
	
	RecipeView *_recipeView;
	CGRect _recipeViewOriginalFrame;
	
	NSInteger _originalDishId;
	NSInteger _photoHeight;
}

- (id)initWithOriginalDishId:(NSInteger)dishId;

@end
