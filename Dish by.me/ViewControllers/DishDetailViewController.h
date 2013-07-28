//
//  DishDetailViewController.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMButton.h"
#import "BookmarkButton.h"
#import "GAITrackedViewController.h"
#import "CommentCell.h"
#import "TTTAttributedLabel.h"
#import "WritingViewController.h"
#import "JLLabelButton.h"
#import "AuthViewController.h"
#import "RecipeViewerViewController.h"

@class Dish;

@interface DishDetailViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate, RecipeViewerViewControllerDelegate, BookmarkButtonDelegate, CommentCellDelegate, WritingViewControllerDelegate, AuthViewControllerDelegate, UITextViewDelegate>
{
	NSInteger _commentOffset;
	BOOL _loadedAllComments;
	
	BOOL lastLoggedIn;
	
	UIImageView *_topView;
	UIImageView *_midView;
	UIImageView *_botView;
	
	CGFloat _contentRowHeight;
	
	UIImageView *_borderView;
	NSTimer *_photoViewTouchTimer;
	
	UILabel *_timeLabel;
	
	UIImageView *_messageBoxView;
	UILabel *_messageLabel;
	UIImageView *_messageBoxDotLineView;
	
	TTTAttributedLabel *_forkedFromLabel;
	JLLabelButton *_forkCountButton;
	
	UIImageView *_dotLineView;
	UIView *_recipeButtonContainer;
	UIButton *_recipeButton;
	UIImageView *_recipeBottomLine;
	
	UIImageView *_bookmarkIconView;
	UILabel *_bookmarkLabel;
	BookmarkButton *_bookmarkButton;
	UIButton *_moreCommentsButton;
	UIActivityIndicatorView *_moreCommentsIndicatorView;
//	UIImageView *_commentBar;
	UIImageView *_commentInputBackgroundView;
	UIPlaceHolderTextView *_commentInput;
	DMButton *_sendButton;
}

@property (nonatomic, strong) Dish *dish;
@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *userPhotoView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *contentBoxTopView;
@property (nonatomic, strong) UIImageView *contentBoxBottomView;
@property (nonatomic, strong) UIImageView *dishPhotoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentSeparatorView;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UIImageView *commentBar;


- (id)initWithDish:(Dish *)dish;
- (id)initWithDishId:(NSInteger)dishId dishName:(NSString *)dishName;

@end
