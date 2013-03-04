//
//  JLFoldable.h
//  JLFoldableView
//
//  Created by 전수열 on 13. 1. 11..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CAGradientLayer.h>

@interface JLFoldableView : UIView
{
	UIView *_contentView;
	
	NSMutableArray *_topViews;
	NSMutableArray *_bottomViews;
	
	NSMutableArray *_topGradientLayers;
	NSMutableArray *_bottomGradientLayers;
	
	NSMutableArray *_topShadowViews;
	NSMutableArray *_bottomShadowViews;
}

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, assign) NSInteger foldCount;
@property (nonatomic, assign) CGFloat fraction;
@property (nonatomic, assign) NSArray *topGradientColors;
@property (nonatomic, assign) NSArray *bottomGradientColors;

- (void)setFraction:(CGFloat)fraction animated:(BOOL)animated completion:(void (^)(BOOL complete))completion;
- (void)setFraction:(CGFloat)fraction animated:(BOOL)animated withDuration:(NSTimeInterval)duration completion:(void (^)(BOOL complete))completion;
- (void)setFraction:(CGFloat)fraction animated:(BOOL)animated withDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve tick:(void (^)(void))tick completion:(void (^)(BOOL completion))completion;

- (void)setTopGradientColors:(NSArray *)colors atLocations:(NSArray *)locations;
- (void)setBottomGradientColors:(NSArray *)colors atLocations:(NSArray *)locations;

@end
