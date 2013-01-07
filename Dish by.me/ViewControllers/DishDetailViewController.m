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
	kRowPhoto = 0,
	kRowProfile = 1,
	kRowMessage = 2,
	kRowRecipe = 3,
	kRowYum = 4,
};

enum {
	kRequestIdComments = 0,
	kRequestIdMoreComments = 1,
	kRequestIdSendComment = 2,
	kRequestIdBookmark = 3,
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
	JLHTTPFormEncodedRequest *req = [[JLHTTPFormEncodedRequest alloc] init];
	req.requestId = kRequestIdBookmark;
	req.url = [NSString stringWithFormat:@"%@dish/%d/bookmark", API_ROOT_URL, _dish.dishId];
	req.method = @"POST";
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
			[_comments addObject:comment];
			[comment release];
			
			[_tableView reloadData];
			_commentInput.text = @"";
			_commentInput.enabled = YES;
		}
	}
	
	else if( response.requestId == kRequestIdBookmark )
	{
		if( response.statusCode == 201 )
		{
			_dish.updatedTime = [result objectForKey:@"updated_time"];
			_dish.bookmarkCount = [[result objectForKey:@"bookmark_count"] integerValue];
			_dish.bookmarked = YES;
			
			_bookmarkButton.enabled = NO;
			[UIView animateWithDuration:0.25 animations:^{
				_bookmarkButton.frame = CGRectMake( 320, 14, 100, 25 );
			}];
			
			[_tableView reloadData];
		}
	}
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch( section )
	{
		case 0:
			return 5;
			
		case 1:
			return _comments.count * 2;
			
		case 2:
			return 1;
	}
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch( indexPath.section )
	{
		case 0:
			switch( indexPath.row )
		{
			case kRowPhoto:
				return 310;
				
			case kRowProfile:
				return 45;
				
			case kRowMessage:
				return _messageRowHeight;
				
			case kRowRecipe:
				if( _dish.recipe )
					return 60;
				return 0;
				
			case kRowYum:
				return 50;
		}
			break;
			
			// Comment
		case 1:
			if( indexPath.row % 2 == 0 )
				return 2;
			return 50;
			
			// Leave a comment
		case 2:
			return 40;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *photoCellId = @"photoCellId";
	static NSString *messageCellId = @"messageCellId";
	static NSString *recipeCellId = @"recipeCellId";
	static NSString *yumCellId = @"yumCellId";
	static NSString *commentCellId = @"commentCellId";
	static NSString *writeCommentCellId = @"writeCommentCellId";
	
	if( indexPath.section == 0 )
	{
		if( indexPath.row == kRowPhoto )
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:photoCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 320 )];
				
				UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake( 11, 11, 298, 298 )];
				imageView.image = [UIImage imageNamed:@"placeholder.png"];
				[bgView addSubview:imageView];
				
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
				[bgView addSubview:borderView];
				[borderView release];
				
				cell.backgroundView = bgView;
				[bgView release];
			}
			
			return cell;
		}
		
		else if( indexPath.row == kRowProfile )
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				UIButton *profileImageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
				profileImageButton.frame = CGRectMake( 12, 10, 30, 30 );
				[profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
				[cell addSubview:profileImageButton];
				
				[JLHTTPLoader loadAsyncFromURL:_dish.userPhotoURL completion:^(NSData *data)
				{
					[profileImageButton setBackgroundImage:_dish.userPhoto = [UIImage imageWithData:data] forState:UIControlStateNormal];
				}];
				
				UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50, 9, 270, 30 )];
				nameLabel.text = _dish.userName;
				nameLabel.textColor = [Utils colorWithHex:0x4A4746 alpha:1.0];
				nameLabel.font = [UIFont boldSystemFontOfSize:14];
				nameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
				nameLabel.shadowOffset = CGSizeMake( 0, 1 );
				nameLabel.backgroundColor = [UIColor clearColor];
				[cell addSubview:nameLabel];
				
				UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 258, 9, 50, 30 )];
#warning 임시 date
				timeLabel.text = @"10분 전";
				timeLabel.textColor = [Utils colorWithHex:0xAAA4A1 alpha:1.0];
				timeLabel.textAlignment = NSTextAlignmentRight;
				timeLabel.font = [UIFont systemFontOfSize:10];
				timeLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
				timeLabel.shadowOffset = CGSizeMake( 0, 1 );
				//				timeLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
				timeLabel.backgroundColor = [UIColor clearColor];
				[cell addSubview:timeLabel];
			}
			return cell;
		}
		
		else if( indexPath.row == kRowMessage )
		{
			UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:messageCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				UIImageView *topView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_top.png"]];
				topView.frame = CGRectMake( 8, 0, 304, 15 );
				[cell addSubview:topView];
				[topView release];
				
				UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake( 20, 15, 280, 20 )];
				messageLabel.text = _dish.description;
				messageLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
				messageLabel.font = [UIFont boldSystemFontOfSize:14];
				messageLabel.shadowOffset = CGSizeMake( 0, 1 );
				messageLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
				messageLabel.backgroundColor = [UIColor clearColor];
				messageLabel.numberOfLines = 0;
				[messageLabel sizeToFit];
				
				UIImageView *centerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_center.png"]];
				centerView.frame = CGRectMake( 8, 15, 304, messageLabel.frame.size.height + 38 );
				[cell addSubview:centerView];
				
				UIImageView *messageBoxDotLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_dot_line.png"]];
				messageBoxDotLineView.frame = CGRectMake( 17, 22 + messageLabel.frame.size.height, 285, 2 );
				[cell addSubview:messageBoxDotLineView];
				[messageBoxDotLineView release];
				
				_forkedFromLabel = [[UILabel alloc] initWithFrame:CGRectMake( 20, 32 + messageLabel.frame.size.height, 280, 20 )];
				_forkedFromLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
				_forkedFromLabel.font = [UIFont boldSystemFontOfSize:14];
				_forkedFromLabel.shadowOffset = CGSizeMake( 0, 1 );
				_forkedFromLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
				_forkedFromLabel.backgroundColor = [UIColor clearColor];
				
				UIButton *forkedButton = [[UIButton alloc] initWithFrame:CGRectMake( 265, 32 + messageLabel.frame.size.height, 40, 20 )];
				forkedButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
				forkedButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				forkedButton.titleLabel.textAlignment = NSTextAlignmentRight;
				[forkedButton setTitle:[NSString stringWithFormat:@"%d", _dish.forkCount] forState:UIControlStateNormal];
				[forkedButton setTitleColor:[Utils colorWithHex:0x808283 alpha:1] forState:UIControlStateNormal];
				[forkedButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.1] forState:UIControlStateNormal];
				[forkedButton setImage:[UIImage imageNamed:@"fork.png"] forState:UIControlStateNormal];
				forkedButton.imageEdgeInsets = UIEdgeInsetsMake( 0, 0, 0, 30 );
				
				UIImageView *bottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_bottom.png"]];
				bottomView.frame = CGRectMake( 8, 15 + centerView.frame.size.height, 304, 15 );
				[cell addSubview:bottomView];
				[bottomView release];
				[centerView release];
				
				UIImageView *dotLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_dotted.png"]];
				dotLineView.frame = CGRectMake( 8, bottomView.frame.origin.y + 25, 304, 2 );
				[cell addSubview:dotLineView];
				[dotLineView release];
				
				[cell addSubview:messageLabel];
				[cell addSubview:_forkedFromLabel];
				[cell addSubview:forkedButton];
				
				_messageRowHeight = 75 + messageLabel.frame.size.height;
				[_tableView reloadData];
			}
			
			return cell;
		}
		else if( indexPath.row == kRowRecipe )
		{
			UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:recipeCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recipeCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				if( !_dish.recipe )
					return cell;
				
				UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 70 )];
				
				_recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 10, 320, 50 )];
				[_recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
				[_recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
				[_recipeButton setTitle:NSLocalizedString( @"SHOW_RECIPE", @"" ) forState:UIControlStateNormal];
				[_recipeButton setTitleColor:[UIColor colorWithRed:0x5B / 255.0 green:0x50 / 255.0 blue:0x46 / 255.0 alpha:1.0] forState:UIControlStateNormal];
				[_recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
				_recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				_recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
				_recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
				[bgView addSubview:_recipeButton];
				
				UIImageView *bottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"]];
				bottomLine.frame = CGRectMake( 0, 54, 320, 10 );
				[bgView addSubview:bottomLine];
				
				[cell addSubview:bgView];
				[bgView release];
			}
			
			return cell;
		}
		else if( indexPath.row == kRowYum )
		{
			UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:yumCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:yumCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
				cell.textLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1];
				cell.textLabel.shadowOffset = CGSizeMake( 0, 1 );
				
				_bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake( 220, 14, 100, 25 )];
				[_bookmarkButton setBackgroundImage:[UIImage imageNamed:@"ribbon.png"] forState:UIControlStateNormal];
				[_bookmarkButton addTarget:self action:@selector(bookmarkButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
				[cell addSubview:_bookmarkButton];
			}
			
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString( @"N_BOOKMAKRED", @"" ), _dish.bookmarkCount];
			
			return cell;
		}
	}
	
	// Comments
	else if( indexPath.section == 1 )
	{
		if( indexPath.row == 0 )
		{
			UITableViewCell *cell = [[UITableViewCell alloc] init];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIImageView *dotLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_dotted.png"]];
			dotLineView.frame = CGRectMake( 8, 0, 304, 2 );
			[cell addSubview:dotLineView];
			[dotLineView release];
			
			return cell;
		}
		else if( indexPath.row % 2 == 1 )
		{
			CommentCell *cell = [_tableView dequeueReusableCellWithIdentifier:commentCellId];
			if( !cell )
			{
				cell = [[CommentCell alloc] initWithResueIdentifier:commentCellId];
			}
			
			Comment *comment = [_comments objectAtIndex:floor( indexPath.row / 2 )];
			[cell setComment:comment atIndexPath:indexPath];
			[comment release];
			
			return cell;
		}
		else
		{
			UITableViewCell *cell = [[UITableViewCell alloc] init];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line.png"]];
			cell.backgroundView = lineView;
			[lineView release];
			
			return cell;
		}
	}
	else if( indexPath.section == 2 )
	{
		UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:writeCommentCellId];
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

- (void)bookmarkButtonDidTouchUpInside
{
	[self bookmark];
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
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
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
#pragma mark LoginViewController

- (void)loginDidFinish
{
	
}

@end
