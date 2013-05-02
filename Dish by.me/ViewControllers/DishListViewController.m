//
//  DishViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "DishListViewController.h"
#import "Dish.h"
#import "DishTileItem.h"
#import "DishDetailViewController.h"
#import "ProfileViewController.h"
#import "CurrentUser.h"
#import "UIButton+TouchAreaInsets.h"

@implementation DishListViewController

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:_tableView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake( 0, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height )];
	_refreshHeaderView.delegate = self;
	_refreshHeaderView.backgroundColor = self.view.backgroundColor;
	[_tableView addSubview:_refreshHeaderView];
	
	_progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"]];
	_progressView.frame = CGRectOffset( _progressView.frame, 0, -_progressView.frame.size.height );
	_progressView.userInteractionEnabled = YES;
	[self.view addSubview:_progressView];
	
	_progressBarBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake( 11, 16, 267, 11 )];
	_progressBarBackgroundView.image = [UIImage imageNamed:@"progress_bar_bg.png"];
	[_progressView addSubview:_progressBarBackgroundView];
	
	_progressBar = [[UIImageView alloc] initWithFrame:CGRectMake( 1, 1, 0, 8 )];
	_progressBar.image = [[UIImage imageNamed:@"progress_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 4, 0, 4 )];
	[_progressBarBackgroundView addSubview:_progressBar];
	
	_progressFailedLabel = [[UILabel alloc] init];
	_progressFailedLabel.text = NSLocalizedString( @"UPLOAD_FAILURE", @"업로드 실패" );
	_progressFailedLabel.textColor = [UIColor colorWithHex:0x8E8F8F alpha:1];
	_progressFailedLabel.backgroundColor = [UIColor clearColor];
	_progressFailedLabel.font = [UIFont boldSystemFontOfSize:14];
	_progressFailedLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.5];
	_progressFailedLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_progressFailedLabel sizeToFit];
	_progressFailedLabel.center = CGPointMake( 160, 22 );
	_progressFailedLabel.hidden = YES;
	[_progressView addSubview:_progressFailedLabel];
	
	// 업로드 실패시 왼쪽에 뜨는 X 버튼
	_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake( 10, 12, 20, 21 )];
	_cancelButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"progress_cancel_button.png"] forState:UIControlStateNormal];
	[_cancelButton addTarget:self action:@selector(cancelButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_progressView addSubview:_cancelButton];
	
	_progressButton = [[UIButton alloc] initWithFrame:CGRectMake( 289, 12, 20, 21 )];
	_progressButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_cancel_button.png"] forState:UIControlStateNormal];
	[_progressButton addTarget:self action:@selector(progressButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_progressView addSubview:_progressButton];
	
	_dishes = [[NSMutableArray alloc] init];
	
	self.navigationItem.title = @"Dish by.me";
	
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
//	[self updateDishes];
	[_tableView reloadData];
}


#pragma mark -
#pragma mark Loading

- (void)updateDishes
{
	JLLog( @"updateDishes" );
	
	_updating = YES;
	_loadedLastDish = NO;
	
	[[DMAPILoader sharedLoader] api:@"/dishes" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
		[_dishes removeAllObjects];
		
		NSArray *data = [response objectForKey:@"data"];
		_offset = data.count;
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		[_tableView reloadData];
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		_updating = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)loadMoreDishes
{
	JLLog( @"loadMoreDishes" );
	
	_loading = YES;
	
	NSDictionary *params = @{ @"offset": [NSString stringWithFormat:@"%d", _offset] };
	[[DMAPILoader sharedLoader] api:@"/dishes" method:@"GET" parameters:params success:^(id response) {
		JLLog( @"Success" );
		
		NSArray *data = [response objectForKey:@"data"];
		_offset += data.count;
		
		for( NSDictionary *d in data )
		{
			Dish *dish = [Dish dishFromDictionary:d];
			[_dishes addObject:dish];
		}
		
		if( data.count == 0 )
			_loadedLastDish = YES;
		
		[_tableView reloadData];
		
		_loading = NO;
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
		
		_loading = NO;
	}];
}

- (void)bookmarkDish:(Dish *)dish
{
	JLLog( @"bookmarkDish" );
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", dish.dishId];	
	[[DMAPILoader sharedLoader] api:api method:@"POST" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)unbookmarkDish:(Dish *)dish
{
	JLLog( @"unbookmarkDish" );
	
	NSString *api = [NSString stringWithFormat:@"/dish/%d/bookmark", dish.dishId];	
	[[DMAPILoader sharedLoader] api:api method:@"DELETE" parameters:nil success:^(id response) {
		JLLog( @"Success" );
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)refreshHeaerView
{
	[self updateDishes];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)refreshHeaerView
{
	return _updating;
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1 + !_loadedLastDish;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 1 ) return 1;
	return _dishes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 1 ) return 45;
	else if( indexPath.row == _dishes.count - 1 ) return 355;
	return 345;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"dishCell";
	
	if( indexPath.section == 0 )
	{
		DishListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if( !cell )
		{
			cell = [[DishListCell alloc] initWithReuseIdentifier:cellId];
			cell.delegate = self;
		}
		
		Dish *dish = [_dishes objectAtIndex:indexPath.row];
		[cell setDish:dish atIndexPath:indexPath];
		
		return cell;
	}
	else
	{
		static NSString *activityIndicatorCellId = @"activityIndicatorCellId";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:activityIndicatorCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:activityIndicatorCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		indicator.frame = CGRectMake( 141, 0, 37, 37 );
		[indicator startAnimating];
		[cell.contentView addSubview:indicator];
		
		if( !_loading )
			[self loadMoreDishes];
		
		return cell;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self showUserPhoto];
	[_scrollTimer invalidate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
	_scrollTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(hideUserPhoto) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:_scrollTimer forMode:NSDefaultRunLoopMode];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	[_scrollTimer invalidate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_scrollTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(hideUserPhoto) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:_scrollTimer forMode:NSDefaultRunLoopMode];
}

- (void)showUserPhoto
{
	for( DishListCell *cell in [_tableView visibleCells] )
	{
		if( cell.indexPath.section == 0 )
		{
			[UIView animateWithDuration:0.25 animations:^{
				cell.topGradientView.alpha = 1;
				cell.userPhotoButton.alpha = 1;
				cell.userNameLabel.alpha = 1;
			}];
		}
	}
}

- (void)hideUserPhoto
{
	for( DishListCell *cell in [_tableView visibleCells] )
	{
		if( cell.indexPath.section == 0 )
		{
			[UIView animateWithDuration:0.25 animations:^{
				cell.topGradientView.alpha = 0;
				cell.userPhotoButton.alpha = 0;
				cell.userNameLabel.alpha = 0;
			}];
		}
	}
}


#pragma mark -
#pragma mark DishListCellDelegate

- (void)dishListCell:(DishListCell *)dishListCell didTouchPhotoViewAtIndexPath:(NSIndexPath *)indexPath
{
	DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] initWithDish:[_dishes objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:dishDetailViewController animated:YES];
}

- (void)dishListCell:(DishListCell *)dishListCell didTouchUserPhotoButtonAtIndexPath:(NSIndexPath *)indexPath
{
	Dish *dish = [_dishes objectAtIndex:indexPath.row];
	
	ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
	[profileViewController loadUserId:dish.userId];
	[self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)dishListCell:(DishListCell *)dishListCell didBookmarkAtIndexPath:(NSIndexPath *)indexPath
{
	[self bookmarkDish:[_dishes objectAtIndex:indexPath.row]];
}

- (void)dishListCell:(DishListCell *)dishListCell didUnbookmarkAtIndexPath:(NSIndexPath *)indexPath
{
	[self unbookmarkDish:[_dishes objectAtIndex:indexPath.row]];
}


#pragma mark -
#pragma mark WritingViewControllerDelegate

- (void)writingViewController:(WritingViewController *)writingViewController willBeginUploadWithBlock:(void (^)(void))uploadBlock
{
	_progressState = DMProgressStateLoading;
	_uploadBlock = uploadBlock;
	
	_progressBarBackgroundView.hidden = NO;
	_progressFailedLabel.hidden = YES;
	_cancelButton.hidden = YES;
	_progressButton.adjustsImageWhenHighlighted = YES;
	
	[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_cancel_button.png"] forState:UIControlStateNormal];
	
	[UIView animateWithDuration:0.25 animations:^{
		CGRect frame = _progressView.frame;
		frame.origin.y = 0;
		_progressView.frame = frame;
		
		_tableView.frame = CGRectMake( 0, 44, 320, UIScreenHeight - 158 );
	}];
}

- (void)writingViewController:(WritingViewController *)writingViewController bytesUploaded:(long long)bytesUploaded bytesTotal:(long long)bytesTotal
{
	CGRect frame = _progressBar.frame;
	frame.size.width = 265.0 * bytesUploaded / bytesTotal;
	_progressBar.frame = frame;
}

- (void)writingViewControllerDidFailedUpload:(WritingViewController *)writingViewController
{
	_progressState = DMProgressStateFailure;
	
	_progressBarBackgroundView.hidden = YES;
	_progressFailedLabel.hidden = NO;
	_cancelButton.hidden = NO;
	
	[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_retry_button.png"] forState:UIControlStateNormal];
}

- (void)writingViewControllerDidFinishUpload:(WritingViewController *)writingViewController
{
	_progressState = DMProgressStateIdle;
	_uploadBlock = nil;
	
	_progressButton.adjustsImageWhenHighlighted = NO;
	[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_check_icon.png"] forState:UIControlStateNormal];
	
	dispatch_async( dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:0.25 delay:1 options:0 animations:^{
			CGRect frame = _progressView.frame;
			frame.origin.y = -_progressView.frame.size.height;
			_progressView.frame = frame;
			
			_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
			
			[self updateDishes];
		} completion:nil];
	} );
}

- (void)progressButtonDidTouchUpInside
{
	// 업로드 취소
	if( _progressState == DMProgressStateLoading )
	{
		[self cancelButtonDidTouchUpInside];
	}
	
	// 다시 시도
	else if( _progressState == DMProgressStateFailure )
	{
		_uploadBlock();
	}
}

- (void)cancelButtonDidTouchUpInside
{
	_progressState = DMProgressStateIdle;
	_uploadBlock = nil;
	
	dispatch_async( dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:0.25 animations:^{
			CGRect frame = _progressView.frame;
			frame.origin.y = -_progressView.frame.size.height;
			_progressView.frame = frame;
			
			_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 114 );
		}];
	} );
}

@end
