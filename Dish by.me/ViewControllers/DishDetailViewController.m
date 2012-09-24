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

@implementation DishDetailViewController

enum {
	kRowPhoto = 0,
	kRowProfile = 1,
	kRowMessage = 2,
	kRowRecipe = 3,
	kRowYum = 4,
};

enum {
	kTokenIdComment = 0,
	kTokenIdLike = 1,
	kTokenIdSendComment = 2
};

- (id)initWithDish:(Dish *)_dish
{
	self = [super init];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 367 )];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xEE / 255.0 blue:0xEA / 255.0 alpha:1];
	[self.view addSubview:tableView];
	
	dish = [_dish retain];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	NSString *rootURL = API_ROOT_URL;
	NSString *url = [NSString stringWithFormat:@"%@/dish/%d/comment", rootURL, dish.dishId];
	[loader addTokenWithTokenId:kTokenIdComment url:url method:APILoaderMethodGET params:nil];
	[loader startLoading];
	
	comments = [[NSMutableArray alloc] init];
	
	DishByMeBarButtonItem *backButton = [[DishByMeBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeBack title:NSLocalizedString( @"BACK", @"" ) target:self action:@selector(backButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
	
	if( dish.userId == [UserManager userId] )
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
	
	self.navigationItem.title = dish.dishName;
	
	commentBar = [[UIView alloc] initWithFrame:CGRectMake( 0, 367, 320, 40 )];
	
	UIImageView *commentBarBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tool_bar.png"]];
	[commentBar addSubview:commentBarBg];
	[commentBarBg release];
	
	UIImageView *commentInputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield_bg.png"]];
	commentInputBg.frame = CGRectMake( 5, 5, 235, 30 );
	[commentBar addSubview:commentInputBg];
	[commentInputBg release];
	
	commentInput = [[UITextField alloc] initWithFrame:CGRectMake( 12, 11, 230, 20 )];
	commentInput.font = [UIFont systemFontOfSize:13];
	commentInput.placeholder = NSLocalizedString( @"LEAVE_A_COMMENT", @"" );
	[commentInput addTarget:self action:@selector(commentInputDidBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
	[commentBar addSubview:commentInput];
	[commentInput release];
	
	DishByMeButton *sendButton = [[DishByMeButton alloc] initWithTitle:NSLocalizedString( @"SEND", @"" )];
	sendButton.frame = CGRectMake( 250, 5, 60, 30 );
	sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[sendButton addTarget:self action:@selector(sendButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[commentBar addSubview:sendButton];
	[sendButton release];
	
	[tableView addSubview:commentBar];
	
	dim = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dim.png"]];
	dim.alpha = 0;
	[self.view addSubview:dim];
	
	scrollEnabled = YES;
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[dish release];
	[loader release];
	[comments release];
	[tableView release];
	[recipeButton release];
	[commentBar release];
	[commentInput release];
	[dim release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark APILoaderDelegate

- (BOOL)shouldLoadWithToken:(APILoaderToken *)token
{
	return YES;
}

- (void)loadingDidFinish:(APILoaderToken *)token
{
	NSDictionary *result = [Utils parseJSON:token.data];
	
	if( token.tokenId == kTokenIdComment )
	{
		NSArray *data = [result objectForKey:@"data"];
		
		for( NSDictionary *d in data )
		{
			Comment *comment = [[Comment alloc] init];
			comment.userId = [[d objectForKey:@"user_id"] integerValue];
			comment.name = [d objectForKey:@"user_name"];
			comment.message = [d objectForKey:@"message"];
			[comments addObject:comment];
		}
		
		[tableView reloadData];
	}
	
	else if( token.tokenId == kTokenIdLike )
	{
		NSLog( @"%@", token.data );
		if( [[result objectForKey:@"status"] isEqualToString:@"ok"] )
		{
			likeButton.enabled = NO;
			[UIView animateWithDuration:0.25 animations:^{
				likeButton.frame = CGRectMake( 320, 14, 100, 25 );
			}];
		}
	}
	
	else if( token.tokenId == kTokenIdSendComment )
	{
		if( [[result objectForKey:@"status"] isEqualToString:@"ok"] )
		{
			Comment *comment = [[Comment alloc] init];
			
			comment.userId = [UserManager userId];
			comment.name = [UserManager userName];
			comment.message = commentInput.text;
			[comments addObject:comment];
			
			[tableView reloadData];
			commentInput.text = @"";
			commentInput.enabled = YES;
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
			return comments.count * 2;
			
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
					return messageRowHeight;
					
				case kRowRecipe:
					if( dish.hasRecipe )
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

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
			UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:photoCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 320 )];
				
				UIImageView *imageView = [[UIImageView alloc] initWithImage:dish.photo];
				imageView.frame = CGRectMake( 11, 11, 298, 298 );
				[bgView addSubview:imageView];
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
			UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:messageCellId];
			if( !cell )
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				UIButton *profileImageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
				profileImageButton.frame = CGRectMake( 12, 10, 30, 30 );
				[profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
				[cell addSubview:profileImageButton];
				
				dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{
					NSString *rootURL = WEB_ROOT_URL;
					NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/thumbnail/profile/%d.jpg", rootURL, dish.userId]]];
					if( data == nil )
						return;
					
					dispatch_async( dispatch_get_main_queue(), ^{
						[profileImageButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
					} );
					
					[data release];
				});
				
				UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50, 9, 270, 30 )];
				nameLabel.text = dish.userName;
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
				messageLabel.text = dish.message;
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
				
				UILabel *forkedFromLabel = [[UILabel alloc] initWithFrame:CGRectMake( 20, 32 + messageLabel.frame.size.height, 280, 20 )];
				forkedFromLabel.text = @"헤헤헤를 포크했습니다.";
				forkedFromLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
				forkedFromLabel.font = [UIFont boldSystemFontOfSize:14];
				forkedFromLabel.shadowOffset = CGSizeMake( 0, 1 );
				forkedFromLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
				forkedFromLabel.backgroundColor = [UIColor clearColor];
				
				UIButton *forkedButton = [[UIButton alloc] initWithFrame:CGRectMake( 265, 32 + messageLabel.frame.size.height, 40, 20 )];
				forkedButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
				forkedButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				forkedButton.titleLabel.textAlignment = NSTextAlignmentRight;
				[forkedButton setTitle:[NSString stringWithFormat:@"%d", dish.forkCount] forState:UIControlStateNormal];
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
				[cell addSubview:forkedFromLabel];
				[cell addSubview:forkedButton];
				
				messageRowHeight = 75 + messageLabel.frame.size.height;
				[tableView reloadData];
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
				
				if( !dish.hasRecipe )
					return cell;
				
				UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 70 )];
				
				recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 10, 320, 50 )];
				[recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
				[recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
				[recipeButton setTitle:NSLocalizedString( @"SHOW_RECIPE", @"" ) forState:UIControlStateNormal];
				[recipeButton setTitleColor:[UIColor colorWithRed:0x5B / 255.0 green:0x50 / 255.0 blue:0x46 / 255.0 alpha:1.0] forState:UIControlStateNormal];
				[recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
				recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
				recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
				[bgView addSubview:recipeButton];
				
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
				cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString( @"N_LIKE", @"" ), dish.yumCount];
				cell.textLabel.textColor = [Utils colorWithHex:0x808283 alpha:1];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
				cell.textLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1];
				cell.textLabel.shadowOffset = CGSizeMake( 0, 1 );
				
				likeButton = [[UIButton alloc] initWithFrame:CGRectMake( 220, 14, 100, 25 )];
				[likeButton setBackgroundImage:[UIImage imageNamed:@"ribbon.png"] forState:UIControlStateNormal];
				[likeButton addTarget:self action:@selector(likeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
				[cell addSubview:likeButton];
			}
			
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
			Comment *comment = [comments objectAtIndex:floor( indexPath.row / 2.0 )];
			CommentCell *cell = [_tableView dequeueReusableCellWithIdentifier:commentCellId];
			if( !cell )
			{
				cell = [[CommentCell alloc] initWithResueIdentifier:commentCellId];
				cell.comment = comment;
				[cell loadProfileImage];
			}
			
			cell.comment = comment;
			
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
	if( !scrollEnabled ) return;
	
	if( scrollView.contentSize.height - scrollView.contentOffset.y > 367 )
	{
		commentBar.frame = CGRectMake( 0, scrollView.contentSize.height - 40, 320, 40 );
	}
	else
	{
		commentBar.frame = CGRectMake( 0, scrollView.contentOffset.y + 327, 320, 40 );
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	scrollEnabled = YES;
	[commentInput resignFirstResponder];
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
	appDelegate.currentWritingForkedFrom = dish.dishId;
	[appDelegate cameraButtonDidTouchUpInside];
}

- (void)recipeButtonDidTouchUpInside
{
	RecipeView *recipeView = [[RecipeView alloc] initWithTitle:NSLocalizedString( @"SHOW_RECIPE", @"" ) recipe:dish.recipe closeButtonTarget:self closeButtonAction:@selector(closeButtonDidTouchUpInside:)];
	[self.view addSubview:recipeView];
	
	CGRect originalFrame = recipeView.frame;
	recipeView.frame = CGRectMake( 7, -originalFrame.size.height, originalFrame.size.width, originalFrame.size.height );
	
	[UIView animateWithDuration:0.25 animations:^{
		dim.alpha = 1;
		recipeView.frame = originalFrame;
	}];
}

- (void)closeButtonDidTouchUpInside:(UIButton *)closeButton
{
	RecipeView *recipeView = (RecipeView *)closeButton.superview;
	
	[UIView animateWithDuration:0.25 animations:^{
		dim.alpha = 0;
		recipeView.frame = CGRectMake( 7, -recipeView.frame.size.height, recipeView.frame.size.width, recipeView.frame.size.height );
	}];
	
	[recipeView release];
}

- (void)likeButtonDidTouchUpInside
{
#warning Const에서 가져오기
	[loader addTokenWithTokenId:kTokenIdLike url:[NSString stringWithFormat:@"http://api.dishby.me/dish/%d/yum", dish.dishId] method:APILoaderMethodPOST params:nil];
	[loader startLoading];
}

- (void)commentInputDidBeginEditing
{
	scrollEnabled = NO;
	
	[tableView setContentOffset:CGPointMake( 0, tableView.contentSize.height - 216 + 15 ) animated:YES];
	[UIView animateWithDuration:0.25 animations:^{
		commentBar.frame = CGRectMake( 0, tableView.contentSize.height - 41, 320, 40 );
	}];
}

- (void)sendButtonDidTouchUpInside
{
	scrollEnabled = YES;
	
	
	if( commentInput.text.length == 0 )
	{
		return;
	}
	
	commentInput.enabled = NO;
	
	NSString *rootURL = API_ROOT_URL;
	NSString *url = [NSString stringWithFormat:@"%@/dish/%d/comment", rootURL, dish.dishId];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:commentInput.text, @"message", nil];
	[loader addTokenWithTokenId:kTokenIdSendComment url:url method:APILoaderMethodPOST params:params];
	[loader startLoading];
}

@end
