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
#import "Const.h"
#import "Utils.h"
#import "DishByMeBarButtonItem.h"
#import "CommentCell.h"
#import "DishByMeButton.h"
#import "RecipeView.h"
#import "UserManager.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "LoginViewController.h"
#import "DishByMeNavigationController.h"

@implementation DishDetailViewController

enum {
	kSectionContent = 0,
	kSectionMoreComments = 1,
	kSectionComment = 2,
	kSectionCommentInput = 3,
};

enum {
	kRequestIdComments = 0,
	kRequestIdMoreComments = 1,
	kRequestIdSendComment = 2,
	kRequestIdBookmark = 3,
	kRequestIdUnbookmark = 4,
	kRequestIdReloadDish = 5,
};

- (id)initWithDish:(Dish *)dish
{
	self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	_dish = dish;
	
	DishByMeBarButtonItem *backButton = [[DishByMeBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeBack title:NSLocalizedString( @"BACK", @"" ) target:self action:@selector(backButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
	
	self.navigationItem.title = _dish.dishName;
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 )];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = self.view.backgroundColor;
	_tableView.scrollIndicatorInsets = UIEdgeInsetsMake( 0, 0, 40, 0 );
	[self.view addSubview:_tableView];
	
	_comments = [[NSMutableArray alloc] init];
	
	_commentBar = [[UIView alloc] initWithFrame:CGRectMake( 0, UIScreenHeight - 114, 320, 40 )];
	
	UIImageView *commentBarBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tool_bar.png"]];
	[_commentBar addSubview:commentBarBg];
	[commentBarBg release];
	
	UIImageView *commentInputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield_bg.png"]];
	commentInputBg.frame = CGRectMake( 5, 5, 235, 30 );
	[_commentBar addSubview:commentInputBg];
	[commentInputBg release];
	
	_commentInput = [[UITextField alloc] initWithFrame:CGRectMake( 12, 11, 230, 20 )];
	_commentInput.font = [UIFont systemFontOfSize:13];
	[_commentInput addTarget:self action:@selector(commentInputDidBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
	[_commentBar addSubview:_commentInput];
	[_commentInput release];
	
	_sendButton = [[DishByMeButton alloc] init];
	_sendButton.frame = CGRectMake( 250, 5, 60, 30 );
	_sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[_sendButton addTarget:self action:@selector(sendButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_commentBar addSubview:_sendButton];
	[_sendButton release];
	
	[_tableView addSubview:_commentBar];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)];
	[self.view addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	
	_dim = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dim.png"]];
	_dim.alpha = 0;
	[self.view addSubview:_dim];
	
	_loader = [[JLHTTPLoader alloc] init];
	_loader.delegate = self;
	
	[self loadComments];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	if( [UserManager manager].loggedIn )
	{
		if( _dish.userId == [UserManager manager].userId )
		{
			DishByMeBarButtonItem *editButton = [[DishByMeBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeNormal title:NSLocalizedString( @"EDIT", @"" ) target:self	action:@selector(editButtonDidTouchUpInside)];
			self.navigationItem.rightBarButtonItem = editButton;
			[editButton release];
		}
		else
		{
			DishByMeBarButtonItem *forkButton = [[DishByMeBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeNormal title:NSLocalizedString( @"FORK", @"" ) target:self	action:@selector(forkButtonDidTouchUpInside)];
			self.navigationItem.rightBarButtonItem = forkButton;
			[forkButton release];
		}
		
		_commentInput.enabled = YES;
		_commentInput.placeholder = NSLocalizedString( @"LEAVE_A_COMMENT", @"" );
		[_sendButton setTitle:NSLocalizedString( @"SEND", @"전송" ) forState:UIControlStateNormal];
	}
	else
	{
		self.navigationItem.rightBarButtonItem = nil;
		
		_commentInput.enabled = NO;
		_commentInput.placeholder = NSLocalizedString( @"LOGIN_TO_COMMENT", @"댓글을 남기려면 로그인해주세요." );
		[_sendButton setTitle:NSLocalizedString( @"LOGIN", @"로그인" ) forState:UIControlStateNormal];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[_dish release]; _dish = nil;
	[_loader release]; _loader = nil;
	[_comments release]; _comments = nil;
	[_tableView release]; _tableView = nil;
	[_recipeButton release]; _recipeButton = nil;
	[_commentBar release]; _commentBar = nil;
	[_commentInput release]; _commentInput = nil;
	[_dim release]; _dim = nil;
}


#pragma mark -
#pragma mark Loading

- (void)loadComments
{
	JLHTTPGETRequest *req = [[JLHTTPGETRequest alloc] init];
	req.requestId = kRequestIdComments;
	req.url = [NSString stringWithFormat:@"%@dish/%d/comments", API_ROOT_URL, _dish.dishId];
	[_loader addRequest:req];
	[_loader startLoading];
}

- (void)loadMoreComments
{
	JLHTTPGETRequest *req = [[JLHTTPGETRequest alloc] init];
	req.requestId = kRequestIdMoreComments;
	req.url = [NSString stringWithFormat:@"%@dish/%d/comments", API_ROOT_URL, _dish.dishId];
	[req setParam:[NSString stringWithFormat:@"%d", _offset] forKey:@"offset"];
	[_loader addRequest:req];
	[_loader startLoading];
}

- (void)sendComment
{
	JLHTTPFormEncodedRequest *req = [[JLHTTPFormEncodedRequest alloc] init];
	req.requestId = kRequestIdSendComment;
	req.url = [NSString stringWithFormat:@"%@dish/%d/comment", API_ROOT_URL, _dish.dishId];
	req.method = @"POST";
	[req setParam:[UserManager manager].accessToken forKey:@"access_token"];
	[req setParam:_commentInput.text forKey:@"message"];
	[_loader addRequest:req];
	[_loader startLoading];
}

- (void)bookmark
{
	NSLog( @"[DishDetailViewController] bookmarkDish" );
	JLHTTPFormEncodedRequest *req = [[JLHTTPFormEncodedRequest alloc] init];
	req.requestId = kRequestIdBookmark;
	req.url = [NSString stringWithFormat:@"%@dish/%d/bookmark", API_ROOT_URL, _dish.dishId];
	req.method = @"POST";
	[req setParam:[UserManager manager].accessToken forKey:@"access_token"];
	[_loader addRequest:req];
	[_loader startLoading];
}

- (void)unbookmark
{
	NSLog( @"[DishDetailViewController] unbookmarkDish" );
	JLHTTPFormEncodedRequest *req = [[JLHTTPFormEncodedRequest alloc] init];
	req.requestId = kRequestIdUnbookmark;
	req.url = [NSString stringWithFormat:@"%@dish/%d/bookmark", API_ROOT_URL, _dish.dishId];
	req.method = @"DELETE";
	[req setParam:[UserManager manager].accessToken forKey:@"access_token"];
	[_loader addRequest:req];
	[_loader startLoading];
}

- (void)reloadDish
{
	NSLog( @"[DishDetailViewController] reloadDish" );
	JLHTTPGETRequest *req = [[JLHTTPGETRequest alloc] init];
	req.requestId = kRequestIdReloadDish;
	req.url = [NSString stringWithFormat:@"%@dish/%d", API_ROOT_URL, _dish.dishId];
	[req setParam:[UserManager manager].accessToken forKey:@"access_token"];
	[_loader addRequest:req];
	[_loader startLoading];
}


#pragma mark -
#pragma mark JLHTTPLoaderDelegate

- (void)loader:(JLHTTPLoader *)loader didFinishLoading:(JLHTTPResponse *)response
{
	NSDictionary *result = [Utils parseJSON:response.body];
	
	if( response.requestId == kRequestIdComments )
	{
		if( response.statusCode == 200 )
		{
			NSArray *data = [result objectForKey:@"data"];
			
			for( NSDictionary *d in data )
			{
				Comment *comment = [Comment commentFromDictionary:d];
				[_comments addObject:comment];
				[comment release];
			}
			
			[_tableView reloadData];
		}
	}
	
	else if( response.requestId == kRequestIdSendComment )
	{
		if( response.statusCode == 201 )
		{
			Comment *comment = [[Comment alloc] init];
			comment.commentId = [[result objectForKey:@"id"] integerValue];
			comment.userId = [UserManager manager].userId;
			comment.userName = [UserManager manager].userName;
			comment.userPhoto = [UserManager manager].userPhoto;
			comment.message = _commentInput.text;
			comment.createdTime = [result objectForKey:@"created_time"];
			comment.relativeCreatedTime = NSLocalizedString( @"JUST_NOW", @"방금" );
			[comment calculateMessageHeight];
			[_comments addObject:comment];
			[comment release];
			
			[_tableView reloadData];
			_commentInput.text = @"";
			_commentInput.enabled = YES;
			
			[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionCommentInput] atScrollPosition:UITableViewScrollPositionNone animated:YES];
		}
	}
	
	else if( response.requestId == kRequestIdBookmark )
	{
		if( response.statusCode == 201 )
		{
			_dish.updatedTime = [result objectForKey:@"updated_time"];
			_dish.bookmarkCount = [[result objectForKey:@"bookmark_count"] integerValue];
		}
		else
		{
			NSLog( @"[DishDetailViewController] Bookmark failed." );
		}
	}
	
	else if( response.requestId == kRequestIdUnbookmark )
	{
		if( response.statusCode != 200 )
		{
			NSLog( @"[DishDetailViewController] Unbookmark failed." );
		}
	}
	
	else if( response.requestId == kRequestIdReloadDish )
	{
		if( response.statusCode == 200 )
		{
			_dish.bookmarked = [[result objectForKey:@"bookmarked"] boolValue];
			[_tableView reloadData];
		}
	}
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch( section )
	{
		case kSectionContent:
			return 1;
			
		case kSectionMoreComments:
			return 0;
			
		case kSectionComment:
			if( [_loader hasRequestId:kRequestIdComments] )
				return 1; // Loading UI
			NSLog( @"%d Comments.", _comments.count );
			return _comments.count;
			
		case kSectionCommentInput:
			return 1;
	}
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch( indexPath.section )
	{
		case kSectionContent:
			return _contentRowHeight;
			
		case kSectionMoreComments:
			return 50;
			
		case kSectionComment:
			if( [_loader hasRequestId:kRequestIdComments] )
				return 50;
			return [[_comments objectAtIndex:indexPath.row] messageHeight] + 32;
		
		case kSectionCommentInput:
			return 40;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *contentCellId = @"contentCellId";
	static NSString *commentCellId = @"commentCellId";
	static NSString *commentInputCellId = @"commentInputCellId";
	static NSString *loadingCellId = @"loadingCellId";
	
	if( indexPath.section == kSectionContent )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contentCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			//
			// Photo
			//
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake( 11, 11, 298, 298 )];
			imageView.image = [UIImage imageNamed:@"placeholder.png"];
			[cell.contentView addSubview:imageView];
			
			// List에서 이미지 로딩이 덜 끝난 채로 Detail에 들어오는 경우가 있으므로
			if( _dish.photo )
			{
				imageView.image = _dish.photo;
			}
			else
			{
				[JLHTTPLoader loadAsyncFromURL:_dish.photoURL completion:^(NSData *data)
				{
					imageView.image = _dish.photo = [UIImage imageWithData:data];
				}];
			}
			
			[imageView release];
			
			UIImageView *borderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_border.png"]];
			borderView.frame = CGRectMake( 5, 5, 310, 310 );
			[cell.contentView addSubview:borderView];
			[borderView release];
			
			UIButton *profileImageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			profileImageButton.frame = CGRectMake( 13, 320, 25, 25 );
			[profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
			[cell.contentView addSubview:profileImageButton];
			
			[JLHTTPLoader loadAsyncFromURL:_dish.userPhotoURL completion:^(NSData *data)
			{
				[profileImageButton setBackgroundImage:_dish.userPhoto = [UIImage imageWithData:data] forState:UIControlStateNormal];
			}];
			
			//
			// User, Date
			//
			UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 45, 325, 270, 14 )];
			nameLabel.text = _dish.userName;
			nameLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1.0];
			nameLabel.font = [UIFont boldSystemFontOfSize:14];
			nameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
			nameLabel.shadowOffset = CGSizeMake( 0, 1 );
			nameLabel.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:nameLabel];
			[nameLabel release];
			
			_timeLabel = [[UILabel alloc] init];
			_timeLabel.textColor = [Utils colorWithHex:0xAAA4A1 alpha:1.0];
			_timeLabel.textAlignment = NSTextAlignmentRight;
			_timeLabel.font = [UIFont systemFontOfSize:10];
			_timeLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
			_timeLabel.shadowOffset = CGSizeMake( 0, 1 );
			_timeLabel.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:_timeLabel];
			
			//
			// Message
			//
			UIImageView *messageBoxView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"message_box.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 24, 12, 10 )]];
			[cell.contentView addSubview:messageBoxView];
			[messageBoxView release];
			
			UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake( 12, 15, 280, 20 )];
			messageLabel.text = _dish.description;
			messageLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
			messageLabel.font = [UIFont boldSystemFontOfSize:14];
			messageLabel.shadowOffset = CGSizeMake( 0, 1 );
			messageLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
			messageLabel.backgroundColor = [UIColor clearColor];
			messageLabel.numberOfLines = 0;
			[messageLabel sizeToFit];
			[messageBoxView addSubview:messageLabel];
			[messageLabel release];
			
			messageBoxView.frame = CGRectMake( 8, 350, 304, 66 + messageLabel.frame.size.height );
			
			UIImageView *messageBoxDotLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_dot_line.png"]];
			messageBoxDotLineView.frame = CGRectMake( 9, 24 + messageLabel.frame.size.height, 285, 2 );
			[messageBoxView addSubview:messageBoxDotLineView];
			[messageBoxDotLineView release];
			
			if( _dish.forkedFromId )
			{
				UIButton *forkedFromLabelButton = [[UIButton alloc] initWithFrame:CGRectMake( 12, messageBoxDotLineView.frame.origin.y + 8, 280, 20 )];
				[forkedFromLabelButton setTitle:[NSString stringWithFormat:NSLocalizedString( @"FORKED_FROM_S", @"%@를 포크했습니다." ), _dish.forkedFromName ] forState:UIControlStateNormal];
				[forkedFromLabelButton setTitleColor:[Utils colorWithHex:0x808283 alpha:1] forState:UIControlStateNormal];
				[forkedFromLabelButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.1] forState:UIControlStateNormal];
				forkedFromLabelButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				forkedFromLabelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
				forkedFromLabelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
				[messageBoxView addSubview:forkedFromLabelButton];
			}
			
			UIButton *forkedButton = [[UIButton alloc] initWithFrame:CGRectMake( 262, messageBoxDotLineView.frame.origin.y + 8, 40, 20 )];
			forkedButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
			forkedButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
			forkedButton.titleLabel.textAlignment = NSTextAlignmentRight;
			[forkedButton setTitle:[NSString stringWithFormat:@"%d", _dish.forkCount] forState:UIControlStateNormal];
			[forkedButton setTitleColor:[Utils colorWithHex:0x808283 alpha:1] forState:UIControlStateNormal];
			[forkedButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.1] forState:UIControlStateNormal];
			[forkedButton setImage:[UIImage imageNamed:@"fork.png"] forState:UIControlStateNormal];
			forkedButton.imageEdgeInsets = UIEdgeInsetsMake( 2, 0, 0, 15 );
			[messageBoxView addSubview:forkedButton];
			
			NSInteger messageBoxBottomY = messageBoxView.frame.origin.y + messageBoxView.frame.size.height;
			NSInteger recipeButtonBottomY = messageBoxBottomY + 8;
			
			//
			// Recipe
			//
			if( _dish.recipe.length > 0 )
			{
				UIImageView *dotLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_dotted.png"]];
				dotLineView.frame = CGRectMake( 8, messageBoxBottomY + 18, 304, 2 );
				[cell.contentView addSubview:dotLineView];
				[dotLineView release];
				
				_recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, messageBoxBottomY + 36, 320, 50 )];
				[_recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
				[_recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
				[_recipeButton setTitle:NSLocalizedString( @"SHOW_RECIPE", @"" ) forState:UIControlStateNormal];
				[_recipeButton setTitleColor:[UIColor colorWithRed:0x5B / 255.0 green:0x50 / 255.0 blue:0x46 / 255.0 alpha:1.0] forState:UIControlStateNormal];
				[_recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
				_recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				_recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
				_recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
				[cell.contentView addSubview:_recipeButton];
				
				recipeButtonBottomY = messageBoxBottomY + 74;
			}
			
			UIImageView *recipeBottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"]];
			recipeBottomLine.frame = CGRectMake( 0, recipeButtonBottomY, 320, 15 );
			[cell.contentView addSubview:recipeBottomLine];
			
			//
			// Bookmark
			//
			_bookmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake( 28, recipeButtonBottomY + 35, 180, 12 )];
			_bookmarkLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
			_bookmarkLabel.font = [UIFont boldSystemFontOfSize:12];
			_bookmarkLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1];
			_bookmarkLabel.shadowOffset = CGSizeMake( 0, 1 );
			_bookmarkLabel.backgroundColor= [UIColor clearColor];
			[cell.contentView addSubview:_bookmarkLabel];
			
			_bookmarkIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 10, recipeButtonBottomY + 33, 13, 17 )];
			[cell.contentView addSubview:_bookmarkIconView];
			
			_bookmarkButton = [[BookmarkButton alloc] init];
			_bookmarkButton.delegate = self;
			_bookmarkButton.parentView = cell.contentView;
			_bookmarkButton.position = CGPointMake( 320, recipeButtonBottomY + 30 );
			
			_contentRowHeight = recipeButtonBottomY + 65;
			[_tableView reloadData];
		}
		
		_timeLabel.text = _dish.relativeCreatedTime;
		[_timeLabel sizeToFit];
		_timeLabel.frame = CGRectMake( 306 - _timeLabel.frame.size.width, 327, _timeLabel.frame.size.width, 10 );
		
		if( _dish.bookmarked )
			_bookmarkButton.buttonX = 10;
		else
			_bookmarkButton.buttonX = 75;

		_bookmarkButton.hidden = ![UserManager manager].loggedIn;
		[self updateBookmarkUI];
		
		return cell;
	}
	
	// Comments
	else if( indexPath.section == kSectionComment )
	{
		if( [_loader hasRequestId:kRequestIdComments] )
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
			[indicator release];
			
			return cell;
		}
		
		CommentCell *cell = [_tableView dequeueReusableCellWithIdentifier:commentCellId];
		if( !cell )
			cell = [[CommentCell alloc] initWithResueIdentifier:commentCellId];
		
		Comment *comment = [_comments objectAtIndex:indexPath.row];
		[cell setComment:comment atIndexPath:indexPath];
		[comment release];
		
		return cell;
	}
	
	// Comment Input (Empty cell just for height)
	else if( indexPath.section == kSectionCommentInput )
	{
		UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:commentInputCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] init];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	
	return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if( !_commentInput.isFirstResponder )
	{
		if( scrollView.contentSize.height - scrollView.contentOffset.y > UIScreenHeight - 114 )
			_commentBar.frame = CGRectMake( 0, scrollView.contentSize.height - 40, 320, 40 );
		else
			_commentBar.frame = CGRectMake( 0, scrollView.contentOffset.y + UIScreenHeight - 154, 320, 40 );
	}
	else
	{
		if( scrollView.contentSize.height - scrollView.contentOffset.y > UIScreenHeight - 279 )
			_commentBar.frame = CGRectMake( 0, scrollView.contentSize.height - 40, 320, 40 );
		else
			_commentBar.frame = CGRectMake( 0, scrollView.contentOffset.y + UIScreenHeight - 319, 320, 40 );
	}
}

- (void)updateBookmarkUI
{
	_bookmarkIconView.image = !_dish.bookmarked ? [UIImage imageNamed:@"icon_bookmark_gray.png"] : [UIImage imageNamed:@"icon_bookmark_selected.png"];
	_bookmarkLabel.text = [NSString stringWithFormat:NSLocalizedString( @"N_BOOKMAKRED", @"" ), _dish.bookmarkCount];
}


#pragma mark -
#pragma mark Selectors

- (void)backButtonDidTouchUpInside
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)editButtonDidTouchUpInside
{
	
}

- (void)forkButtonDidTouchUpInside
{
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	appDelegate.currentWritingForkedFrom = _dish.dishId;
	[appDelegate cameraButtonDidTouchUpInside];
}

- (void)backgroundDidTap
{
	[_commentInput resignFirstResponder];
	
	[UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^
	{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
	} completion:nil];
}

- (void)recipeButtonDidTouchUpInside
{
	RecipeView *recipeView = [[RecipeView alloc] initWithTitle:NSLocalizedString( @"SHOW_RECIPE", @"" ) recipe:_dish.recipe closeButtonTarget:self closeButtonAction:@selector(closeButtonDidTouchUpInside:)];
	[self.view addSubview:recipeView];
	
	CGRect originalFrame = recipeView.frame;
	recipeView.frame = CGRectMake( 7, -originalFrame.size.height, originalFrame.size.width, originalFrame.size.height );
	
	[UIView animateWithDuration:0.25 animations:^{
		_dim.alpha = 1;
		recipeView.frame = originalFrame;
	}];
}

- (void)closeButtonDidTouchUpInside:(UIButton *)closeButton
{
	RecipeView *recipeView = (RecipeView *)closeButton.superview;
	
	[UIView animateWithDuration:0.25 animations:^{
		_dim.alpha = 0;
		recipeView.frame = CGRectMake( 7, -recipeView.frame.size.height, recipeView.frame.size.width, recipeView.frame.size.height );
	}];
	
	[recipeView release];
}

- (void)commentInputDidBeginEditing
{
	[UIView animateWithDuration:0.2 animations:^
	{
		_commentBar.frame = CGRectMake( 0, _tableView.contentSize.height - 41, 320, 40 );
	}
	 
	completion:^(BOOL finished)
	{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 279 );
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionCommentInput] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	}];
}

- (void)sendButtonDidTouchUpInside
{
	if( [UserManager manager].loggedIn )
	{
		if( _commentInput.text.length == 0 )
			return;
		
		[self backgroundDidTap];
		_commentInput.enabled = NO;
		
		[self sendComment];
	}
	else
	{
		LoginViewController *loginViewController = [[LoginViewController alloc] initWithTarget:self action:@selector(loginDidFinish)];
		DishByMeNavigationController *navigationController = [[DishByMeNavigationController alloc] initWithRootViewController:loginViewController];
		navigationController.navigationBarHidden = YES;
		[loginViewController release];
		
		[self presentViewController:navigationController animated:YES completion:nil];
		[navigationController release];
	}
}


#pragma mark -
#pragma mark BookmarkButtonDelegate

- (void)bookmarkButton:(BookmarkButton *)button didChangeBookmarked:(BOOL)bookmarked
{
	if( bookmarked )
	{
		if( !_dish.bookmarked )
		{
			[self bookmark];
			_dish.bookmarked = YES;
			_dish.bookmarkCount++;
			[self updateBookmarkUI];
			
			[UIView animateWithDuration:0.18 animations:^{
				_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.14 animations:^{
					_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.12 animations:^{
						_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
					} completion:^(BOOL finished) {
						[UIView animateWithDuration:0.1 animations:^{
							_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
						}];
					}];
				}];
			}];
		}
	}
	else if( !bookmarked )
	{
		if( _dish.bookmarked )
		{
			[self unbookmark];
			_dish.bookmarked = NO;
			_dish.bookmarkCount--;
			[self updateBookmarkUI];
		}
	}
}


#pragma mark -
#pragma mark LoginViewController

- (void)loginDidFinish
{
	[self reloadDish];
}

@end
