//
//  DMPhotoViewerViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 5. 14..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMPhotoViewerViewController.h"

@implementation DMPhotoViewerViewController

- (id)initWithPhotoURL:(NSURL *)url thumbnailImage:(UIImage *)thumbnailImage
{
	self = [super init];
	self.trackedViewName = [self.class description];
	self.view.backgroundColor = [UIColor clearColor];
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap)]];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, UIScreenWidth, UIScreenHeight )];
	_scrollView.delegate = self;
	_scrollView.minimumZoomScale = 1;
	_scrollView.maximumZoomScale = 2;
	_scrollView.userInteractionEnabled = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	_imageView = [[UIImageView alloc] init];
	_imageView.backgroundColor = [UIColor redColor];
	[_imageView setImageWithURL:url placeholderImage:thumbnailImage];
	[_scrollView addSubview:_imageView];
	
	CGFloat imageRatio = thumbnailImage.size.width / thumbnailImage.size.height;
	CGFloat scrollViewRatio = _scrollView.frame.size.width / _scrollView.frame.size.height;
	
	CGFloat maxWidth = _scrollView.frame.size.width;
	CGFloat maxHeight = _scrollView.frame.size.height;
	
	// 이미지의 가로 비율이 더 클 경우
	if( imageRatio > scrollViewRatio )
	{
		CGFloat height = thumbnailImage.size.height * maxWidth / thumbnailImage.size.width;
		_aspectFitRect = CGRectMake( 0, (maxHeight - height) / 2.0, maxWidth, height );
	}
	
	// 스크롤뷰의 세로 비율이 더 클 경우
	else if( imageRatio < scrollViewRatio )
	{
		CGFloat width = thumbnailImage.size.width * maxHeight / thumbnailImage.size.height;
		_aspectFitRect = CGRectMake( (maxWidth - width) / 2.0, 0, width, maxHeight );
	}
	
	// 이미지와 스크롤뷰의 가로 비율이 같을 경우
	else
	{
		_aspectFitRect = CGRectMake( 0, 0, maxWidth, maxHeight );
	}
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
	
	return self;
}

- (void)setOriginRect:(CGRect)originRect
{
	CGFloat scale = [UIScreen mainScreen].scale;
	CGFloat y = originRect.origin.y / scale;
	if( scale == 2.0 ) y -= 10;
	_originRect = CGRectMake( originRect.origin.x / scale, y, originRect.size.width / scale, originRect.size.height / scale );
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
			_imageView.frame = _aspectFitRect;
		} completion:^(BOOL finished) {
			_scrollView.userInteractionEnabled = YES;
		}];
	}];
}

- (void)viewDidTap
{
	_scrollView.userInteractionEnabled = NO;
	
	_imageView.frame = [self.view convertRect:_imageView.frame fromView:_scrollView];
	[_imageView removeFromSuperview];
	[self.view addSubview:_imageView];
	
	[UIView animateWithDuration:0.25 animations:^{
		_imageView.frame = _originRect;
		self.view.backgroundColor = [UIColor clearColor];
	} completion:^(BOOL finished) {
		[self dismissViewControllerAnimated:NO completion:nil];
	}];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)orientationDidChange:(NSNotification *)notification
{
	UIDevice * device = notification.object;
	CGAffineTransform transform;
	
	switch( device.orientation )
	{
		case UIDeviceOrientationPortrait:
			transform = CGAffineTransformMakeRotation( 0 );
			break;
			
		case UIDeviceOrientationLandscapeRight:
			transform = CGAffineTransformMakeRotation( 3 * M_PI_2 );
			break;
			
		case UIDeviceOrientationPortraitUpsideDown:
			transform = CGAffineTransformMakeRotation( M_PI );
			break;
			
		case UIDeviceOrientationLandscapeLeft:
			transform = CGAffineTransformMakeRotation( M_PI_2 );
			break;
			
		default:
			transform = CGAffineTransformMakeRotation( 0 );
			break;
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		_scrollView.zoomScale = 1.0;
		_scrollView.transform = transform;
		_scrollView.frame = CGRectMake( 0, 0, UIScreenWidth, UIScreenHeight );
		[self resetAspectFitRect];
	} completion:^(BOOL finished) {}];
}

- (void)resetAspectFitRect
{
	CGFloat scrollViewWidth, scrollViewHeight;
	
	switch( [UIDevice currentDevice].orientation )
	{
		case UIDeviceOrientationLandscapeRight:
		case UIDeviceOrientationLandscapeLeft:
			scrollViewWidth = _scrollView.frame.size.height;
			scrollViewHeight = _scrollView.frame.size.width;
			break;
			
		default:
			scrollViewWidth = _scrollView.frame.size.width;
			scrollViewHeight = _scrollView.frame.size.height;
			break;
	}
	
	CGFloat imageRatio = _imageView.image.size.width / _imageView.image.size.height;
	CGFloat scrollViewRatio = scrollViewWidth / scrollViewHeight;
	
	CGFloat maxWidth = scrollViewWidth;
	CGFloat maxHeight = scrollViewHeight;
	
	CGFloat x, y, width, height;
	
	// 이미지의 가로 비율이 더 클 경우
	if( imageRatio > scrollViewRatio )
	{
		width = maxWidth;
		height = _imageView.image.size.height * maxWidth / _imageView.image.size.width;
		x = 0;
		y = (maxHeight - height) / 2.0;
	}
	
	// 스크롤뷰의 세로 비율이 더 클 경우
	else if( imageRatio < scrollViewRatio )
	{
		width = _imageView.image.size.width * maxHeight / _imageView.image.size.height;
		height = maxHeight;
		x = (maxWidth - width) / 2.0;
		y = 0;
	}
	
	// 이미지와 스크롤뷰의 가로 비율이 같을 경우
	else
	{
		x = y = 0;
		width = maxWidth;
		height = maxHeight;
	}
	
	_aspectFitRect = CGRectMake( x, y, width, height );
	_imageView.frame = _aspectFitRect;
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	// Center the imageview.
	CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
	
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
	
	_imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
									scrollView.contentSize.height * 0.5 + offsetY);
}

@end
