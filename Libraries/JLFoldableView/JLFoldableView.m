//
//  JLFoldable.m
//  JLFoldableView
//
//  Created by 전수열 on 13. 1. 11..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "JLFoldableView.h"
#import "UIView+Screenshot.h"
#import <QuartzCore/CALayer.h>

@implementation JLFoldableView

- (id)init
{
	return self = [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
	// Eanble perspective transform.
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = -1 / 500.0;
	[self.layer setSublayerTransform:transform];
	
	_topViews = [[NSMutableArray alloc] init];
	_bottomViews = [[NSMutableArray alloc] init];
	
	_topGradientLayers = [[NSMutableArray alloc] init];
	_bottomGradientLayers = [[NSMutableArray alloc] init];
	
	_topShadowViews = [[NSMutableArray alloc] init];
	_bottomShadowViews = [[NSMutableArray alloc] init];
	
	self.foldCount = 1;
	self.fraction = 1;
	
	return self;
}


#pragma mark Getter/Setter

- (UIView *)contentView
{
	return _contentView;
}

- (void)setContentView:(UIView *)contentView
{
	CGFloat originalFraction = _fraction;
	if( originalFraction < 1 )
		self.fraction = 1;
	
	_contentView = [contentView retain];
	[self addSubview:_contentView];
	[_contentView release];
	
	UIImage *image = [_contentView screenshot];
	for( NSInteger i = 0; i < _foldCount; i++ )
	{
		UIView *topView = [_topViews objectAtIndex:i];
		topView.layer.anchorPoint = CGPointMake( 0.5, 0 );
		topView.frame = CGRectMake( 0, _contentView.frame.size.height * ( i * 2 ) / ( 2 * _foldCount ), _contentView.frame.size.width, _contentView.frame.size.height / ( 2 * _foldCount ) );
		
		UIView *bottomView = [_bottomViews objectAtIndex:i];
		bottomView.layer.anchorPoint = CGPointMake( 0.5, 1 );
		bottomView.frame = CGRectMake( 0, _contentView.frame.size.height * ( i * 2 + 1 ) / ( 2 * _foldCount ), _contentView.frame.size.width, _contentView.frame.size.height / ( 2 * _foldCount ) );
		
		CGFloat imageHeight = image.size.height * image.scale / ( 2 * _foldCount );
		CGImageRef topImage = CGImageCreateWithImageInRect( [image CGImage], CGRectMake( 0, imageHeight * i * 2, image.size.width * image.scale, imageHeight ) );
		[topView.layer setContents:(id)topImage];
		CFRelease( topImage );
		
		CGImageRef bottomImage = CGImageCreateWithImageInRect( [image CGImage], CGRectMake( 0, imageHeight * ( i * 2 + 1 ), image.size.width * image.scale, imageHeight ) );
		[bottomView.layer setContents:(id)bottomImage];
		CFRelease( bottomImage );
		
		CAGradientLayer *topGradientLayer = [_topGradientLayers objectAtIndex:i];
		CAGradientLayer *bottomGradientLayer = [_bottomGradientLayers objectAtIndex:i];
		
		topGradientLayer.frame = CGRectMake( 0, 0, _contentView.frame.size.width, _contentView.frame.size.height / ( 2 * _foldCount ) );
		bottomGradientLayer.frame = CGRectMake( 0, _contentView.frame.size.height / ( -2 * _foldCount ), _contentView.frame.size.width, _contentView.frame.size.height / ( 2 * _foldCount ) );
		
		UIView *topShadowView = [_topShadowViews objectAtIndex:i];
		UIView *bottomShadowView = [_bottomShadowViews objectAtIndex:i];
		
		topShadowView.frame = CGRectMake( 0, 0, _contentView.frame.size.width, _contentView.frame.size.height / ( 2 * _foldCount ) );
		bottomShadowView.frame = CGRectMake( 0, _contentView.frame.size.height / ( 2 * _foldCount ), _contentView.frame.size.width, _contentView.frame.size.height / ( 2 * _foldCount ) );
	}
	
	self.fraction = originalFraction;
}

- (void)setFoldCount:(NSInteger)foldCount
{
	for( NSInteger i = 0; i < _foldCount; i++ )
	{
		[[_topViews objectAtIndex:i] removeFromSuperview];
		[[_bottomViews objectAtIndex:i] removeFromSuperview];
	}
	
	[_topViews removeAllObjects];
	[_bottomViews removeAllObjects];
	
	[_topGradientLayers removeAllObjects];
	[_bottomGradientLayers removeAllObjects];
	
	[_topShadowViews removeAllObjects];
	[_bottomShadowViews removeAllObjects];
	
	_foldCount = foldCount;
	
	for( NSInteger i = 0; i < _foldCount; i++ )
	{
		UIView *topView = [[UIView alloc] init];
		[self addSubview:topView];
		[_topViews addObject:topView];
		
		UIView *bottomView = [[UIView alloc] init];
		[self addSubview:bottomView];
		[_bottomViews addObject:bottomView];
		
		CAGradientLayer *topGradientLayer = [CAGradientLayer layer];
		topGradientLayer.startPoint = CGPointMake( 0, 0 );
		topGradientLayer.endPoint = CGPointMake( 0, 1 );
		topGradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithWhite:0xFFFFFF alpha:1].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.9].CGColor];
		topGradientLayer.locations = @[@0, @0.025, @0.05, @1];
		[_topGradientLayers addObject:topGradientLayer];
		
		CAGradientLayer *bottomGradientLayer = [CAGradientLayer layer];
		bottomGradientLayer.startPoint = CGPointMake( 0, 0 );
		bottomGradientLayer.endPoint = CGPointMake( 0, 1 );
		bottomGradientLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.7].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:0xFFFFFF alpha:1].CGColor, (id)[UIColor clearColor].CGColor];
		bottomGradientLayer.locations = @[@0, @0.95, @0.975, @1];
		[_bottomGradientLayers addObject:bottomGradientLayer];
		
		UIView *topShadowView = [[UIView alloc] init];
		topShadowView.backgroundColor = [UIColor clearColor];
		[topShadowView.layer addSublayer:topGradientLayer];
		[topView addSubview:topShadowView];
		[_topShadowViews addObject:topShadowView];
		
		UIView *bottomShadowView = [[UIView alloc] init];
		[bottomShadowView.layer addSublayer:bottomGradientLayer];
		[bottomView addSubview:bottomShadowView];
		[_bottomShadowViews addObject:bottomShadowView];
	}
	
	if( _contentView )
		[self setContentView:_contentView];
}

- (void)setFraction:(CGFloat)fraction
{
	if( fraction > 1 ) fraction = 1;
	if( fraction < 0 ) fraction = 0;
	
	float theta = asinf( fraction );
	
	for( NSInteger i = 0; i < _foldCount; i++ )
	{
		UIView *topView = [_topViews objectAtIndex:i];
		UIView *bottomView = [_bottomViews objectAtIndex:i];
		
		topView.hidden = bottomView.hidden = fraction == 1;
		_contentView.hidden = !topView.hidden;
		
		CGFloat topY = -i * _contentView.frame.size.height * ( 1 - sinf( theta ) ) / _foldCount;
	
		CATransform3D transform = CATransform3DMakeTranslation( 0, topY, 0 );
		topView.layer.transform = CATransform3DRotate( transform, M_PI / 2 - theta, -1, 0, 0 );
		
		CGFloat bottomY = -1 * ( i + 1 ) * _contentView.frame.size.height * ( 1 - sinf( theta ) ) / _foldCount;
		
		transform = CATransform3DMakeTranslation( 0, bottomY, 0 );
		bottomView.layer.transform = CATransform3DRotate( transform, M_PI / 2 - theta, 1, 0, 0 );
		
		UIView *topShadowView = [_topShadowViews objectAtIndex:i];
		UIView *bottomShadowView = [_bottomShadowViews objectAtIndex:i];
		
		CGFloat alpha = ( 1 - fraction ) * 0.6;
		topShadowView.alpha = alpha;
		bottomShadowView.alpha = alpha;
		
		NSLog( @"fraction : %f", fraction );
		NSLog( @"alpha : %f", topShadowView.alpha );
	}
	
	_fraction = fraction;
}


- (NSArray *)topGradientColors
{
	return [[_topGradientLayers objectAtIndex:0] colors];
}

- (void)setTopGradientColors:(NSArray *)topGradientColors
{
	[self setTopGradientColors:topGradientColors atLocations:nil];
}

- (void)setTopGradientColors:(NSArray *)colors atLocations:(NSArray *)locations
{
	for( CAGradientLayer *topGradientLayer in _topGradientLayers )
	{
		topGradientLayer.colors = colors;
		topGradientLayer.locations = locations;
	}
}


- (NSArray *)bottomGradientColors
{
	return [[_bottomGradientLayers objectAtIndex:0] colors];
}

- (void)setBottomGradientColors:(NSArray *)bottomGradientColors
{
	[self setBottomGradientColors:bottomGradientColors atLocations:nil];
}

- (void)setBottomGradientColors:(NSArray *)colors atLocations:(NSArray *)locations
{
	for( CAGradientLayer *bottomGradientLayer in _bottomGradientLayers )
	{
		bottomGradientLayer.colors = colors;
		bottomGradientLayer.locations = locations;
	}
}

@end
