//
//  RecipeEditorView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeEditorViewController.h"
#import "UIResponder+Dim.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_RECIPE_COUNT 20
#define DRAGGING_RECIPE_ALPHA 0.8
#define DRAGGING_RECIPE_SCALE 1.02
#define REMOVING_RECIPE_SCALE 0.3

@implementation RecipeEditorViewController

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super init];
	self.trackedViewName = [self.class description];
	
	_recipe = recipe ? recipe : [[Recipe alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 8, 0, 304, DMRecipeHeight )];
	_scrollView.center = CGPointMake( _scrollView.center.x, UIScreenHeight / 2 - 20 );
	_scrollView.delegate = self;
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_infoEditorView = [[RecipeInfoEditorView alloc] initWithRecipe:_recipe];
	_infoEditorView.frame = CGRectMake( -2, 0, 304, DMRecipeHeight );
	[_infoEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[_infoEditorView setCurrentPage:0 numberOfPages:_recipe.contents.count + 1];
	[_scrollView addSubview:_infoEditorView];
	
	_contentEditorViews = [NSMutableArray array];
	for( NSInteger i = 0; i < _recipe.contents.count; i++ )
	{
		RecipeContentEditorView *contentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:[_recipe.contents objectAtIndex:i]];
		contentEditorView.frame = CGRectMake( -2 + 304 * ( i + 1 ), 0, 304, DMRecipeHeight );
		contentEditorView.originalLocation = contentEditorView.frame.origin;
		[contentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDown:touchEvent:) forControlEvents:UIControlEventTouchDown];
		[contentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDrag:touchEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
		[contentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
		[contentEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		[contentEditorView.photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[contentEditorView setCurrentPage:i + 1 numberOfPages:_recipe.contents.count + 1];
		[_scrollView addSubview:contentEditorView];
		[_contentEditorViews addObject:contentEditorView];
	}
	
	_scrollView.contentSize = CGSizeMake( _recipe.contents.count == 0 ? 305 : 304 * ( _recipe.contents.count + 1 ), DMRecipeHeight );
	
	_newContentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:nil];
	_newContentEditorView.frame = CGRectOffset( _newContentEditorView.frame, UIScreenWidth, 0 );
	[self.view addSubview:_newContentEditorView];
	
	_openingAnimations = [NSMutableArray array];
	_closingAnimations = [NSMutableArray array];
	_throwingAnimations = [NSMutableArray array];
	
	for( NSInteger i = 1; i <= 20; i++ )
	{
		NSString *imageName = [NSString stringWithFormat:@"recipe_bin_%04d.png", i];
		[_openingAnimations addObject:[UIImage imageNamed:imageName]];
	}
	
	for( NSInteger i = 19; i >= 0; i-- )
	{
		UIImage *image = [_openingAnimations objectAtIndex:i];
		[_closingAnimations addObject:image];
	}
	
	for( NSInteger i = 21; i <= 50; i++ )
	{
		NSString *imageName = [NSString stringWithFormat:@"recipe_bin_%04d.png", i];
		[_throwingAnimations addObject:[UIImage imageNamed:imageName]];
	}
	
	_binView = [[UIImageView alloc] initWithFrame:CGRectMake( 110, UIScreenHeight, 100, 100 )];
	_binView.image = [_openingAnimations objectAtIndex:0];
	_binView.animationDuration = 0.33;
	_binView.animationRepeatCount = 1;
	_binView.alpha = 0;
	[[UIApplication sharedApplication].keyWindow addSubview:_binView];
	
	return self;
}

- (void)presentAnimation
{
	_scrollView.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
	
	[UIView animateWithDuration:0.4 animations:^{
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
		_scrollView.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 - 20 );
	}];
}

- (void)dismiss
{
	[self.view endEditing:YES];
	[self.delegate recipeEditorViewControllerWillDismiss:self];
	[UIView animateWithDuration:0.4 animations:^{
		_scrollView.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
	} completion:^(BOOL finished) {
		[self dismissViewControllerAnimated:NO completion:nil];
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	}];
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.delegate recipeEditorViewControllerDidDismiss:self];
	});
}

- (void)animateRecipes
{
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[scrollView endEditing:YES];
	
	CGFloat offset = scrollView.contentOffset.x;
	UIView *lastView = [_contentEditorViews lastObject];
	if( !lastView ) lastView = _infoEditorView;
	
	// 추가되기 전 : _newContentEditorView
	if( scrollView.scrollEnabled )
	{
		CGRect lastViewFrame = [scrollView convertRect:lastView.frame toView:self.view];
		_newContentEditorView.frame = CGRectOffset( lastViewFrame, 304, 0 );
		
		if( offset >= _scrollView.contentSize.width - 304 )
		{
			_newContentEditorView.hidden = NO;
			
			CGFloat angle = M_PI * ( offset - 304 * (_contentEditorViews.count + 1) ) / 608.0;
			CATransform3D transform = CATransform3DMakeRotation( angle, 0, 1, 0 );
			transform.m34 = -1 / 500.0;
			transform.m14 = -angle / 500;
			_newContentEditorView.layer.transform = transform;
		}
		else
		{
			_newContentEditorView.hidden = YES;
		}
	}
	
	// 추가되는 중 : lastView
	else
	{
		CGFloat angle = M_PI * ( offset - 304 * _contentEditorViews.count ) / 608.0;
		CATransform3D transform = CATransform3DMakeRotation( angle, 0, 1, 0 );
		transform.m34 = -1 / 500.0;
		transform.m14 = -angle / 500;
		lastView.layer.transform = transform;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if( _recipe.contents.count >= MAX_RECIPE_COUNT )
		return;
	
	CGFloat offset = scrollView.contentOffset.x;
	if( offset > _scrollView.contentSize.width - 304 + 60 )
	{
		JLLog( @"Added RecipeContentEditorView" );
		
		scrollView.scrollEnabled = NO;
		
		RecipeContent *newContent = [[RecipeContent alloc] init];
		[_recipe.contents addObject:newContent];
		
		RecipeContentEditorView *newContentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:newContent];
		newContentEditorView.layer.transform = _newContentEditorView.layer.transform;
		newContentEditorView.frame = CGRectMake( -2 + 304 * _recipe.contents.count, 0, 304, DMRecipeHeight );
		newContentEditorView.originalLocation = newContentEditorView.frame.origin;
		[newContentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDown:touchEvent:) forControlEvents:UIControlEventTouchDown];
		[newContentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDrag:touchEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
		[newContentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
		[newContentEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		[newContentEditorView.photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		_scrollView.contentSize = CGSizeMake( 304 * ( _recipe.contents.count + 1 ), DMRecipeHeight );
		[_scrollView addSubview:newContentEditorView];
		
		[_contentEditorViews addObject:newContentEditorView];
		
		[_infoEditorView setCurrentPage:0 numberOfPages:_recipe.contents.count + 1];
		for( NSInteger i = 0; i < _recipe.contents.count ; i++ )
		{
			RecipeContentEditorView *contentEditorView = [_contentEditorViews objectAtIndex:i];
			[contentEditorView setCurrentPage:i + 1 numberOfPages:_recipe.contents.count + 1];
		}
		
		if( _recipe.contents.count < MAX_RECIPE_COUNT )
		{
			_newContentEditorView.layer.transform = CATransform3DIdentity;
			_newContentEditorView.frame = CGRectOffset( _newContentEditorView.frame, UIScreenWidth, 0 );
		}
		else
		{
			_newContentEditorView.hidden = YES;
		}
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if( !scrollView.scrollEnabled )
	{
		scrollView.scrollEnabled = NO;
		
		RecipeContentEditorView *lastAddedContentEditorView = [_contentEditorViews lastObject];
		[scrollView setContentOffset:CGPointMake( lastAddedContentEditorView.frame.origin.x + 2, 0 ) animated:YES];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if( !scrollView.scrollEnabled )
	{
		scrollView.scrollEnabled = YES;
		
		RecipeContentEditorView *lastAddedContentEditorView = [_contentEditorViews lastObject];
		lastAddedContentEditorView.layer.transform = CATransform3DIdentity;
	}
}


#pragma mark -
#pragma mark RecipeContentEditorView

- (void)grabButtonDidTouchDown:(UIButton *)grabButton touchEvent:(UIEvent *)touchEvent
{
	_currentDraggingContentEditorView = (RecipeContentEditorView *)grabButton.superview;
	[[UIApplication sharedApplication].keyWindow addSubview:_currentDraggingContentEditorView];
	[[UIApplication sharedApplication].keyWindow bringSubviewToFront:_binView];
	
	CGPoint point = [touchEvent.allTouches.anyObject locationInView:[UIApplication sharedApplication].keyWindow];
	_currentDraggingContentEditorView.center = CGPointMake( point.x - 27, _currentDraggingContentEditorView.center.y + self.view.frame.origin.y );
	
	[UIView animateWithDuration:0.25 animations:^{
		_currentDraggingContentEditorView.transform = CGAffineTransformScale( CGAffineTransformIdentity, DRAGGING_RECIPE_SCALE, DRAGGING_RECIPE_SCALE );
		_currentDraggingContentEditorView.alpha = DRAGGING_RECIPE_ALPHA;
		
		_binView.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight - _binView.frame.size.height + 30 );
		_binView.alpha = 1;
	}];
}

- (void)grabButtonDidTouchDrag:(UIButton *)grabButton touchEvent:(UIEvent *)touchEvent
{
	RecipeContentEditorView *editorView = (RecipeContentEditorView *)grabButton.superview;
	
	CGPoint point = [touchEvent.allTouches.anyObject locationInView:[UIApplication sharedApplication].keyWindow];
	CGFloat scale = REMOVING_RECIPE_SCALE + ( point.y - _binView.frame.origin.y ) * ( DRAGGING_RECIPE_SCALE - REMOVING_RECIPE_SCALE ) / ( UIScreenHeight / 2 - _binView.frame.origin.y );
	if( scale > DRAGGING_RECIPE_SCALE ) scale = DRAGGING_RECIPE_SCALE;
	else if( scale < REMOVING_RECIPE_SCALE ) scale = REMOVING_RECIPE_SCALE;
	editorView.transform = CGAffineTransformMakeScale( scale, scale );
	
	CGFloat x = point.x - scale * 27;
	CGFloat y = point.y + scale * ( DMRecipeHeight / 2 - 34 );
	editorView.center = CGPointMake( x, y );
	
	if( point.x < 20 )
	{
		if( !_pagingTimer )
		{
			_pagingTimer = [NSTimer timerWithTimeInterval:0.7 target:self selector:@selector(prevPage) userInfo:nil repeats:NO];
			[[NSRunLoop mainRunLoop] addTimer:_pagingTimer forMode:NSDefaultRunLoopMode];
		}
	}
	else if( point.x > 300 )
	{
		if( !_pagingTimer )
		{
			_pagingTimer = [NSTimer timerWithTimeInterval:0.7 target:self selector:@selector(nextPage) userInfo:nil repeats:NO];
			[[NSRunLoop mainRunLoop] addTimer:_pagingTimer forMode:NSDefaultRunLoopMode];
		}
	}
	else if( CGRectContainsPoint( _binView.frame, point ) )
	{
		if( !_isDraggingRecipeOnBin )
		{
			_isDraggingRecipeOnBin = YES;
			
			_binView.image = [_openingAnimations lastObject];
			_binView.animationImages = _openingAnimations;
			_binView.animationDuration = 0.33;
			[_binView startAnimating];
		}
	}
	else
	{
		[_pagingTimer invalidate];
		_pagingTimer = nil;
		
		if( _isDraggingRecipeOnBin )
		{
			_isDraggingRecipeOnBin = NO;
			
			_binView.image = [_openingAnimations objectAtIndex:0];
			_binView.animationImages = _closingAnimations;
			_binView.animationDuration = 0.33;
			[_binView startAnimating];
		}
	}
}

- (void)grabButtonDidTouchUp:(UIButton *)grabButton
{
	[_pagingTimer invalidate];
	_pagingTimer = nil;
	
	RecipeContentEditorView *editorView = (RecipeContentEditorView *)grabButton.superview;
	
	// 버리기
	if( _isDraggingRecipeOnBin )
	{
		_isDraggingRecipeOnBin = NO;
		
		NSInteger index = [_contentEditorViews indexOfObject:editorView];
		[_contentEditorViews removeObjectAtIndex:index];
		[_recipe.contents removeObjectAtIndex:index];
		
		
		
		[UIView animateWithDuration:0.25 animations:^{
			editorView.center = CGPointMake( 153, UIScreenHeight - 95 );
			editorView.transform = CGAffineTransformMakeScale( 0.04, 0.04 );
			editorView.alpha = 0.6;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.2 animations:^{
				editorView.center = CGPointMake( 153, UIScreenHeight - 80 );
				editorView.alpha = 0;
			}];
			
			_binView.image = [_openingAnimations objectAtIndex:0];
			_binView.animationImages = _throwingAnimations;
			_binView.animationDuration = 0.5;
			[_binView startAnimating];
		
		
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[UIView animateWithDuration:0.25 animations:^{
				editorView.alpha = 0;
				
				_scrollView.contentSize = CGSizeMake( _recipe.contents.count == 0 ? 305 : 304 * ( _recipe.contents.count + 1 ), DMRecipeHeight );
				
				[_infoEditorView setCurrentPage:0 numberOfPages:_recipe.contents.count + 1];
				for( NSInteger i = 0; i < _recipe.contents.count; i++ )
				{
					RecipeContentEditorView *contentEditorView = [_contentEditorViews objectAtIndex:i];
					contentEditorView.frame = CGRectMake( -2 + 304 * ( i + 1 ), 0, 304, DMRecipeHeight );
					contentEditorView.originalLocation = contentEditorView.frame.origin;
					[contentEditorView setCurrentPage:i + 1 numberOfPages:_recipe.contents.count + 1];
				}
				
				_binView.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight + _binView.frame.size.height / 2 );
				_binView.alpha = 0;
			}];
		});
			
			}];
	}
	else
	{
		editorView.center = [[UIApplication sharedApplication].keyWindow convertPoint:editorView.center toView:_scrollView];
		[_scrollView addSubview:editorView];
		
		[UIView animateWithDuration:0.25 animations:^{
			editorView.transform = CGAffineTransformScale( CGAffineTransformIdentity, 1, 1 );
			editorView.alpha = 1;
			
			CGRect frame = editorView.frame;
			frame.origin = editorView.originalLocation;
			editorView.frame = frame;
			
			_binView.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight + _binView.frame.size.height / 2 );
			_binView.alpha = 0;
		}];
	}
}

- (void)prevPage
{
	[_pagingTimer invalidate];
	_pagingTimer = nil;
	
	NSInteger currentDraggingEditorViewIndex = [_contentEditorViews indexOfObject:_currentDraggingContentEditorView];
	if( currentDraggingEditorViewIndex == 0 )
	{
		return;
	}
	
	// 스크롤뷰 스크롤
	[_scrollView setContentOffset:CGPointMake( _scrollView.contentOffset.x - 304, _scrollView.contentOffset.y ) animated:YES];
	
	// 레시피 전환 애니메이션
	NSInteger targetEditorViewIndex = currentDraggingEditorViewIndex - 1;
	RecipeContentEditorView *targetEditorView = [_contentEditorViews objectAtIndex:targetEditorViewIndex];
	_currentDraggingContentEditorView.originalLocation = targetEditorView.frame.origin;
	
	[UIView animateWithDuration:0.25 delay:0.5 options:0 animations:^{
		CGRect frame = targetEditorView.frame;
		frame.origin.x += 304;
		targetEditorView.frame = frame;
		targetEditorView.originalLocation = frame.origin;
	} completion:nil];
	
	[targetEditorView setCurrentPage:currentDraggingEditorViewIndex + 1 numberOfPages:_recipe.contents.count + 1];
	[_currentDraggingContentEditorView setCurrentPage:targetEditorViewIndex + 1 numberOfPages:_recipe.contents.count + 1];
	
	// 실제 데이터 교환
	JLLog( @"드래그중인 %d를 %d와 교환", currentDraggingEditorViewIndex, targetEditorViewIndex );
	[_recipe.contents exchangeObjectAtIndex:currentDraggingEditorViewIndex withObjectAtIndex:targetEditorViewIndex];
	[_contentEditorViews exchangeObjectAtIndex:currentDraggingEditorViewIndex withObjectAtIndex:targetEditorViewIndex];
	
	// 계속 제자리에 올려놓고 있으면 쭉 넘어가게
	_pagingTimer = [NSTimer timerWithTimeInterval:0.7 target:self selector:@selector(prevPage) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:_pagingTimer forMode:NSDefaultRunLoopMode];
}

- (void)nextPage
{
	[_pagingTimer invalidate];
	_pagingTimer = nil;
	
	NSInteger currentDraggingEditorViewIndex = [_contentEditorViews indexOfObject:_currentDraggingContentEditorView];
	if( currentDraggingEditorViewIndex == _contentEditorViews.count - 1 )
	{
		return;
	}
	
	// 스크롤뷰 스크롤
	[_scrollView setContentOffset:CGPointMake( _scrollView.contentOffset.x + 304, _scrollView.contentOffset.y ) animated:YES];
	
	// 레시피 전환 애니메이션
	NSInteger targetEditorViewIndex = currentDraggingEditorViewIndex + 1;
	RecipeContentEditorView *targetEditorView = [_contentEditorViews objectAtIndex:targetEditorViewIndex];
	_currentDraggingContentEditorView.originalLocation = targetEditorView.frame.origin;
	
	[UIView animateWithDuration:0.25 delay:0.5 options:0 animations:^{
		CGRect frame = targetEditorView.frame;
		frame.origin.x -= 304;
		targetEditorView.frame = frame;
		targetEditorView.originalLocation = frame.origin;
	} completion:nil];
	
	[targetEditorView setCurrentPage:currentDraggingEditorViewIndex + 1 numberOfPages:_recipe.contents.count + 1];
	[_currentDraggingContentEditorView setCurrentPage:targetEditorViewIndex + 1 numberOfPages:_recipe.contents.count + 1];
	
	// 실제 데이터 교환
	JLLog( @"드래그중인 %d를 %d와 교환", currentDraggingEditorViewIndex, targetEditorViewIndex );
	[_recipe.contents exchangeObjectAtIndex:currentDraggingEditorViewIndex withObjectAtIndex:targetEditorViewIndex];
	[_contentEditorViews exchangeObjectAtIndex:currentDraggingEditorViewIndex withObjectAtIndex:targetEditorViewIndex];
	
	// 계속 제자리에 올려놓고 있으면 쭉 넘어가게
	_pagingTimer = [NSTimer timerWithTimeInterval:0.7 target:self selector:@selector(nextPage) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:_pagingTimer forMode:NSDefaultRunLoopMode];
}

- (void)photoButtonDidTouchUpInside:(UIButton *)photoButton
{
	[[[UIActionSheet alloc] initWithTitle:nil cancelButtonTitle:NSLocalizedString( @"CANCEL", @"" ) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString( @"TAKE_A_PHOTO", @"" ), NSLocalizedString( @"FROM_LIBRARY", @"" )] dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
		
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		
		if( buttonIndex == 0 ) // Camera
		{
			@try
			{
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			}
			@catch( NSException *exception )
			{
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", @"" ) message:NSLocalizedString( @"MESSAGE_NO_SUPPORT_CAMERA", @"" ) delegate:self cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"" ) otherButtonTitles:nil] show];
				return;
			}
			
			picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
		}
		else if( buttonIndex == 1 ) // Album
		{
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		}
		else
		{
			return;
		}
		
		[picker setFinishBlock:^(UIImagePickerController *picker, NSDictionary *info) {
			[picker dismissViewControllerAnimated:YES completion:nil];
			
			UIImage *image = [Utils scaleAndRotateImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
			
			// 카메라로 찍은 경우 앨범에 저장
			if( picker.sourceType == UIImagePickerControllerSourceTypeCamera )
				UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
			
			RecipeContentEditorView *contentEditorView = (RecipeContentEditorView *)photoButton.superview.superview;
			[contentEditorView setPhotoButtonImage:image];
			
			// 새로운 사진을 선택했을 경우에는 photoURL을 nil로 만들어 사진 바이너리를 업로드시키도록 함
			contentEditorView.content.photoURL = nil;
			
			// 텍스트가 입력되지 않았으면 사진 선택 후 텍스트뷰 포커싱
			if( contentEditorView.textView.text.length == 0 )
				[contentEditorView.textView becomeFirstResponder];
		}];
		
		[picker setCancelBlock:^(UIImagePickerController *picker) {
			[picker dismissModalViewControllerAnimated:YES];
		}];
		
		[self presentViewController:picker animated:YES completion:nil];
	}] showInView:self.view];
}

@end
