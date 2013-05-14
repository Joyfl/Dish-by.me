//
//  DMPhotoViewerViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 5. 14..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMPhotoViewerViewController.h"

@implementation DMPhotoViewerViewController

- (id)init
{
	self = [super init];
	self.view.backgroundColor = [UIColor clearColor];
	self.trackedViewName = [self.class description];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, UIScreenWidth, UIScreenHeight - 20 )];
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	[_scrollView addSubview:_imageView];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	if( !CGRectEqualToRect( _originRect, CGRectZero ) )
	{
		_imageView.frame = _originRect;
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		self.view.backgroundColor = [UIColor blackColor];
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^{
			_imageView.frame = _scrollView.bounds;
		}];
	}];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
}

@end
