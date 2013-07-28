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
	
	TTTAttributedLabel *_forkedFromLabel;
	JLLabelButton *_forkCountButton;
}

@property (nonatomic, strong) Dish *dish;
@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) UITableView *tableView;

//
// User
//
@property (nonatomic, strong) UIImageView *userPhotoView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;

//
// Photo
//
@property (nonatomic, strong) UIImageView *contentBoxTopView;
@property (nonatomic, strong) UIImageView *dishPhotoView;

//
// Content
//
@property (nonatomic, strong) UIImageView *contentBoxBottomView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentSeparatorView;
@property (nonatomic, strong) UILabel *descriptionLabel;

//
// Recipe
//
@property (nonatomic, strong) UIImageView *recipeDotLineView;
@property (nonatomic, strong) UIView *recipeButtonContainer;
@property (nonatomic, strong) UIButton *recipeButton;
@property (nonatomic, strong) UIImageView *recipeBottomLine;


//
// Bookmark
//
@property (nonatomic, strong) UIImageView *bookmarkIconView;
@property (nonatomic, strong) UILabel *bookmarkLabel;
@property (nonatomic, strong) BookmarkButton *bookmarkButton;
@property (nonatomic, strong) UIImageView *bookmarkDotLineView;
@property (nonatomic, strong) JLLabelButton *likeButton;
@property (nonatomic, strong) UILabel *likeButtonCommentButtonSeparator;
@property (nonatomic, strong) JLLabelButton *commentButton;
@property (nonatomic, strong) UIImageView *likeIconView;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UIImageView *commentIconView;
@property (nonatomic, strong) UILabel *commentCountLabel;

//
// More Comments
//
@property (nonatomic, strong) UIButton *moreCommentsButton;
@property (nonatomic, strong) UIActivityIndicatorView *moreCommentsIndicatorView;


@property (nonatomic, strong) UIImageView *commentBar;
@property (nonatomic, strong) UIImageView *commentInputBackgroundView;
@property (nonatomic, strong) UIPlaceHolderTextView *commentInput;
@property (nonatomic, strong) DMButton *sendButton;


- (id)initWithDish:(Dish *)dish;
- (id)initWithDishId:(NSInteger)dishId dishName:(NSString *)dishName;

@end
