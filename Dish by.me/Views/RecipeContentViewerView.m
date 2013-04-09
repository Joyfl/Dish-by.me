//
//  RecipeContentViewerView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeContentViewerView.h"
#import "UIButton+TouchAreaInsets.h"
#import <QuartzCore/QuartzCore.h>

@implementation RecipeContentViewerView

- (id)initWithRecipeContent:(RecipeContent *)content
{
	self = [super initWithFrame:CGRectMake( 0, 0, 308, 451 )];
	self.layer.anchorPoint = CGPointMake( 0, 0.5 );
	[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)]];
	
	_content = content;
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_recipe.png"]];
	[self addSubview:bgView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 245, 0 )];
	titleLabel.text = NSLocalizedString( @"WRITE_RECIPE", nil );
	titleLabel.font = [UIFont systemFontOfSize:15];
	titleLabel.textColor = [UIColor colorWithHex:0x5B5046 alpha:1];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.9];
	titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[titleLabel sizeToFit];
	titleLabel.frame = CGRectOffset( titleLabel.frame, 20, 22 );
	[self addSubview:titleLabel];
	
	self.checkButton = [[UIButton alloc] initWithFrame:CGRectMake( 270, 24, 20, 20 )];
	self.checkButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[self.checkButton setBackgroundImage:[UIImage imageNamed:@"recipe_button_check.png"] forState:UIControlStateNormal];
	[self addSubview:self.checkButton];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 14, 59, 280, 330 )];
	[self addSubview:_scrollView];
	
	_photoButton = [[UIButton alloc] initWithFrame:CGRectMake( 19, 18, 241, 186 )];
	[_photoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
	[_photoButton addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
	[_scrollView addSubview:_photoButton];
	
	_borderView = [[UIImageView alloc] init];
	_borderView.image = [[UIImage imageNamed:@"dish_tile_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 12, 12 )];
	[_scrollView addSubview:_borderView];
	
	_lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_line_thin.png"]];
	[_scrollView addSubview:_lineView];
	
	_contentInput = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake( 0, 0, 250, 100 )];
	_contentInput.delegate = self;
	_contentInput.editable = YES;
	_contentInput.font = [UIFont boldSystemFontOfSize:12];
	_contentInput.text = _content.description;
	_contentInput.placeholder = NSLocalizedString( @"INPUT_CONTENT", nil );
	_contentInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	_contentInput.placeholderColor = [UIColor colorWithHex:0x958675 alpha:1];
	_contentInput.backgroundColor = [UIColor clearColor];
	_contentInput.contentInset = UIEdgeInsetsZero;
	_contentInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	_contentInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_contentInput.layer.shadowOpacity = 0.7;
	_contentInput.layer.shadowRadius = 0;
	_contentInput.scrollEnabled = NO;
	[_scrollView addSubview:_contentInput];
	
	[self layoutScrollViewContent];
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( [keyPath isEqualToString:@"frame"] )
	{
		_content.photo = [_photoButton imageForState:UIControlStateNormal];
		[self layoutScrollViewContent];
	}
}

- (void)layoutScrollViewContent
{
	_borderView.frame = CGRectInset( _photoButton.frame, -7, -7 );
	_lineView.frame = CGRectMake( 12, _photoButton.frame.origin.y + _photoButton.frame.size.height + 13, 255, 4 );
	_contentInput.frame = CGRectMake( 15, _lineView.frame.origin.y + _lineView.frame.size.height, 250, MAX( _contentInput.contentSize.height, 100 ) );
	_scrollView.contentSize = CGSizeMake( 280, _contentInput.frame.origin.y + _contentInput.frame.size.height + 13 );
}


#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[UIView animateWithDuration:0.5 animations:^{
		CGRect frame = _scrollView.frame;
		frame.size.height = (UIScreenHeight - 120) / 2;
		_scrollView.frame = frame;
	}];
}

- (void)textViewDidChange:(UITextView *)textView
{
	[self layoutScrollViewContent];
	_content.description = textView.text;
}

- (void)backgroundDidTap
{
	[self endEditing:YES];
	CGRect frame = _scrollView.frame;
	frame.size.height = 330;
	_scrollView.frame = frame;
}

@end
