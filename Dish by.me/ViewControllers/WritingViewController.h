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
@class RecipeEditorView;

@protocol WritingViewControllerDelegate;

@interface WritingViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UITableView *_tableView;
	
	UIButton *_photoButton;
	UIImageView *_borderView;
	UITextField *_nameInput;
	UITextView *_messageInput;
	
	RecipeEditorView *_recipeView;
	CGRect _recipeViewOriginalFrame;
	
	NSInteger _originalDishId;
	NSInteger _photoHeight;
}

@property (nonatomic, weak) id<WritingViewControllerDelegate> delegate;

- (id)initWithOriginalDishId:(NSInteger)dishId;

@end


@protocol WritingViewControllerDelegate

- (void)writingViewControllerDidFinishUpload:(WritingViewController *)writingViewController;

@end