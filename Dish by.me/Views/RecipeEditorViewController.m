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

@implementation RecipeEditorViewController

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super init];
	self.trackedViewName = [self.class description];
	
	_recipe = recipe ? recipe : [[Recipe alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 8, 0, 304, UIScreenHeight - 30 )];
	_scrollView.delegate = self;
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_infoEditorView = [[RecipeInfoEditorView alloc] initWithRecipe:_recipe];
	_infoEditorView.frame = CGRectMake( -2, 0, 304, UIScreenHeight - 30 );
	[_infoEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_infoEditorView];
	
	_contentEditorViews = [NSMutableArray array];
	for( NSInteger i = 0; i < _recipe.contents.count ; i++ )
	{
		RecipeContentEditorView *contentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:[_recipe.contents objectAtIndex:i]];
		contentEditorView.frame = CGRectMake( -2 + 304 * ( i + 1 ), 0, 304, UIScreenHeight - 30 );
		contentEditorView.originalLocation = contentEditorView.frame.origin;
		[contentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDown:touchEvent:) forControlEvents:UIControlEventTouchDown];
		[contentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDrag:touchEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
		[contentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
		[contentEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		[contentEditorView.photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:contentEditorView];
		[_contentEditorViews addObject:contentEditorView];
	}
	
	_scrollView.contentSize = CGSizeMake( _recipe.contents.count == 0 ? 305 : 304 * ( _recipe.contents.count + 1 ), UIScreenHeight - 30 );
	
	_newContentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:nil];
	_newContentEditorView.frame = CGRectOffset( _newContentEditorView.frame, UIScreenWidth, 0 );
	[self.view addSubview:_newContentEditorView];
	
	return self;
}

- (void)presentAfterDelay:(NSTimeInterval)delay
{
	NSTimeInterval duration = 0.4;
	
	[self dimWithDuration:duration completion:nil];
	
	self.view.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
	
	[UIView animateWithDuration:duration delay:delay options:0 animations:^{
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
		[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
		
		self.view.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 + 10 );
		
	} completion:^(BOOL finished) {
		[self animateRecipes];
		[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
	}];
}

- (void)dismiss
{
	NSTimeInterval duration = 0.4;
	
	if( [self.delegate respondsToSelector:@selector(recipeEditorViewControllerWillDismiss:)] )
		[self.delegate recipeEditorViewControllerWillDismiss:self];
	
	[self.view endEditing:YES];
	[self undimWithDuration:duration completion:nil];
	
	[UIView animateWithDuration:duration animations:^{
		self.view.center = CGPointMake( UIScreenWidth / 2, -UIScreenHeight / 2 );
		
	} completion:^(BOOL finished) {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
		[self.view removeFromSuperview];
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
			CGFloat angle = M_PI * ( offset - 304 * (_contentEditorViews.count + 1) ) / 608.0;
			CATransform3D transform = CATransform3DMakeRotation( angle, 0, 1, 0 );
			transform.m34 = -1 / 500.0;
			transform.m14 = -angle / 500;
			_newContentEditorView.layer.transform = transform;
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
	CGFloat offset = scrollView.contentOffset.x;
	if( offset > _scrollView.contentSize.width - 304 + 60 )
	{
		JLLog( @"Added RecipeContentEditorView" );
		
		scrollView.scrollEnabled = NO;
		
		RecipeContent *newContent = [[RecipeContent alloc] init];
		[_recipe.contents addObject:newContent];
		
		RecipeContentEditorView *newContentEditorView = [[RecipeContentEditorView alloc] initWithRecipeContent:newContent];
		newContentEditorView.layer.transform = _newContentEditorView.layer.transform;
		newContentEditorView.frame = CGRectMake( -2 + 304 * _recipe.contents.count, 0, 304, UIScreenHeight - 30 );
		newContentEditorView.originalLocation = newContentEditorView.frame.origin;
		[newContentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDown:touchEvent:) forControlEvents:UIControlEventTouchDown];
		[newContentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchDrag:touchEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
		[newContentEditorView.grabButton addTarget:self action:@selector(grabButtonDidTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
		[newContentEditorView.checkButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		[newContentEditorView.photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		_scrollView.contentSize = CGSizeMake( 304 * ( _recipe.contents.count + 1 ), UIScreenHeight - 30 );
		[_scrollView addSubview:newContentEditorView];
		
		[_contentEditorViews addObject:newContentEditorView];
		
		_newContentEditorView.layer.transform = CATransform3DIdentity;
		_newContentEditorView.frame = CGRectOffset( _newContentEditorView.frame, UIScreenWidth, 0 );
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
	
	CGPoint point = [touchEvent.allTouches.anyObject locationInView:[UIApplication sharedApplication].keyWindow];
	_currentDraggingContentEditorView.center = CGPointMake( point.x - 27, _currentDraggingContentEditorView.center.y + self.view.frame.origin.y );
	
	[UIView animateWithDuration:0.25 animations:^{
		_currentDraggingContentEditorView.transform = CGAffineTransformScale( CGAffineTransformIdentity, 1.02, 1.02 );
		_currentDraggingContentEditorView.alpha = 0.9;
	}];
}

- (void)grabButtonDidTouchDrag:(UIButton *)grabButton touchEvent:(UIEvent *)touchEvent
{
	RecipeContentEditorView *editorView = (RecipeContentEditorView *)grabButton.superview;
	
	CGPoint point = [touchEvent.allTouches.anyObject locationInView:[UIApplication sharedApplication].keyWindow];
	editorView.center = CGPointMake( point.x - 27, editorView.center.y );
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
	else
	{
		[_pagingTimer invalidate];
		_pagingTimer = nil;
	}
}

- (void)grabButtonDidTouchUp:(UIButton *)grabButton
{
	[_pagingTimer invalidate];
	_pagingTimer = nil;
	
	RecipeContentEditorView *editorView = (RecipeContentEditorView *)grabButton.superview;
	editorView.center = [[UIApplication sharedApplication].keyWindow convertPoint:editorView.center toView:_scrollView];
	[_scrollView addSubview:editorView];
	
	[UIView animateWithDuration:0.25 animations:^{
		editorView.transform = CGAffineTransformScale( CGAffineTransformIdentity, 1, 1 );
		editorView.alpha = 1;
		
		CGRect frame = editorView.frame;
		frame.origin = editorView.originalLocation;
		editorView.frame = frame;
	}];
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
	
	// 실제 데이터 교환
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
	
	// 실제 데이터 교환
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
			
			[photoButton setImage:image forState:UIControlStateNormal];
			CGRect frame = photoButton.frame;
			frame.size.height = floorf( 241 * image.size.height / image.size.width );
			photoButton.frame = frame;
			
			// 텍스트가 입력되지 않았으면 사진 선택 후 텍스트뷰 포커싱
			RecipeContentEditorView *contentEditorView = (RecipeContentEditorView *)photoButton.superview.superview;
			if( contentEditorView.textView.text.length == 0 )
				[contentEditorView.textView becomeFirstResponder];
		}];
		
		[self presentViewController:picker animated:YES completion:nil];
	}] showInView:self.view];
}

@end
