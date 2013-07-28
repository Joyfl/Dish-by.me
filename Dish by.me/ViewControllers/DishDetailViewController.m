//
//  DishDetailViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishDetailViewController.h"
#import "Dish.h"
#import "Comment.h"
#import "Utils.h"
#import "DMBarButtonItem.h"
#import "DMButton.h"
#import "CurrentUser.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "DMNavigationController.h"
#import "JLFoldableView.h"
#import "UIView+Screenshot.h"
#import "UIResponder+Dim.h"
#import "ProfileViewController.h"
#import "JLHangulUtils.h"
#import "ForkListViewController.h"
#import "AppDelegate.h"
#import "DMPhotoViewerViewController.h"

#define photoHeight !self.dish ? 296 : 296 * self.dish.photoHeight / self.dish.photoWidth
#define titleHeight [self.dish.dishName sizeWithFont:self.titleLabel.font constrainedToSize:self.titleLabel.frame.size lineBreakMode:NSLineBreakByWordWrapping].height
#define descriptionHeight [self.dish.description sizeWithFont:self.descriptionLabel.font constrainedToSize:self.descriptionLabel.frame.size lineBreakMode:NSLineBreakByWordWrapping].height
#define isFirstCommentLoaded self.dish.commentCount > 0 && _commentOffset == 0

@implementation DishDetailViewController

enum {
	kSectionUser,
	kSectionPhoto,
	kSectionContent,
	kSectionRecipe,
	kSectionBookmark,
	kSectionMoreComments,
	kSectionComment,
};

- (id)initWithDish:(Dish *)dish
{
	self.dish = dish;
	return [self initWithDishId:self.dish.dishId dishName:self.dish.dishName];
}

- (id)initWithDishId:(NSInteger)dishId dishName:(NSString *)dishName
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0x333333 alpha:1];
	self.trackedViewName = [[self class] description];
	
	self.comments = [[NSMutableArray alloc] init];
	
	[DMBarButtonItem setBackButtonToViewController:self];
	
	self.navigationItem.title = dishName;
	
	DMBarButtonItem *moreButton = [DMBarButtonItem barButtonItemWithTitle:nil target:self action:@selector(showNavigationMenu)];
	[moreButton setImage:[UIImage imageNamed:@"icon_more.png"] forState:UIControlStateNormal];
	self.navigationItem.rightBarButtonItem = moreButton;
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 )];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake( 0, 0, 40, 0 );
	self.tableView.contentInset = UIEdgeInsetsMake( 0, 0, 40, 0 );
	[self.view addSubview:self.tableView];
	
	
	//
	// User
	//
	self.userPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake( 14, 13, 25, 26 )];
	self.userPhotoView.layer.cornerRadius = 5;
	self.userPhotoView.clipsToBounds = YES;
	UIImageView *userPhotoShadowView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 25, 26 )];
	userPhotoShadowView.image = [UIImage imageNamed:@"profile_thumbnail_border_small.png"];
	[self.userPhotoView addSubview:userPhotoShadowView];
	self.userPhotoView.userInteractionEnabled = YES;
	[self.userPhotoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile)]];
	
	self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 45, 13, 200, 26 )];
	self.userNameLabel.backgroundColor = [UIColor clearColor];
	self.userNameLabel.font = [UIFont boldSystemFontOfSize:14];
	self.userNameLabel.textColor = [UIColor colorWithHex:0x2E2C2A alpha:1];
	self.userNameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.8];
	self.userNameLabel.shadowOffset = CGSizeMake( 0, 1 );
	
	self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 20, 13, 100, 26 )];
	self.timeLabel.backgroundColor = [UIColor clearColor];
	self.timeLabel.font = [UIFont systemFontOfSize:10];
	self.timeLabel.textColor = [UIColor colorWithHex:0xAAA5A3 alpha:1];
	
	
	//
	// Photo
	//
	self.contentBoxTopView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dish_content_box_top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 15, 15, 0, 10 )]];
	
	self.dishPhotoView = [[UIImageView alloc] init];
	self.dishPhotoView.userInteractionEnabled = YES;
	[self.dishPhotoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDishPhotoViewer)]];
	[self.dishPhotoView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showDishPhotoMenu:)]];
	
	
	//
	// Content
	//
	self.contentBoxBottomView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dish_content_box_bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 10, 10, 10 )]];
	
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 16, 9, 288, 0 )];
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
	self.titleLabel.textColor = [UIColor colorWithHex:0x514F4D alpha:1];
	self.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	self.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	self.titleLabel.numberOfLines = 0;
	
	self.contentSeparatorView = [[UIView alloc] initWithFrame:CGRectMake( 10, 0, 300, 2 )];
	UIView *contentSeparatorTopView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 300, 1 )];
	contentSeparatorTopView.backgroundColor = [UIColor colorWithHex:0xE2DFDC alpha:1];
	UIView *contentSeparatorBottomView = [[UIView alloc] initWithFrame:CGRectMake( 0, 1, 300, 1 )];
	contentSeparatorBottomView.backgroundColor = [UIColor whiteColor];
	[self.contentSeparatorView addSubview:contentSeparatorTopView];
	[self.contentSeparatorView addSubview:contentSeparatorBottomView];
	
	self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake( 18, 0, 284, 0 )];
	self.descriptionLabel.backgroundColor = [UIColor clearColor];
	self.descriptionLabel.font = [UIFont systemFontOfSize:13];
	self.descriptionLabel.textColor = [UIColor colorWithHex:0x48494B alpha:1];
	self.descriptionLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	self.descriptionLabel.shadowOffset = CGSizeMake( 0, 1 );
	self.descriptionLabel.numberOfLines = 0;
	
	//
	// Recipe
	//
	self.recipeDotLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 8, 20, 304, 2 )];
	self.recipeDotLineView.image = [UIImage imageNamed:@"line_dotted.png"];
	
	self.recipeButtonContainer = [[UIView alloc] initWithFrame:CGRectMake( 0, 34, 320, 50 )];
	
	self.recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, 320, 50 )];
	[self.recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
	[self.recipeButton setTitle:NSLocalizedString( @"SHOW_RECIPE", @"" ) forState:UIControlStateNormal];
	[self.recipeButton setTitleColor:[UIColor colorWithHex:0x5B5046 alpha:1] forState:UIControlStateNormal];
	[self.recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
	self.recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	self.recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
	self.recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
	[self.recipeButtonContainer addSubview:self.recipeButton];
	
	CALayer *maskLayer = [CALayer layer];
	maskLayer.bounds = CGRectMake( 0, 0, 640, 100 );
	maskLayer.contents = (id)[UIImage imageNamed:@"placeholder"].CGImage;
	self.recipeButtonContainer.layer.mask = maskLayer;
	
	self.recipeBottomLine = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, 15 )];
	self.recipeBottomLine.image = [UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"];
	
	
	//
	// Bookmark
	//
	self.bookmarkIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 12, 16, 13, 17 )];
	
	self.bookmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake( 33, 16, 0, 0 )];
	self.bookmarkLabel.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	self.bookmarkLabel.font = [UIFont boldSystemFontOfSize:12];
	self.bookmarkLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1];
	self.bookmarkLabel.shadowOffset = CGSizeMake( 0, 1 );
	self.bookmarkLabel.backgroundColor= [UIColor clearColor];
	
	self.bookmarkButton = [[BookmarkButton alloc] init];
	self.bookmarkButton.delegate = self;
	self.bookmarkButton.position = CGPointMake( 320, 13 );
	
	self.bookmarkDotLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 8, 48, 304, 2 )];
	self.bookmarkDotLineView.image = [UIImage imageNamed:@"line_dotted.png"];
	
	self.likeButton = [[JLLabelButton alloc] initWithFrame:CGRectMake( 12, 64, 0, 0 )];
	self.likeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	[self.likeButton setTitle:NSLocalizedString( @"LIKE", nil ) forState:UIControlStateNormal];
	[self.likeButton setTitle:NSLocalizedString( @"UNLIKE", nil ) forState:UIControlStateSelected];
	[self.likeButton setTitleColor:[UIColor colorWithHex:0x717374 alpha:1] forState:UIControlStateNormal];
	[self.likeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
	self.likeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	self.likeButton.hightlightViewInsets = UIEdgeInsetsMake( -4, -4, -4, -4 );
	[self.likeButton addTarget:self action:@selector(likeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	self.likeButtonCommentButtonSeparator = [[UILabel alloc] initWithFrame:CGRectMake( 0, 64, 0, 0 )];
	self.likeButtonCommentButtonSeparator.backgroundColor = [UIColor clearColor];
	self.likeButtonCommentButtonSeparator.font = [UIFont boldSystemFontOfSize:12];
	self.likeButtonCommentButtonSeparator.textColor = [UIColor colorWithHex:0x717374 alpha:1];
	self.likeButtonCommentButtonSeparator.shadowColor = [UIColor colorWithWhite:1 alpha:0.8];
	self.likeButtonCommentButtonSeparator.shadowOffset = CGSizeMake( 0, 1 );
	self.likeButtonCommentButtonSeparator.text = @" ・ ";
	[self.likeButtonCommentButtonSeparator sizeToFit];
	
	self.commentButton = [[JLLabelButton alloc] initWithFrame:CGRectMake( 0, 64, 0, 0 )];
	self.commentButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	[self.commentButton setTitle:NSLocalizedString( @"WRITE_COMMENT", nil ) forState:UIControlStateNormal];
	[self.commentButton setTitleColor:[UIColor colorWithHex:0x717374 alpha:1] forState:UIControlStateNormal];
	[self.commentButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
	self.commentButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[self.commentButton sizeToFit];
	self.commentButton.hightlightViewInsets = UIEdgeInsetsMake( -4, -4, -4, -4 );
	[self.commentButton addTarget:self action:@selector(commentButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	self.likeIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 63, 19, 18 )];
	
	self.likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 60, 0, 0 )];
	self.likeCountLabel.backgroundColor = [UIColor clearColor];
	self.likeCountLabel.font = [UIFont fontWithName:@"SegoeUI-Bold" size:13];
	self.likeCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	self.likeCountLabel.shadowOffset = CGSizeMake( 0, 1 );
	
	self.commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 64, 14, 17 )];
	self.commentIconView.image = [UIImage imageNamed:@"icon_comment_gray.png"];
	
	self.commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 60, 0, 0 )];
	self.commentCountLabel.backgroundColor = [UIColor clearColor];
	self.commentCountLabel.font = [UIFont fontWithName:@"SegoeUI-Bold" size:13];
	self.commentCountLabel.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	self.commentCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	self.commentCountLabel.shadowOffset = CGSizeMake( 0, 1 );
	
	
	//
	// More Comments
	//
	self.moreCommentsButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 2, 320, 43 )];
	[self.moreCommentsButton setImage:[UIImage imageNamed:@"icon_comment_gray.png"] forState:UIControlStateNormal];
	[self.moreCommentsButton setTitle:NSLocalizedString( @"MOREself.comments", @"" ) forState:UIControlStateNormal];
	[self.moreCommentsButton setTitleColor:[UIColor colorWithHex:0x808283 alpha:1] forState:UIControlStateNormal];
	[self.moreCommentsButton setTitleColor:[UIColor colorWithHex:0x343535 alpha:1] forState:UIControlStateHighlighted];
	[self.moreCommentsButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
	self.moreCommentsButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	self.moreCommentsButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	self.moreCommentsButton.imageEdgeInsets = UIEdgeInsetsMake( 2, 12, 0, 0 );
	self.moreCommentsButton.titleEdgeInsets = UIEdgeInsetsMake( 0, 18, 0, 0 );
	self.moreCommentsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self.moreCommentsButton addTarget:self action:@selector(moreCommentsButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	
	//
	// Comment
	//
	self.commentBar = [[UIImageView alloc] initWithFrame:CGRectMake( 0, UIScreenHeight, 320, 40 )];
	self.commentBar.image = [[UIImage imageNamed:@"tool_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 20, 0, 20, 0 )];
	self.commentBar.userInteractionEnabled = YES;
	[self.view addSubview:self.commentBar];
	
	self.commentInputBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"textfield_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 10, 10, 10, 10 )]];
	self.commentInputBackgroundView.frame = CGRectMake( 4, 5, 245, 30 );
	self.commentInputBackgroundView.userInteractionEnabled = YES;
	[self.commentBar addSubview:self.commentInputBackgroundView];
	
	self.commentInput = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake( 12, 11, 230, 20 )];
	self.commentInput.font = [UIFont systemFontOfSize:13];
	self.commentInput.delegate = self;
	self.commentInput.editable = NO;
	self.commentInput.contentInset = UIEdgeInsetsMake( -8, -8, -8, -8 );
	self.commentInput.backgroundColor = [UIColor clearColor];
	[self.commentBar addSubview:self.commentInput];
	
	self.sendButton = [[DMButton alloc] init];
	self.sendButton.frame = CGRectMake( 255, 5, 60, 30 );
	self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[self.sendButton addTarget:self action:@selector(sendButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.commentBar addSubview:self.sendButton];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)];
	tapRecognizer.enabled = NO; // 댓글입력중일때만 활성화 (TTTAttributedLabel 링크 터치 중복문제)
	[self.view addGestureRecognizer:tapRecognizer];
	
	lastLoggedIn = [CurrentUser user].loggedIn;
	
	if( !self.dish )
		[self loadDishId:dishId];
	else
		[self loadComments];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	if( [CurrentUser user].loggedIn )
	{
		self.commentInput.editable = YES;
		self.commentInput.placeholder = NSLocalizedString( @"LEAVE_A_COMMENT", @"" );
		[self.sendButton setTitle:NSLocalizedString( @"SEND", @"전송" ) forState:UIControlStateNormal];
		
		// 로그아웃상태에서 로그인상태로
		if( !lastLoggedIn )
			[self loadDishId:self.dish.dishId];
	}
	
	else
	{
		self.commentInput.editable = NO;
		self.commentInput.placeholder = NSLocalizedString( @"LOGIN_TO_COMMENT", @"댓글을 남기려면 로그인해주세요." );
		[self.sendButton setTitle:NSLocalizedString( @"LOGIN", @"로그인" ) forState:UIControlStateNormal];
	}
	
	[self updateAllCommentsRelativeTime];
	[self.tableView reloadData];
	
	lastLoggedIn = [CurrentUser user].loggedIn;
}


#pragma mark -
#pragma mark Loading

- (void)loadDishId:(NSInteger)dishId
{
	JLLog( @"%d번 Dish 로드 시작", dishId );
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d", dishId];
	[[DMAPILoader sharedLoader] api:api method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"%d번 Dish 로드 완료", dishId );
		
		if( self.dish )
			[self.dish updateFromDictionary:response];
		else
			self.dish = [Dish dishFromDictionary:response];
		
		self.navigationItem.title = self.dish.dishName;
		
		[self.tableView reloadData];
		[self loadComments];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)loadComments
{
	JLLog( @"댓글 로드 시작" );
	NSString *api = [NSString stringWithFormat:@"/dish/%d/comments", self.dish.dishId];
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _commentOffset] };
	[[DMAPILoader sharedLoader] api:api method:@"GET" parameters:params success:^(id response) {
		JLLog( @"댓글 로드 완료" );
		
		NSArray *data = [response objectForKey:@"data"];
		
		self.dish.commentCount = [[response objectForKey:@"count"] integerValue];
		_commentOffset += data.count;
		
		self.commentInput.editable = YES;
		
		// 로드된 댓글이 없을 경우
		if( data.count == 0 )
		{
			_loadedAllComments = _commentOffset == self.dish.commentCount;
			[self.tableView reloadData];
			return;
		}
		
		// 로드된 댓글이 추가될 indexPath들
		NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
		
		for( NSInteger i = 0; i < data.count; i++ )
		{
			NSDictionary *dict = [data objectAtIndex:i];
			Comment *comment = [Comment commentFromDictionary:dict];
			[self.comments insertObject:comment atIndex:i];
			[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:kSectionComment]];
		}
		
		// 처음 로드
		if( _commentOffset == data.count )
		{
			_loadedAllComments = _commentOffset == self.dish.commentCount;
			[self.tableView reloadData];
			return;
		}
		
		// fold 애니메이션이 진행되는동안 제거
		[self.tableView removeFromSuperview];
		
		CGFloat scale = [[UIScreen mainScreen] scale];
		
		// 그냥 screenshot을 가져오면 self.tableView.frame에 보이는 것만 가져와지기 때문에 contentSize만큼 frame을 늘려줌.
		CGPoint originalContentOffset = self.tableView.contentOffset;
		self.tableView.frame = CGRectMake( 0, 0, 320, self.tableView.contentOffset.y + UIScreenHeight - 114 );
		self.tableView.contentOffset = originalContentOffset;
		UIImage *screenshot = [self.tableView screenshot];
		self.tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
		
		// 더보기 cell 아래쪽에 새 댓글들이 추가됨.
		UITableViewCell *moreCommentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionMoreComments]];
		CGRect rect = CGRectMake( 0, self.tableView.contentOffset.y * scale, 320 * scale, (moreCommentCell.frame.origin.y + moreCommentCell.frame.size.height - self.tableView.contentOffset.y) * scale );
		
		// topImage : [테이블뷰 상단 ~ 더보기 버튼]까지의 스크린샷
		UIImage *topImage = [Utils cropImage:screenshot toRect:rect];
		_topView = [[UIImageView alloc] initWithImage:topImage];
		_topView.frame = CGRectMake( 0, 0, _topView.frame.size.width / scale, _topView.frame.size.height / scale );
		[self.view addSubview:_topView];
		
		// botImage : [더보기 버튼 아래쪽 ~ 테이블뷰 하단]까지의 스크린샷
		UIImage *botImage = [Utils cropImage:screenshot toRect:CGRectMake( 0, (moreCommentCell.frame.origin.y + moreCommentCell.frame.size.height) * scale, 320 * scale, (self.tableView.contentSize.height - moreCommentCell.frame.origin.y - moreCommentCell.frame.size.height) * scale )];
		_botView = [[UIImageView alloc] initWithImage:botImage];
		_botView.frame = CGRectMake( 0, _topView.frame.origin.y + _topView.frame.size.height, _botView.frame.size.width / scale, _botView.frame.size.height / scale );
		[self.view addSubview:_botView];
		
		// 안보이는동안 새 댓글들을 추가시켜놓음
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
		[self.tableView endUpdates];
		
		// 새 댓글들의 총 높이
		CGFloat height = 0;
		for( NSInteger i = 0; i < data.count; i++ )
			height += [[self.comments objectAtIndex:i] messageHeight] + 32;
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
			// 댓글이 추가된 self.tableView의 스크린샷을 찍음
			self.tableView.frame = CGRectMake( 0, 0, 320, self.tableView.contentOffset.y + UIScreenHeight - 114 );
			self.tableView.contentOffset = originalContentOffset;
			UIImage *screenshotAfterReload = [self.tableView screenshot];
			self.tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
			
			// midImage : 추가된 새 댓글부분의 스크린샷
			UIImage *midImage = [Utils cropImage:screenshotAfterReload toRect:CGRectMake( 0, (moreCommentCell.frame.origin.y + moreCommentCell.frame.size.height) * scale, 320 * scale, height * scale )];
			_midView = [[UIImageView alloc] initWithImage:midImage];
			_midView.frame = CGRectMake( 0, _topView.frame.origin.y + _topView.frame.size.height, _midView.frame.size.width / scale, _midView.frame.size.height / scale );
		
			JLFoldableView *foldableView = [[JLFoldableView alloc] initWithFrame:CGRectMake( 0, _midView.frame.origin.y, 320, 0 )];
			foldableView.contentView = _midView;
			
			NSInteger foldCount = data.count / 4;
			if( data.count == 1 ) foldCount = 1;
			else if( foldCount < 2 ) foldCount = 2;
			else if( foldCount > 4 ) foldCount = 4;
			
			foldableView.foldCount = foldCount;
			foldableView.fraction = 0;
			[self.view addSubview:foldableView];
			
			[foldableView setFraction:1 animated:YES withDuration:0.5 curve:UIViewAnimationCurveEaseInOut tick:^{
				_botView.frame = (CGRect){{0, foldableView.frame.origin.y + foldableView.frame.size.height}, _botView.frame.size};
			} completion:^(BOOL completion) {
				[_topView removeFromSuperview];
				[_midView removeFromSuperview];
				[_botView removeFromSuperview];
				[foldableView removeFromSuperview];
				
				[self.view addSubview:self.tableView];
				[self.view bringSubviewToFront:self.commentBar];
				[self.moreCommentsIndicatorView removeFromSuperview];
				
				// _loadedAllComments를 위에서 먼저 정하게 되면 새 댓글을 insert할 때와 겹치면서 에러가 발생함. 따라서 댓글을 모두 로드한 후 더보기 버튼 제거.
				_loadedAllComments = _commentOffset == self.dish.commentCount;
				if( _loadedAllComments )
				{
					[self.tableView beginUpdates];
					[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:kSectionMoreComments]] withRowAnimation:UITableViewRowAnimationNone];
					[self.tableView endUpdates];
				}
			}];
		});
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)sendComment
{
	Comment *comment = [[Comment alloc] init];
	comment.userId = [CurrentUser user].userId;
	comment.userName = [CurrentUser user].name;
	comment.userPhotoURL = [CurrentUser user].photoURL;
	comment.message = self.commentInput.text;
	comment.createdTime = [NSDate date];
	comment.relativeCreatedTime = NSLocalizedString( @"SENDING", @"전송중" );
	comment.sending = YES;
	[comment calculateMessageHeight];
	[self.comments addObject:comment];
	
	[self.tableView reloadData];
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/comment", self.dish.dishId];
	NSDictionary *params = @{ @"message": self.commentInput.text };
	
	[self textView:self.commentInput shouldChangeTextInRange:(NSRange){0, self.commentInput.text.length} replacementText:@""];
	self.commentInput.text = @"";
	
	[self.tableView setContentOffset:CGPointMake( 0, self.tableView.contentSize.height - UIScreenHeight + 114 + self.commentBar.frame.size.height ) animated:YES];
	
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:params success:^(id response) {
		JLLog( @"Success" );
		
		[self updateAllCommentsRelativeTime];
		
		comment.commentId = [[response objectForKey:@"id"] integerValue];
		comment.sending = NO;
		
		self.dish.commentCount ++;
		_commentOffset ++;
		
		[self.tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)deleteComment:(NSInteger)commentId
{
	NSString *api = [NSString stringWithFormat:@"/comment/%d", commentId];
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		self.dish.commentCount --;
		if( _commentOffset > 0 )
			_commentOffset --;
		
		[self.tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)bookmark
{
	DishListViewController *dishListViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate dishListViewController];
	for( Dish *dish in dishListViewController.dishes )
	{
		if( dish.dishId == self.dish.dishId )
		{
			dish.bookmarked = YES;
		}
	}
	
	ProfileViewController *profileViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController];
	[profileViewController addBookmark:self.dish];
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", self.dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		self.dish.updatedTime = [response objectForKey:@"updated_time"];
		self.dish.bookmarkCount = [[response objectForKey:@"bookmark_count"] integerValue];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)unbookmark
{
	DishListViewController *dishListViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate dishListViewController];
	for( Dish *dish in dishListViewController.dishes )
	{
		if( dish.dishId == self.dish.dishId )
		{
			dish.bookmarked = NO;
		}
	}
	
	ProfileViewController *profileViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController];
	[profileViewController removeBookmark:self.dish.dishId];
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", self.dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)like
{
	self.dish.liked = YES;
	self.dish.likeCount ++;
	[self updateLikeUI];
	
	self.likeIconView.transform = CGAffineTransformMakeScale( 0.78, 0.78 );
	[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.likeIconView.transform = CGAffineTransformMakeScale( 1.21, 1.21 );
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
			self.likeIconView.transform = CGAffineTransformMakeScale( 0.89, 0.89 );
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				self.likeIconView.transform = CGAffineTransformMakeScale( 1, 1 );
			} completion:nil];
		}];
	}];
	
	[UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.likeCountLabel.transform = CGAffineTransformMakeScale( 1.3, 1.3 );
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
			self.likeCountLabel.transform = CGAffineTransformMakeScale( 0.9, 0.9 );
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				self.likeCountLabel.transform = CGAffineTransformMakeScale( 1, 1 );
			} completion:nil];
		}];
	}];
	
	JLLog( @"<Dish:%d> like", self.dish.dishId );
	NSString *api = [NSString stringWithFormat:@"/dish/%d/like", self.dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		self.dish.updatedTime = [response objectForKey:@"updated_time"];
		self.dish.likeCount = [[response objectForKey:@"like_count"] integerValue];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		self.dish.liked = NO;
		self.dish.likeCount --;
		[self updateLikeUI];
	}];
}

- (void)unlike
{
	self.dish.liked = NO;
	self.dish.likeCount --;
	[self updateLikeUI];
	
	JLLog( @"<Dish:%d> unlike", self.dish.dishId );
	NSString *api = [NSString stringWithFormat:@"/dish/%d/like", self.dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		self.dish.updatedTime = [response objectForKey:@"updated_time"];
		self.dish.likeCount = [[response objectForKey:@"like_count"] integerValue];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		self.dish.liked = YES;
		self.dish.likeCount ++;
		[self updateLikeUI];
	}];
}

- (void)deleteDish
{
	self.view.userInteractionEnabled = NO;
	[self.tabBarController dim];
	
	JLLog( @"[TRY] Delete a dish : %d", self.dish.dishId );
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d", self.dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"[SUCCESS] Delete a dish : %d", self.dish.dishId );
		
		DishListViewController *dishListViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate dishListViewController];
		for( Dish *dish in dishListViewController.dishes )
		{
			if( dish.dishId == self.dish.dishId )
			{
				[dishListViewController.dishes removeObject:dish];
				break;
			}
		}
		
		ProfileViewController *profileViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController];
		[profileViewController removeDish:self.dish.dishId];
		
		[self.tabBarController undim];
		[self.navigationController popViewControllerAnimated:YES];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch( section )
	{
		case kSectionUser:
			return 1;
		
		case kSectionPhoto:
			return 1;
			
		case kSectionContent:
			return 1;
			
		case kSectionRecipe:
			return 1;
			
		case kSectionBookmark:
			return 1;
			
		case kSectionMoreComments:
			return self.comments.count == 0 ? 0 : !_loadedAllComments;
			
		case kSectionComment:
			if( isFirstCommentLoaded )
				return 1; // Loading UI
			return self.comments.count;
	}
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch( indexPath.section )
	{
		case kSectionUser:
			return 44;
			
		case kSectionPhoto:
			return photoHeight + 9;
			
		case kSectionContent:
			return titleHeight + descriptionHeight + self.contentSeparatorView.frame.size.height + 40;
			
		case kSectionRecipe:
			return self.dish.recipe ? 84 : 22;
			
		case kSectionBookmark:
			return 95;
			
		case kSectionMoreComments:
			return 45;
			
		case kSectionComment:
			if( isFirstCommentLoaded )
				return 50;
			return [[self.comments objectAtIndex:indexPath.row] messageHeight] + 32;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *userCellId = @"userCellId";
	static NSString *photoCellId = @"photoCellId";
	static NSString *contentCellId = @"contentCellId";
	static NSString *recipeCellId = @"recipeCellId";
	static NSString *bookmarkCellId = @"bookmarkCellId";
	static NSString *moreCommentCellId = @"moreCommentCellId";
	static NSString *commentCellId = @"commentCellId";
	static NSString *loadingCellId = @"loadingCellId";
	
	//
	// User
	//
	if( indexPath.section == kSectionUser )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			[cell.contentView addSubview:self.userPhotoView];
			[cell.contentView addSubview:self.userNameLabel];
			[cell.contentView addSubview:self.timeLabel];
		}
		
		[self.userPhotoView setImageWithURL:[NSURL URLWithString:self.dish.userPhotoURL] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"]];
		self.userNameLabel.text = self.dish.userName;
		self.timeLabel.text = self.dish.relativeCreatedTime;
		[self.timeLabel sizeToFit];
		self.timeLabel.frame = CGRectMake( 302 - self.timeLabel.frame.size.width, 17, self.timeLabel.frame.size.width, self.timeLabel.frame.size.height );
		
		return cell;
	}
	
	
	//
	// Photo
	//
	else if( indexPath.section == kSectionPhoto )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:photoCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			[cell.contentView addSubview:self.dishPhotoView];
			[cell.contentView addSubview:self.contentBoxTopView];
		}
		
		self.contentBoxTopView.frame = CGRectMake( 8, 0, 304, photoHeight + 9 );
		self.dishPhotoView.frame = CGRectMake( 12, 9, 296, photoHeight );
		[self.dishPhotoView setImageWithURL:[NSURL URLWithString:self.dish.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
		
		return cell;
	}
	
	//
	// Content
	//
	else if( indexPath.section == kSectionContent )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contentCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			[cell.contentView addSubview:self.contentBoxBottomView];
			[cell.contentView addSubview:self.titleLabel];
			[cell.contentView addSubview:self.contentSeparatorView];
			[cell.contentView addSubview:self.descriptionLabel];
		}
		
		self.contentBoxBottomView.frame = CGRectMake( 8, 0, 304, titleHeight + descriptionHeight + self.contentSeparatorView.frame.size.height + 40 );
		
		self.titleLabel.text = self.dish.dishName;
		[self.titleLabel sizeToFit];
		
		self.contentSeparatorView.frame = CGRectMake(self.contentSeparatorView.frame.origin.x,
													 self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 7,
													 self.contentSeparatorView.frame.size.width,
													 self.contentSeparatorView.frame.size.height);
		
		self.descriptionLabel.text = self.dish.description;
		[self.descriptionLabel sizeToFit];
		self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x,
												 self.contentSeparatorView.frame.origin.y + 10,
												 self.descriptionLabel.frame.size.width,
												 self.descriptionLabel.frame.size.height);
		
		return cell;
/*
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIButton *profileImageButton = [[UIButton alloc] initWithFrame:CGRectMake( 14, 1, 25, 25 )];
			profileImageButton.adjustsImageWhenHighlighted = NO;
			[profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
			[profileImageButton setBackgroundImageWithURL:[NSURL URLWithString:self.dish.userPhotoURL] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"] forState:UIControlStateNormal];
			[profileImageButton addTarget:self action:@selector(profileImageButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:profileImageButton];
			
			//
			// User, Date
			//
			UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 45, 6, 270, 14 )];
			nameLabel.text = self.dish.userName;
			nameLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1.0];
			nameLabel.font = [UIFont boldSystemFontOfSize:14];
			nameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
			nameLabel.shadowOffset = CGSizeMake( 0, 1 );
			nameLabel.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:nameLabel];
			
			self.timeLabel = [[UILabel alloc] init];
			self.timeLabel.textColor = [UIColor colorWithHex:0xAAA4A1 alpha:1.0];
			self.timeLabel.textAlignment = NSTextAlignmentRight;
			self.timeLabel.font = [UIFont systemFontOfSize:10];
			self.timeLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
			self.timeLabel.shadowOffset = CGSizeMake( 0, 1 );
			self.timeLabel.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:self.timeLabel];
			
			//
			// Message
			//
			_messageBoxView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"message_box.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 24, 12, 10 )]];
			_messageBoxView.userInteractionEnabled = YES;
			[cell.contentView addSubview:_messageBoxView];
			
			_messageLabel = [[UILabel alloc] init];
			_messageLabel.textColor = [UIColor colorWithHex:0x808283 alpha:1];
			_messageLabel.font = [UIFont boldSystemFontOfSize:14];
			_messageLabel.shadowOffset = CGSizeMake( 0, 1 );
			_messageLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
			_messageLabel.backgroundColor = [UIColor clearColor];
			_messageLabel.numberOfLines = 0;
			[_messageBoxView addSubview:_messageLabel];
			
			_messageBoxDotLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_dot_line.png"]];
			[_messageBoxView addSubview:_messageBoxDotLineView];
			
			if( self.dish.forkedFromId )
			{
				_forkedFromLabel = [[TTTAttributedLabel alloc] init];
				_forkedFromLabel.delegate = self;
				_forkedFromLabel.font = [UIFont boldSystemFontOfSize:14];
				_forkedFromLabel.backgroundColor = [UIColor clearColor];
				_forkedFromLabel.textColor = [UIColor colorWithHex:0x808283 alpha:1];
				_forkedFromLabel.linkAttributes = @{ (NSString *)kCTUnderlineStyleAttributeName: @NO };
				_forkedFromLabel.activeLinkAttributes = @{ (NSString *)kTTTBackgroundFillColorAttributeName: (id)[UIColor lightGrayColor].CGColor, (NSString *)kTTTBackgroundCornerRadiusAttributeName: @3 };
				
				NSString *text = nil;
				NSString *dishNameWithQuote = [NSString stringWithFormat:@"'%@'", self.dish.forkedFromName];
				if( [LANGUAGE isEqualToString:@"ko"] )
				{
					NSArray *hangul = [JLHangulUtils separateHangul:[self.dish.forkedFromName substringFromIndex:self.dish.forkedFromName.length - 1]];
					text = [NSString stringWithFormat:NSLocalizedString( @"FORKED_FROM_S", @"" ), dishNameWithQuote, [[hangul objectAtIndex:2] length] ? @"을" : @"를"];
				}
				else
				{
					text = [NSString stringWithFormat:NSLocalizedString( @"FORKED_FROM_S", @"" ), dishNameWithQuote, @""];
				}
				
				__block NSRange dishNameRange;
				[_forkedFromLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
					dishNameRange = [mutableAttributedString.string rangeOfString:dishNameWithQuote];
					[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor colorWithHex:0x4A4746 alpha:1].CGColor range:dishNameRange];
					return mutableAttributedString;
				}];
				
				[_forkedFromLabel addLinkToURL:nil withRange:dishNameRange];
				[_messageBoxView addSubview:_forkedFromLabel];
			}
			
			_forkCountButton = [[JLLabelButton alloc] init];
			_forkCountButton.titleLabel.font = [UIFont fontWithName:@"SegoeUI-Bold" size:14];
			_forkCountButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
			_forkCountButton.titleLabel.textAlignment = NSTextAlignmentRight;
			[_forkCountButton setTitleColor:[UIColor colorWithHex:0x808283 alpha:1] forState:UIControlStateNormal];
			[_forkCountButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.1] forState:UIControlStateNormal];
			[_forkCountButton setImage:[UIImage imageNamed:@"fork.png"] forState:UIControlStateNormal];
			_forkCountButton.titleEdgeInsets = UIEdgeInsetsMake( -2, 0, 0, -8 );
			_forkCountButton.imageEdgeInsets = UIEdgeInsetsMake( 2, 0, 0, 5 );
			[_forkCountButton addTarget:self action:@selector(forkCountButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[_messageBoxView addSubview:_forkCountButton];
			
			[self.tableView reloadData];
		}
		
		self.timeLabel.text = self.dish.relativeCreatedTime;
		[self.timeLabel sizeToFit];
		self.timeLabel.frame = CGRectMake( 307 - self.timeLabel.frame.size.width, 8, self.timeLabel.frame.size.width, 10 );
		
		_messageLabel.frame = CGRectMake( 12, 15, 280, 0 );
		_messageLabel.text = self.dish.description;
		[_messageLabel sizeToFit];
		_messageBoxView.frame = CGRectMake( 8, 30, 304, 66 + _messageLabel.frame.size.height );
		_messageBoxDotLineView.frame = CGRectMake( 9, 24 + _messageLabel.frame.size.height, 285, 2 );
		
		_forkedFromLabel.frame = CGRectMake( 12, _messageBoxDotLineView.frame.origin.y + 4, 280, 30 );
		
		// (NSInteger)log10f : 자리수
		CGFloat forkedButtonWidth = self.dish.forkCount == 0 ? 35 : 30 + ((NSInteger)log10f( self.dish.forkCount ) + 1) * 5;
		_forkCountButton.frame = CGRectMake( 297 - forkedButtonWidth, _messageBoxDotLineView.frame.origin.y + 9, forkedButtonWidth, 20 );
		[_forkCountButton setTitle:[NSString stringWithFormat:@"%d", self.dish.forkCount] forState:UIControlStateNormal];
		
		NSInteger messageBoxBottomY = _messageBoxView.frame.origin.y + _messageBoxView.frame.size.height;
		NSInteger recipeButtonBottomY = messageBoxBottomY + 8;
		
		
		if( self.dish.recipe )
		{
			self.recipeButtonContainer.frame = CGRectMake( 0, messageBoxBottomY + 36, 320, 50 );
			recipeButtonBottomY = messageBoxBottomY + 74;
		}
		
		_recipeBottomLine.frame = CGRectMake( 0, recipeButtonBottomY, 320, 15 );
		
		
		
		_contentRowHeight = recipeButtonBottomY + 65;
		
		return cell;
 */
	}
	
	//
	// Recipe
	//
	else if( indexPath.section == kSectionRecipe )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recipeCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recipeCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			[cell.contentView addSubview:self.recipeDotLineView];
			[cell.contentView addSubview:self.recipeButtonContainer];
			[cell.contentView addSubview:self.recipeBottomLine];
		}
		
		self.recipeDotLineView.hidden = self.recipeButtonContainer.hidden = !self.dish.recipe;
		self.recipeBottomLine.frame = CGRectMake(self.recipeBottomLine.frame.origin.x,
												 self.dish.recipe ? 71 : 7,
												 self.recipeBottomLine.frame.size.width,
												 self.recipeBottomLine.frame.size.height);
		
		return cell;
	}
	
	//
	// Bookmark
	//
	else if( indexPath.section == kSectionBookmark )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bookmarkCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookmarkCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			[cell.contentView addSubview:self.bookmarkLabel];
			[cell.contentView addSubview:self.bookmarkIconView];
			self.bookmarkButton.parentView = cell.contentView;
			
			[cell.contentView addSubview:self.bookmarkDotLineView];
			[cell.contentView addSubview:self.likeButton];
			[cell.contentView addSubview:self.likeButtonCommentButtonSeparator];
			[cell.contentView addSubview:self.commentButton];
			[cell.contentView addSubview:self.likeIconView];
			[cell.contentView addSubview:self.likeCountLabel];
			[cell.contentView addSubview:self.commentIconView];
			[cell.contentView addSubview:self.commentCountLabel];
		}
		
		if( self.dish.bookmarked )
			self.bookmarkButton.buttonX = 10;
		else
			self.bookmarkButton.buttonX = 75;
		
		self.bookmarkButton.hidden = ![CurrentUser user].loggedIn;
		[self updateBookmarkUI];
		[self updateLikeUI];
		
		return cell;
	}
	
	//
	// More Comments
	//
	else if( indexPath.section == kSectionMoreComments )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreCommentCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreCommentCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line.png"]];
			[cell.contentView addSubview:lineView];
			
			[cell.contentView addSubview:self.moreCommentsButton];
		}
		
		return cell;
	}
	
	// Comments
	else if( indexPath.section == kSectionComment )
	{
		if( isFirstCommentLoaded )
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadingCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			
			UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			indicator.frame = CGRectMake( 141, 0, 37, 37 );
			[indicator startAnimating];
			[cell.contentView addSubview:indicator];
			
			return cell;
		}
		
		CommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:commentCellId];
		if( !cell )
		{
			cell = [[CommentCell alloc] initWithResueIdentifier:commentCellId];
			cell.delegate = self;
		}
		
		Comment *comment = [self.comments objectAtIndex:indexPath.row];
		[cell setComment:comment atIndexPath:indexPath];
		
		return cell;
	}
	
	return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if( scrollView.contentSize.height < 50 )
		return;
	
	if( !self.commentInput.isFirstResponder )
	{
		if( scrollView.contentSize.height - scrollView.contentOffset.y > UIScreenHeight - 114 - self.commentBar.frame.size.height )
		{
			CGRect frame = self.commentBar.frame;
			frame.origin.y = scrollView.contentSize.height - scrollView.contentOffset.y + frame.size.height - self.tableView.contentInset.bottom;
			self.commentBar.frame = frame;
		}
		else
		{
			CGRect frame = self.commentBar.frame;
			frame.origin.y = UIScreenHeight - 154 - frame.size.height + 41;
			self.commentBar.frame = frame;
		}
	}
	else
	{
		CGRect frame = self.commentBar.frame;
		frame.origin.y = UIScreenHeight - 279 - frame.size.height;
		self.commentBar.frame = frame;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section == kSectionComment && self.comments.count > 0 && [[self.comments objectAtIndex:indexPath.row] userId] == [[CurrentUser user] userId];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == kSectionComment )
		return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	Comment *comment = [self.comments objectAtIndex:indexPath.row];
	[self deleteComment:comment.commentId];
	
	[UIView animateWithDuration:0.3 animations:^{
		self.commentBar.frame = CGRectMake( 0, self.tableView.contentSize.height - comment.messageHeight - 72, 320, 40 );
	}];
	
	NSLog( @"removeComment" );
	[self.comments removeObjectAtIndex:indexPath.row];
	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:kSectionComment]] withRowAnimation:UITableViewRowAnimationLeft];
	[self.tableView endUpdates];
}

- (void)updateBookmarkUI
{
	self.bookmarkIconView.image = !self.dish.bookmarked || ![CurrentUser user].loggedIn ? [UIImage imageNamed:@"icon_bookmark_gray.png"] : [UIImage imageNamed:@"icon_bookmark_selected.png"];
	self.bookmarkLabel.text = [NSString stringWithFormat:NSLocalizedString( @"N_BOOKMAKRED", @"" ), self.dish.bookmarkCount];
	[self.bookmarkLabel sizeToFit];
}

- (void)updateLikeUI
{
	self.likeButton.selected = self.dish.liked;
	[self.likeButton sizeToFit];
	self.likeButtonCommentButtonSeparator.frame = CGRectMake(self.likeButton.frame.origin.x + self.likeButton.frame.size.width,
															 self.likeButtonCommentButtonSeparator.frame.origin.y,
															 self.likeButtonCommentButtonSeparator.frame.size.width,
															 self.likeButtonCommentButtonSeparator.frame.size.height);
	self.commentButton.frame = CGRectMake(self.likeButtonCommentButtonSeparator.frame.origin.x + self.likeButtonCommentButtonSeparator.frame.size.width,
										  self.commentButton.frame.origin.y,
										  self.commentButton.frame.size.width,
										  self.commentButton.frame.size.height);
	
	self.commentCountLabel.text = [NSString stringWithFormat:@"%d", self.dish.commentCount];
	[self.commentCountLabel sizeToFit];
	self.commentCountLabel.frame = CGRectMake(320 - self.commentCountLabel.frame.size.width - 12,
											  self.commentCountLabel.frame.origin.y,
											  self.commentCountLabel.frame.size.width,
											  self.commentCountLabel.frame.size.height);
	
	self.commentIconView.frame = CGRectMake(self.commentCountLabel.frame.origin.x - self.commentIconView.frame.size.width - 3,
											self.commentIconView.frame.origin.y,
											self.commentIconView.frame.size.width,
											self.commentIconView.frame.size.height);
	
	
	self.likeCountLabel.text = [NSString stringWithFormat:@"%d", self.dish.likeCount];
	[self.likeCountLabel sizeToFit];
	self.likeCountLabel.frame = CGRectMake(self.commentIconView.frame.origin.x - self.likeCountLabel.frame.size.width - 7,
										   self.likeCountLabel.frame.origin.y,
										   self.likeCountLabel.frame.size.width,
										   self.likeCountLabel.frame.size.height);
	
	self.likeIconView.frame = CGRectMake(self.likeCountLabel.frame.origin.x - self.likeIconView.frame.size.width - 1,
										 self.likeIconView.frame.origin.y,
										 self.likeIconView.frame.size.width,
										 self.likeIconView.frame.size.height);
	
	if( !self.dish.liked || ![CurrentUser user].loggedIn )
	{
		self.likeIconView.image = [UIImage imageNamed:@"icon_like.png"];
		self.likeCountLabel.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	}
	else
	{
		self.likeIconView.image = [UIImage imageNamed:@"icon_like_selected.png"];
		self.likeCountLabel.textColor = [UIColor colorWithHex:0x098CA6 alpha:1];
	}
}

- (void)updateAllCommentsRelativeTime
{
	for( Comment *comment in self.comments )
		[comment updateRelativeTime];
}


#pragma mark -
#pragma mark Selectors

- (void)backButtonDidTouchUpInside
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)showNavigationMenu
{
	
}

#warning not used
- (void)forkButtonDidTouchUpInside
{
	WritingViewController *writingViewController = [[WritingViewController alloc] initWithOriginalDishId:self.dish.dishId];
	writingViewController.delegate = self;
	DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:writingViewController];
	self.tabBarController.modalPresentationStyle = 0;
	[self.navigationController presentViewController:navController animated:YES completion:NO];
}

- (void)backgroundDidTap
{
	[[self.view.gestureRecognizers objectAtIndex:0] setEnabled:NO];
	[self.commentInput resignFirstResponder];
	
	[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^
	{
		self.tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
	} completion:nil];
}

- (void)showDishPhotoViewer
{
	DMPhotoViewerViewController *photoViewer = [[DMPhotoViewerViewController alloc] initWithPhotoURL:[NSURL URLWithString:self.dish.photoURL] thumbnailImage:self.dishPhotoView.image];
	photoViewer.originRect = [photoViewer.view convertRect:self.dishPhotoView.frame fromView:self.dishPhotoView.superview];
	self.tabBarController.modalPresentationStyle = UIModalPresentationCurrentContext;
	[self presentViewController:photoViewer animated:NO completion:nil];
}

- (void)showDishPhotoMenu:(UILongPressGestureRecognizer *)recognizer
{
	if( recognizer.state == UIGestureRecognizerStateBegan )
	{
		UIActionSheet *menu = nil;
		if( self.dish.userId == [CurrentUser user].userId )
		{
			menu = [[UIActionSheet alloc] initWithTitle:nil cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:NSLocalizedString( @"EDIT_DISH", nil ) otherButtonTitles:@[NSLocalizedString( @"DELETE_DISH", nil )] dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
				
				// 요리 수정
				if( buttonIndex == 0 )
				{
					WritingViewController *writingViewController = [[WritingViewController alloc] initWithDish:self.dish];
					writingViewController.delegate = self;
					DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:writingViewController];
					self.tabBarController.modalPresentationStyle = 0;
					[self.navigationController presentViewController:navController animated:YES completion:NO];
				}
				
				// 요리 삭제 -> 재확인
				else if( buttonIndex == 1 )
				{
					[[[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"MESSAGE_REALLY_DELETE", nil ) cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:NSLocalizedString( @"DELETE_DISH", nil ) otherButtonTitles:nil dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
						if( buttonIndex == 0 )
						{
							[self deleteDish];
						}
					}] showInView:self.tabBarController.view];
				}
			}];
			
			menu.destructiveButtonIndex = 1;
		}
		else
		{
			menu = [[UIActionSheet alloc] initWithTitle:nil cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:NSLocalizedString( @"REPORT", nil ) otherButtonTitles:nil dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
				
				// 신고하기
				if( buttonIndex == 0 )
				{
					[[[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"MESSAGE_REPORT_REASON", nil ) cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString( @"REPORT_REASON_SPAM", nil ), NSLocalizedString( @"REPORT_REASON_PORN", nil ), NSLocalizedString( @"REPORT_REASON_VIOLENCE", nil ), NSLocalizedString( @"REPORT_REASON_COPYRIGHT", nil )] dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
						
						if( buttonIndex < 4 )
						{
							[self.tabBarController dim];
							NSString *api = [NSString stringWithFormat:@"/dish/%d/report", self.dish.dishId];
							NSDictionary *params = @{ @"type": [NSString stringWithFormat:@"%d", buttonIndex] };
							[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:params success:^(id response) {
								[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"MESSAGE_REPORT_ACCEPTED_TITLE", nil ) message:NSLocalizedString( @"MESSAGE_REPORT_ACCEPTED", nil ) cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", nil ) otherButtonTitles:nil dismissBlock:nil] show];
								[self.tabBarController undim];
							} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
								showErrorAlert();
								[self.tabBarController undim];
							}];
						}
						
					}] showInView:self.tabBarController.view];
				}
			}];
		}
		
		[menu showInView:self.tabBarController.view];
	}
}

- (void)viewProfile
{
	ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
	[profileViewController loadUserId:self.dish.userId];
	[self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)forkCountButtonDidTouchUpInside
{
	ForkListViewController *forkListViewController = [[ForkListViewController alloc] initWithDish:self.dish];
	[self.navigationController pushViewController:forkListViewController animated:YES];
}

- (void)likeButtonDidTouchUpInside
{
	if( !self.likeButton.selected )
	{
		[self like];
	}
	else
	{
		[self unlike];
	}
}

- (void)commentButtonDidTouchUpInside
{
	if( [CurrentUser user].loggedIn )
		[self.commentInput becomeFirstResponder];
}

- (void)recipeButtonDidTouchUpInside
{
	[self backgroundDidTap];
	[self.tabBarController dim];
	
	[UIView animateWithDuration:0.25 animations:^{
		self.recipeButton.frame = CGRectMake( 0, 50, 320, 50 );
	}];
	
	self.tabBarController.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		RecipeViewerViewController *recipeView = [[RecipeViewerViewController alloc] initWithRecipe:self.dish.recipe];
		recipeView.delegate = self;
		[recipeView presentAnimation];
		[self presentViewController:recipeView animated:NO completion:nil];
	});
}

- (void)recipeViewerViewControllerWillDismiss:(RecipeEditorViewController *)recipeEditorView
{
	[self.tabBarController undim];
}

- (void)recipeViewerViewControllerDidDismiss:(RecipeEditorViewController *)recipeEditorView
{
	[UIView animateWithDuration:0.25 animations:^{
		self.recipeButton.frame = CGRectMake( 0, 0, 320, 50 );
	}];
}

- (void)moreCommentsButtonDidTouchUpInside
{
	if( !self.moreCommentsIndicatorView )
	{
		self.moreCommentsIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self.moreCommentsIndicatorView startAnimating];
	}
	
	self.moreCommentsIndicatorView.frame = CGRectMake( -1, [self.moreCommentsButton convertPoint:self.moreCommentsButton.frame.origin toView:self.tableView].y, 37, 37 );
	[self.tableView addSubview:self.moreCommentsIndicatorView];
	
	[self loadComments];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[[self.view.gestureRecognizers objectAtIndex:0] setEnabled:YES];
	
	
	[UIView animateWithDuration:0.25 animations:^
	{
		CGRect frame = self.commentBar.frame;
		frame.origin.y = UIScreenHeight - 279 - frame.size.height;
		self.commentBar.frame = frame;
		self.tableView.contentOffset = CGPointMake( 0, self.tableView.contentSize.height - frame.origin.y );
	}
	 
	completion:^(BOOL finished)
	{
		self.tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 279 );
	}];
}

- (void)sendButtonDidTouchUpInside
{
	if( [CurrentUser user].loggedIn )
	{
		if( self.commentInput.text.length == 0 || [self.commentInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 )
			return;
		
		[self backgroundDidTap];
		[self sendComment];
	}
	else
	{
		[(AppDelegate *)[UIApplication sharedApplication].delegate presentAuthViewControllerWithClosingAnimation:YES];
	}
}


#pragma mark -
#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
	DishDetailViewController *detailViewController = [[DishDetailViewController alloc] initWithDishId:self.dish.forkedFromId dishName:self.dish.forkedFromName];
	[self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark -
#pragma mark BookmarkButtonDelegate

- (void)bookmarkButton:(BookmarkButton *)button needsUpdateBookmarkUIAsBookmarked:(BOOL)bookmarked
{
	if( bookmarked )
	{
		self.dish.bookmarked = YES;
		self.dish.bookmarkCount++;
		[self updateBookmarkUI];
		
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			self.bookmarkIconView.transform = CGAffineTransformMakeScale( 1.3, 1.3 );
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
				self.bookmarkIconView.transform = CGAffineTransformMakeScale( 0.92, 0.92 );
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
					self.bookmarkIconView.transform = CGAffineTransformMakeScale( 1, 1 );
				} completion:nil];
			}];
		}];
	}
	
	else
	{
		self.dish.bookmarked = NO;
		self.dish.bookmarkCount--;
		[self updateBookmarkUI];
	}
}

- (void)bookmarkButton:(BookmarkButton *)button didChangeBookmarked:(BOOL)bookmarked
{
	if( bookmarked )
	{
		[self bookmark];
	}
	else if( !bookmarked )
	{
		[self unbookmark];
	}
}


#pragma mark -
#pragma mark CommentCellDelegate

- (void)commentCell:(CommentCell *)commentCell didTouchProfilePhotoViewAtIndexPath:(NSIndexPath *)indexPath
{
	ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
	[profileViewController loadUserId:[[self.comments objectAtIndex:indexPath.row] userId]];
	[self.navigationController pushViewController:profileViewController animated:YES];
}


#pragma mark -
#pragma mark WritingViewControllerDelegate

- (void)writingViewControllerDidFinishUpload:(WritingViewController *)writingViewController
{
	JLLog( @"업로드 완료. Dish 재로드" );
	[self loadDishId:self.dish.dishId];
}



#pragma mark -
#pragma mark AuthViewControllerDelegate

- (void)authViewControllerDidSucceedLogin:(AuthViewController *)authViewController
{
	JLLog( @"Login succeed" );
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	static NSInteger fontHeight = 16;
	
	NSInteger maxLineCount = 8;
	CGFloat maxCommentInputHeight = maxLineCount * fontHeight;
	
	NSString *comment = [self.commentInput.text stringByReplacingCharactersInRange:range withString:text];
	
	UIFont *font = self.commentInput.font;
	CGSize constraintSize = CGSizeMake( self.commentInput.frame.size.width - 16, maxCommentInputHeight ); // 최대 8줄
	CGFloat commentHeight = [comment sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping].height;
	if( commentHeight < fontHeight ) commentHeight = fontHeight;
	
	if( [text isEqualToString:@"\n"] && range.location == self.commentInput.text.length && commentHeight < maxCommentInputHeight - fontHeight )
	{
		commentHeight += fontHeight;
	}
	
	CGRect frame = self.commentInput.frame;
	frame.size.height = commentHeight;
	self.commentInput.frame = frame;
	
	frame = self.commentBar.frame;
	frame.size.height = commentHeight + 24;
	frame.origin.y = UIScreenHeight - 279 - frame.size.height;
	self.tableView.contentInset = UIEdgeInsetsMake( 0, 0, frame.size.height, 0 );
	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake( 0, 0, frame.size.height, 0 );
	self.commentBar.frame = frame;
	
	frame = self.commentInputBackgroundView.frame;
	frame.size.height = commentHeight + 14;
	self.commentInputBackgroundView.frame = frame;
	
	frame =self.sendButton.frame;
	frame.origin.y = self.commentBar.frame.size.height - 35;
	self.sendButton.frame = frame;
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
	self.sendButton.enabled = self.commentInput.text.length > 0;
}

@end
