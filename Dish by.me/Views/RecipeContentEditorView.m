//
//  RecipeContentEditorView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeContentEditorView.h"
#import "UIButton+TouchAreaInsets.h"
#import <QuartzCore/QuartzCore.h>

@implementation RecipeContentEditorView

- (id)init
{
	self = [super initWithFrame:CGRectMake( 0, 0, 308, 451 )];
	self.userInteractionEnabled = YES;
	
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
	
	_photoButton = [[UIButton alloc] initWithFrame:CGRectMake( 19, 18, 241, 186-100 )];
	[_photoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
//	[_photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_photoButton];
	
	_borderView = [[UIImageView alloc] initWithFrame:CGRectMake( 12, 11, 255, 200-100 )];
	_borderView.image = [[UIImage imageNamed:@"dish_tile_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 12, 12 )];
	[_scrollView addSubview:_borderView];
	
	_lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_line_thin.png"]];
	[_scrollView addSubview:_lineView];
	
	_contentInput = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake( 0, 0, 250, 0 )];
	_contentInput.delegate = self;
	_contentInput.editable = YES;
	_contentInput.font = [UIFont boldSystemFontOfSize:12];
	_contentInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	_contentInput.placeholder = NSLocalizedString( @"INPUT_CONTENT", nil );
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

- (void)layoutScrollViewContent
{
	_lineView.frame = CGRectMake( 12, _photoButton.frame.origin.y + _photoButton.frame.size.height + 13, 255, 4 );
	_contentInput.frame = CGRectMake( 15, _lineView.frame.origin.y + _lineView.frame.size.height, 250, _contentInput.contentSize.height );
	_scrollView.contentSize = CGSizeMake( 280, _contentInput.frame.origin.y + _contentInput.frame.size.height + 13 );
}

- (void)textViewDidChange:(UITextView *)textView
{
	[self layoutScrollViewContent];
}

@end
