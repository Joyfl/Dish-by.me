//
//  PhotoEditingViewController.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "RecipeEditorViewController.h"
#import "UIPlaceholderTextView.h"

@class Dish;
@class RecipeView;

@protocol WritingViewControllerDelegate;

@interface WritingViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, RecipeEditorViewControllerDelegate>
{
	UITableView *_tableView;
	
	UITableViewCell *_photoCell;
	UIButton *_photoButton;
	UIImageView *_borderView;
	UITextField *_nameInput;
	UIButton *_facebookButton;
	UIImageView *_messageBoxView;
	UIPlaceHolderTextView *_descriptionInput;
	UIButton *_recipeButton;
	
	RecipeEditorViewController *_recipeView;
	
	NSInteger _editingDishId; // 요리 수정일 경우 수정중인 dish id
	BOOL _isPhotoChanged; // 새 사진이 등록되었는지
	NSInteger _originalDishId;
	
//	NSInteger _messageBoxHeight;
	NSInteger _photoHeight;
}

@property (nonatomic, weak) id<WritingViewControllerDelegate> delegate;

- (id)initWithNewDish;
- (id)initWithDish:(Dish *)dish;
- (id)initWithOriginalDishId:(NSInteger)dishId;

@end


@protocol WritingViewControllerDelegate

- (void)writingViewControllerDidFinishUpload:(WritingViewController *)writingViewController;

@end