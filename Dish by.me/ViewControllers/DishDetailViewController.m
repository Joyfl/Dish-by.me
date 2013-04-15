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

#define photoHeight !_dish ? 298 : 298 * _dish.photoHeight / _dish.photoWidth
#define isFirstCommentLoaded _dish.commentCount > 0 && _commentOffset == 0

@implementation DishDetailViewController

enum {
	kSectionPhoto = 0,
	kSectionContent = 1,
	kSectionMoreComments = 2,
	kSectionComment = 3,
	kSectionCommentInput = 4,
};

- (id)initWithDish:(Dish *)dish
{
	_dish = dish;
	return [self initWithDishId:_dish.dishId dishName:_dish.dishName];
}

- (id)initWithDishId:(NSInteger)dishId dishName:(NSString *)dishName
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0x333333 alpha:1];
	self.trackedViewName = [[self class] description];
	
	[DMBarButtonItem setBackButtonToViewController:self];
	
	self.navigationItem.title = dishName;
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, photoHeight + 100 )];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	_tableView.scrollIndicatorInsets = UIEdgeInsetsMake( 0, 0, 40, 0 );
	[self.view addSubview:_tableView];
	
	_comments = [[NSMutableArray alloc] init];
	
	_commentBar = [[UIView alloc] initWithFrame:CGRectMake( 0, UIScreenHeight - 114, 320, 40 )];
	
	UIImageView *commentBarBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tool_bar.png"]];
	[_commentBar addSubview:commentBarBg];
	
	UIImageView *commentInputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield_bg.png"]];
	commentInputBg.frame = CGRectMake( 5, 5, 235, 30 );
	[_commentBar addSubview:commentInputBg];
	
	_commentInput = [[UITextField alloc] initWithFrame:CGRectMake( 12, 11, 230, 20 )];
	_commentInput.font = [UIFont systemFontOfSize:13];
	_commentInput.enabled = NO;
	[_commentInput addTarget:self action:@selector(commentInputDidBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
	[_commentBar addSubview:_commentInput];
	
	_sendButton = [[DMButton alloc] init];
	_sendButton.frame = CGRectMake( 250, 5, 60, 30 );
	_sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[_sendButton addTarget:self action:@selector(sendButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_commentBar addSubview:_sendButton];
	
	[_tableView addSubview:_commentBar];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)];
	tapRecognizer.enabled = NO; // 댓글입력중일때만 활성화 (TTTAttributedLabel 링크 터치 중복문제)
	[self.view addGestureRecognizer:tapRecognizer];
	
	lastLoggedIn = [CurrentUser user].loggedIn;
	
	if( !_dish )
		[self loadDishId:dishId];
	else
		[self loadComments];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	if( [CurrentUser user].loggedIn )
	{
		if( _dish.userId == [CurrentUser user].userId )
		{
			DMBarButtonItem *editButton = [DMBarButtonItem barButtonItemWithTitle:NSLocalizedString( @"EDIT", @"" ) target:self	action:@selector(editButtonDidTouchUpInside)];
			self.navigationItem.rightBarButtonItem = editButton;
		}
		else
		{
			DMBarButtonItem *forkButton = [DMBarButtonItem barButtonItemWithTitle:NSLocalizedString( @"FORK", @"" ) target:self	action:@selector(forkButtonDidTouchUpInside)];
			self.navigationItem.rightBarButtonItem = forkButton;
		}
		
		_commentInput.enabled = YES;
		_commentInput.placeholder = NSLocalizedString( @"LEAVE_A_COMMENT", @"" );
		[_sendButton setTitle:NSLocalizedString( @"SEND", @"전송" ) forState:UIControlStateNormal];
		
		// 로그아웃상태에서 로그인상태로
		if( !lastLoggedIn )
			[self loadDishId:_dish.dishId];
	}
	
	else
	{
		self.navigationItem.rightBarButtonItem = nil;
		
		_commentInput.enabled = NO;
		_commentInput.placeholder = NSLocalizedString( @"LOGIN_TO_COMMENT", @"댓글을 남기려면 로그인해주세요." );
		[_sendButton setTitle:NSLocalizedString( @"LOGIN", @"로그인" ) forState:UIControlStateNormal];
	}
	
	[self updateAllCommentsRelativeTime];
	[_tableView reloadData];
	
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
		
		_dish = [Dish dishFromDictionary:response];
		
		self.navigationItem.title = _dish.dishName;
		
		[_tableView reloadData];
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
	NSString *api = [NSString stringWithFormat:@"/dish/%d/comments", _dish.dishId];
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _commentOffset] };
	[[DMAPILoader sharedLoader] api:api method:@"GET" parameters:params success:^(id response) {
		JLLog( @"댓글 로드 완료" );
		
		NSArray *data = [response objectForKey:@"data"];
		
		_dish.commentCount = [[response objectForKey:@"count"] integerValue];
		_commentOffset += data.count;
		
		_commentInput.enabled = YES;
		
		// 로드된 댓글이 없을 경우
		if( data.count == 0 )
		{
			_loadedAllComments = _commentOffset == _dish.commentCount;
			[_tableView reloadData];
			return;
		}
		
		// 로드된 댓글이 추가될 indexPath들
		NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
		
		for( NSInteger i = 0; i < data.count; i++ )
		{
			NSDictionary *dict = [data objectAtIndex:i];
			Comment *comment = [Comment commentFromDictionary:dict];
			[_comments insertObject:comment atIndex:i];
			[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:kSectionComment]];
		}
		
		// 처음 로드
		if( _commentOffset == data.count )
		{
			_loadedAllComments = _commentOffset == _dish.commentCount;
			[_tableView reloadData];
			return;
		}
		
		// fold 애니메이션이 진행되는동안 제거
		[_tableView removeFromSuperview];
		
		CGFloat scale = [[UIScreen mainScreen] scale];
		
		// 그냥 screenshot을 가져오면 _tableView.frame에 보이는 것만 가져와지기 때문에 contentSize만큼 frame을 늘려줌.
		CGPoint originalContentOffset = _tableView.contentOffset;
		_tableView.frame = CGRectMake( 0, 0, 320, _tableView.contentOffset.y + UIScreenHeight - 114 );
		_tableView.contentOffset = originalContentOffset;
		UIImage *screenshot = [_tableView screenshot];
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
		
		// 더보기 cell 아래쪽에 새 댓글들이 추가됨.
		UITableViewCell *moreCommentCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionMoreComments]];
		CGRect rect = CGRectMake( 0, _tableView.contentOffset.y * scale, 320 * scale, (moreCommentCell.frame.origin.y + moreCommentCell.frame.size.height - _tableView.contentOffset.y) * scale );
		
		// topImage : [테이블뷰 상단 ~ 더보기 버튼]까지의 스크린샷
		UIImage *topImage = [Utils cropImage:screenshot toRect:rect];
		_topView = [[UIImageView alloc] initWithImage:topImage];
		_topView.frame = CGRectMake( 0, 0, _topView.frame.size.width / scale, _topView.frame.size.height / scale );
		[self.view addSubview:_topView];
		
		// botImage : [더보기 버튼 아래쪽 ~ 테이블뷰 하단]까지의 스크린샷
		UIImage *botImage = [Utils cropImage:screenshot toRect:CGRectMake( 0, (moreCommentCell.frame.origin.y + moreCommentCell.frame.size.height) * scale, 320 * scale, (_tableView.contentSize.height - moreCommentCell.frame.origin.y - moreCommentCell.frame.size.height) * scale )];
		_botView = [[UIImageView alloc] initWithImage:botImage];
		_botView.frame = CGRectMake( 0, _topView.frame.origin.y + _topView.frame.size.height, _botView.frame.size.width / scale, _botView.frame.size.height / scale );
		[self.view addSubview:_botView];
		
		// 안보이는동안 새 댓글들을 추가시켜놓음
		[_tableView beginUpdates];
		[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
		[_tableView endUpdates];
		
		// 새 댓글들의 총 높이
		CGFloat height = 0;
		for( NSInteger i = 0; i < data.count; i++ )
			height += [[_comments objectAtIndex:i] messageHeight] + 32;
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
			// 댓글이 추가된 _tableView의 스크린샷을 찍음
			_tableView.frame = CGRectMake( 0, 0, 320, _tableView.contentOffset.y + UIScreenHeight - 114 );
			_tableView.contentOffset = originalContentOffset;
			UIImage *screenshotAfterReload = [_tableView screenshot];
			_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
			
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
				
				[self.view addSubview:_tableView];
				[_moreCommentsIndicatorView removeFromSuperview];
				
				// _loadedAllComments를 위에서 먼저 정하게 되면 새 댓글을 insert할 때와 겹치면서 에러가 발생함. 따라서 댓글을 모두 로드한 후 더보기 버튼 제거.
				_loadedAllComments = _commentOffset == _dish.commentCount;
				if( _loadedAllComments )
				{
					[_tableView beginUpdates];
					[_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:kSectionMoreComments]] withRowAnimation:UITableViewRowAnimationNone];
					[_tableView endUpdates];
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
	comment.userPhoto = [CurrentUser user].photo;
	comment.message = _commentInput.text;
	comment.createdTime = [NSDate date];
	comment.relativeCreatedTime = NSLocalizedString( @"SENDING", @"전송중" );
	comment.sending = YES;
	[comment calculateMessageHeight];
	[_comments addObject:comment];
	
	[_tableView reloadData];
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionCommentInput] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/comment", _dish.dishId];
	NSDictionary *params = @{ @"message": _commentInput.text };
	
	_commentInput.text = @"";
	
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:params success:^(id response) {
		JLLog( @"Success" );
		
		[self updateAllCommentsRelativeTime];
		
		comment.commentId = [[response objectForKey:@"id"] integerValue];
		comment.sending = NO;
		
		_dish.commentCount ++;
		_commentOffset ++;
		
		[_tableView reloadData];
		
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
		
		_dish.commentCount --;
		if( _commentOffset > 0 )
			_commentOffset --;
		
		[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)bookmark
{
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", _dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		_dish.updatedTime = [response objectForKey:@"updated_time"];
		_dish.bookmarkCount = [[response objectForKey:@"bookmark_count"] integerValue];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)unbookmark
{
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", _dish.dishId];
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
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
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch( section )
	{
		case kSectionPhoto:
			return 1;
			
		case kSectionContent:
			return 1;
			
		case kSectionMoreComments:
			return _comments.count == 0 ? 0 : !_loadedAllComments;
			
		case kSectionComment:
			if( isFirstCommentLoaded )
				return 1; // Loading UI
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
		case kSectionPhoto:
			return photoHeight + 24;
			
		case kSectionContent:
			return _contentRowHeight;
			
		case kSectionMoreComments:
			return 45;
			
		case kSectionComment:
			if( isFirstCommentLoaded )
				return 50;
			return [[_comments objectAtIndex:indexPath.row] messageHeight] + 32;
		
		case kSectionCommentInput:
			return 40;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *photoCellId = @"photoCellId";
	static NSString *contentCellId = @"contentCellId";
	static NSString *moreCommentCellId = @"moreCommentCellId";
	static NSString *commentCellId = @"commentCellId";
	static NSString *commentInputCellId = @"commentInputCellId";
	static NSString *loadingCellId = @"loadingCellId";
	
	//
	// Photo
	//
	if( indexPath.section == kSectionPhoto )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:photoCellId];
		if( !cell )
		{
			// 이미지 세로 사이즈가 클 경우 kSectionContent가 미리 만들어져있지 않아서
			// tableView 생성시 photoHeight + 100으로 tableView의 높이를 지정했다가
			// 이곳에서 원래 사이즈로 다시 변경
			_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
			
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			_photoView = [[UIImageView alloc] init];
			[cell.contentView addSubview:_photoView];
			
			_borderView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dish_detail_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 12, 12 )]];
			[cell.contentView addSubview:_borderView];
		}
		
		_photoView.frame = CGRectMake( 11, 11, 298, photoHeight );
		_borderView.frame = CGRectMake( 5, 5, 310, _photoView.frame.size.height + 12 );
		
		if( _dish.photo )
		{
			_photoView.image = _dish.photo;
		}
		else if( _dish.thumbnail )
		{
			_photoView.image = _dish.thumbnail;
			[DMAPILoader loadImageFromURLString:_dish.photoURL context:nil success:^(UIImage *image, id context) {
				_photoView.image = _dish.photo = image;
			}];
		}
		else
		{
			_photoView.image = [UIImage imageNamed:@"placeholder.png"];
			[DMAPILoader loadImageFromURLString:_dish.thumbnailURL context:nil success:^(UIImage *image, id context) {
				_photoView.image = _dish.thumbnail = image;
				[DMAPILoader loadImageFromURLString:_dish.photoURL context:nil success:^(UIImage *image, id context) {
					_photoView.image = _dish.photo = image;
				}];
			}];
		}
		
		return cell;
	}
	
	else if( indexPath.section == kSectionContent )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contentCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIButton *profileImageButton = [[UIButton alloc] initWithFrame:CGRectMake( 14, 1, 25, 25 )];
			profileImageButton.adjustsImageWhenHighlighted = NO;
			[profileImageButton setImage:[UIImage imageNamed:@"profile_thumbnail_border.png"] forState:UIControlStateNormal];
			[profileImageButton setBackgroundImageWithURL:[NSURL URLWithString:_dish.userPhotoURL] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"] forState:UIControlStateNormal];
			[profileImageButton addTarget:self action:@selector(profileImageButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:profileImageButton];
			
			//
			// User, Date
			//
			UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 45, 6, 270, 14 )];
			nameLabel.text = _dish.userName;
			nameLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1.0];
			nameLabel.font = [UIFont boldSystemFontOfSize:14];
			nameLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
			nameLabel.shadowOffset = CGSizeMake( 0, 1 );
			nameLabel.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:nameLabel];
			
			_timeLabel = [[UILabel alloc] init];
			_timeLabel.textColor = [UIColor colorWithHex:0xAAA4A1 alpha:1.0];
			_timeLabel.textAlignment = NSTextAlignmentRight;
			_timeLabel.font = [UIFont systemFontOfSize:10];
			_timeLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1.0];
			_timeLabel.shadowOffset = CGSizeMake( 0, 1 );
			_timeLabel.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:_timeLabel];
			
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
			
			if( _dish.forkedFromId )
			{
				_forkedFromLabel = [[TTTAttributedLabel alloc] init];
				_forkedFromLabel.delegate = self;
				_forkedFromLabel.font = [UIFont boldSystemFontOfSize:14];
				_forkedFromLabel.backgroundColor = [UIColor clearColor];
				_forkedFromLabel.textColor = [UIColor colorWithHex:0x808283 alpha:1];
				_forkedFromLabel.linkAttributes = @{ (NSString *)kCTUnderlineStyleAttributeName: @NO };
				_forkedFromLabel.activeLinkAttributes = @{ (NSString *)kTTTBackgroundFillColorAttributeName: (id)[UIColor lightGrayColor].CGColor, (NSString *)kTTTBackgroundCornerRadiusAttributeName: @3 };
				
				NSString *text = nil;
				NSString *dishNameWithQuote = [NSString stringWithFormat:@"'%@'", _dish.forkedFromName];
				if( [LANGUAGE isEqualToString:@"ko"] )
				{
					NSArray *hangul = [JLHangulUtils separateHangul:[_dish.forkedFromName substringFromIndex:_dish.forkedFromName.length - 1]];
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
			
			//
			// Recipe
			//
			if( _dish.recipe )
			{
				_dotLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_dotted.png"]];
				[cell.contentView addSubview:_dotLineView];
				
				_recipeButtonContainer = [[UIView alloc] init];
				[cell.contentView addSubview:_recipeButtonContainer];
				
				_recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, 320, 50 )];
				[_recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
				[_recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
				[_recipeButton setTitle:NSLocalizedString( @"SHOW_RECIPE", @"" ) forState:UIControlStateNormal];
				[_recipeButton setTitleColor:[UIColor colorWithHex:0x5B5046 alpha:1] forState:UIControlStateNormal];
				[_recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
				_recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				_recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
				_recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
				[_recipeButtonContainer addSubview:_recipeButton];
				
				CALayer *maskLayer = [CALayer layer];
				maskLayer.bounds = CGRectMake( 0, 0, 640, 100 );
				maskLayer.contents = (id)[UIImage imageNamed:@"placeholder"].CGImage;
				_recipeButtonContainer.layer.mask = maskLayer;
			}
			
			_recipeBottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"]];
			[cell.contentView addSubview:_recipeBottomLine];
			
			//
			// Bookmark
			//
			_bookmarkLabel = [[UILabel alloc] init];
			_bookmarkLabel.textColor = [UIColor colorWithHex:0x808283 alpha:1];
			_bookmarkLabel.font = [UIFont boldSystemFontOfSize:12];
			_bookmarkLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1];
			_bookmarkLabel.shadowOffset = CGSizeMake( 0, 1 );
			_bookmarkLabel.backgroundColor= [UIColor clearColor];
			[cell.contentView addSubview:_bookmarkLabel];
			
			_bookmarkIconView = [[UIImageView alloc] init];
			[cell.contentView addSubview:_bookmarkIconView];
			
			_bookmarkButton = [[BookmarkButton alloc] init];
			_bookmarkButton.delegate = self;
			_bookmarkButton.parentView = cell.contentView;
		}
		
		_timeLabel.text = _dish.relativeCreatedTime;
		[_timeLabel sizeToFit];
		_timeLabel.frame = CGRectMake( 307 - _timeLabel.frame.size.width, 8, _timeLabel.frame.size.width, 10 );
		
		_messageLabel.frame = CGRectMake( 12, 15, 280, 0 );
		_messageLabel.text = _dish.description;
		[_messageLabel sizeToFit];
		_messageBoxView.frame = CGRectMake( 8, 30, 304, 66 + _messageLabel.frame.size.height );
		_messageBoxDotLineView.frame = CGRectMake( 9, 24 + _messageLabel.frame.size.height, 285, 2 );
		
		_forkedFromLabel.frame = CGRectMake( 12, _messageBoxDotLineView.frame.origin.y + 4, 280, 30 );
		
		// (NSInteger)log10f : 자리수
		CGFloat forkedButtonWidth = _dish.forkCount == 0 ? 35 : 30 + ((NSInteger)log10f( _dish.forkCount ) + 1) * 5;
		_forkCountButton.frame = CGRectMake( 297 - forkedButtonWidth, _messageBoxDotLineView.frame.origin.y + 9, forkedButtonWidth, 20 );
		[_forkCountButton setTitle:[NSString stringWithFormat:@"%d", _dish.forkCount] forState:UIControlStateNormal];
		
		NSInteger messageBoxBottomY = _messageBoxView.frame.origin.y + _messageBoxView.frame.size.height;
		NSInteger recipeButtonBottomY = messageBoxBottomY + 8;
		
		_dotLineView.frame = CGRectMake( 8, messageBoxBottomY + 18, 304, 2 );
		
		if( _dish.recipe )
		{
			_recipeButtonContainer.frame = CGRectMake( 0, messageBoxBottomY + 36, 320, 50 );
			recipeButtonBottomY = messageBoxBottomY + 74;
		}
		
		_recipeBottomLine.frame = CGRectMake( 0, recipeButtonBottomY, 320, 15 );
		
		_bookmarkLabel.frame = CGRectMake( 28, recipeButtonBottomY + 35, 180, 12 );
		_bookmarkIconView.frame = CGRectMake( 10, recipeButtonBottomY + 33, 13, 17 );
		_bookmarkButton.position = CGPointMake( 320, recipeButtonBottomY + 30 );
		
		if( _dish.bookmarked )
			_bookmarkButton.buttonX = 10;
		else
			_bookmarkButton.buttonX = 75;

		_bookmarkButton.hidden = ![CurrentUser user].loggedIn;
		[self updateBookmarkUI];
		
		_contentRowHeight = recipeButtonBottomY + 65;
		[_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
			
			if( !_moreCommentsButton )
			{
				_moreCommentsButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 2, 320, 43 )];
				[_moreCommentsButton setImage:[UIImage imageNamed:@"icon_comment_gray.png"] forState:UIControlStateNormal];
				[_moreCommentsButton setTitle:NSLocalizedString( @"MORE_COMMENTS", @"" ) forState:UIControlStateNormal];
				[_moreCommentsButton setTitleColor:[UIColor colorWithHex:0x808283 alpha:1] forState:UIControlStateNormal];
				[_moreCommentsButton setTitleColor:[UIColor colorWithHex:0x343535 alpha:1] forState:UIControlStateHighlighted];
				[_moreCommentsButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
				_moreCommentsButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
				_moreCommentsButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
				_moreCommentsButton.imageEdgeInsets = UIEdgeInsetsMake( 2, 12, 0, 0 );
				_moreCommentsButton.titleEdgeInsets = UIEdgeInsetsMake( 0, 18, 0, 0 );
				_moreCommentsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
				[_moreCommentsButton addTarget:self action:@selector(moreCommentsButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
				[cell.contentView addSubview:_moreCommentsButton];
			}
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
		
		CommentCell *cell = [_tableView dequeueReusableCellWithIdentifier:commentCellId];
		if( !cell )
		{
			cell = [[CommentCell alloc] initWithResueIdentifier:commentCellId];
			cell.delegate = self;
		}
		
		Comment *comment = [_comments objectAtIndex:indexPath.row];
		[cell setComment:comment atIndexPath:indexPath];
		
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section == kSectionComment && _comments.count > 0 && [[_comments objectAtIndex:indexPath.row] userId] == [[CurrentUser user] userId];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == kSectionComment )
		return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	Comment *comment = [_comments objectAtIndex:indexPath.row];
	[self deleteComment:comment.commentId];
	
	[UIView animateWithDuration:0.3 animations:^{
		_commentBar.frame = CGRectMake( 0, _tableView.contentSize.height - comment.messageHeight - 72, 320, 40 );
	}];
	
	NSLog( @"removeComment" );
	[_comments removeObjectAtIndex:indexPath.row];
	[_tableView beginUpdates];
	[_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:kSectionComment]] withRowAnimation:UITableViewRowAnimationLeft];
	[_tableView endUpdates];
}

- (void)updateBookmarkUI
{
	_bookmarkIconView.image = !_dish.bookmarked || ![CurrentUser user].loggedIn ? [UIImage imageNamed:@"icon_bookmark_gray.png"] : [UIImage imageNamed:@"icon_bookmark_selected.png"];
	_bookmarkLabel.text = [NSString stringWithFormat:NSLocalizedString( @"N_BOOKMAKRED", @"" ), _dish.bookmarkCount];
}

- (void)updateAllCommentsRelativeTime
{
	for( Comment *comment in _comments )
		[comment updateRelativeTime];
}


#pragma mark -
#pragma mark Selectors

- (void)backButtonDidTouchUpInside
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)editButtonDidTouchUpInside
{
	WritingViewController *writingViewController = [[WritingViewController alloc] initWithDish:_dish];
	writingViewController.delegate = self;
	DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:writingViewController];
	[self.navigationController presentViewController:navController animated:YES completion:NO];
}

- (void)forkButtonDidTouchUpInside
{
	WritingViewController *writingViewController = [[WritingViewController alloc] initWithOriginalDishId:_dish.dishId];
	writingViewController.delegate = self;
	DMNavigationController *navController = [[DMNavigationController alloc] initWithRootViewController:writingViewController];
	[self.navigationController presentViewController:navController animated:YES completion:NO];
}

- (void)backgroundDidTap
{
	[[self.view.gestureRecognizers objectAtIndex:0] setEnabled:NO];
	[_commentInput resignFirstResponder];
	
	[UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^
	{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
	} completion:nil];
}

- (void)profileImageButtonDidTouchUpInside
{
	ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
	[profileViewController loadUserId:_dish.userId];
	[self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)recipeButtonDidTouchUpInside
{	
	[self backgroundDidTap];
	
	RecipeViewerViewController *recipeView = [[RecipeViewerViewController alloc] initWithRecipe:_dish.recipe];
	recipeView.delegate = self;
	[UIView animateWithDuration:0.25 animations:^{
		_recipeButton.frame = CGRectMake( 0, 0, 320, 50 );
	}];
	
	[recipeView presentAfterDelay:0.1];
}

- (void)recipeViewerViewControllerDidDismiss:(RecipeViewerViewController *)recipeViewerViewController
{
	[UIView animateWithDuration:0.25 animations:^{
		_recipeButton.frame = CGRectMake( 0, 0, 320, 50 );
	}];
}

- (void)moreCommentsButtonDidTouchUpInside
{
	if( !_moreCommentsIndicatorView )
	{
		_moreCommentsIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[_moreCommentsIndicatorView startAnimating];
	}
	
	_moreCommentsIndicatorView.frame = CGRectMake( -1, [_moreCommentsButton convertPoint:_moreCommentsButton.frame.origin toView:self.view].y, 37, 37 );
	[self.view addSubview:_moreCommentsIndicatorView];
	
	[self loadComments];
}

- (void)commentInputDidBeginEditing
{
	[[self.view.gestureRecognizers objectAtIndex:0] setEnabled:YES];
	
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
	if( [CurrentUser user].loggedIn )
	{
		if( _commentInput.text.length == 0 || [_commentInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 )
			return;
		
		[self backgroundDidTap];
		[self sendComment];
	}
	else
	{
		[AuthViewController presentAuthViewControllerFromViewController:self delegate:self];
	}
}


#pragma mark -
#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
	DishDetailViewController *detailViewController = [[DishDetailViewController alloc] initWithDishId:_dish.forkedFromId dishName:_dish.forkedFromName];
	[self.navigationController pushViewController:detailViewController animated:YES];
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
#pragma mark CommentCellDelegate

- (void)commentCell:(CommentCell *)commentCell didTouchProfilePhotoViewAtIndexPath:(NSIndexPath *)indexPath
{
	ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
	[profileViewController loadUserId:[[_comments objectAtIndex:indexPath.row] userId]];
	[self.navigationController pushViewController:profileViewController animated:YES];
}


#pragma mark -
#pragma mark WritingViewControllerDelegate

- (void)writingViewControllerDidFinishUpload:(WritingViewController *)writingViewController
{
	JLLog( @"업로드 완료. Dish 재로드" );
	[self loadDishId:_dish.dishId];
}



#pragma mark -
#pragma mark AuthViewControllerDelegate

- (void)authViewControllerDidSucceedLogin:(AuthViewController *)authViewController
{
	JLLog( @"Login succeed" );
}



- (void)forkCountButtonDidTouchUpInside
{
	ForkListViewController *forkListViewController = [[ForkListViewController alloc] initWithDish:_dish];
	[self.navigationController pushViewController:forkListViewController animated:YES];
}

@end
