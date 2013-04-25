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

- (id)initWithRecipeContent:(RecipeContent *)content
{
	self = [super initWithFrame:CGRectMake( 0, 0, 308, DMRecipeHeight )];
	self.layer.anchorPoint = CGPointMake( 0, 0.5 );
	[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)]];
	
	_content = content;
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 308, DMRecipeHeight )];
	bgView.image = [[UIImage imageNamed:@"bg_recipe.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 70, 0, 70, 0 )];
	bgView.userInteractionEnabled = YES;
	[self addSubview:bgView];
	
	_grabButton = [[UIButton alloc] initWithFrame:CGRectMake( 17, 24, 20, 20 )];
	_grabButton.adjustsImageWhenHighlighted = NO;
	_grabButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[_grabButton setBackgroundImage:[UIImage imageNamed:@"recipe_reorder_control.png"] forState:UIControlStateNormal];
	[self addSubview:_grabButton];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 245, 0 )];
	titleLabel.text = NSLocalizedString( @"WRITE_RECIPE", nil );
	titleLabel.font = [UIFont systemFontOfSize:15];
	titleLabel.textColor = [UIColor colorWithHex:0x5B5046 alpha:1];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.9];
	titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[titleLabel sizeToFit];
	titleLabel.frame = CGRectOffset( titleLabel.frame, 46, 22 );
	[self addSubview:titleLabel];
	
	_checkButton = [[UIButton alloc] initWithFrame:CGRectMake( 270, 24, 20, 20 )];
	_checkButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[_checkButton setBackgroundImage:[UIImage imageNamed:@"recipe_button_check.png"] forState:UIControlStateNormal];
	[self addSubview:_checkButton];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 14, 59, 280, DMRecipeHeight - 120 )];
	[self addSubview:_scrollView];
	
	_photoButton = [[UIButton alloc] initWithFrame:CGRectMake( 7, 17, 263, 176 )];
	[_photoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
	
	if( content.photo )
	{
		[self setPhotoButtonImage:content.photo];
	}
	else
	{
		[_photoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
		[DMAPILoader loadImageFromURLString:content.photoURL context:nil success:^(UIImage *image, id context) {
			content.photo = image;
			[self setPhotoButtonImage:image];
		}];
	}
	[_scrollView addSubview:_photoButton];
	
	_borderView = [[UIImageView alloc] init];
	_borderView.image = [[UIImage imageNamed:@"dish_tile_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 12, 12 )];
	[_scrollView addSubview:_borderView];
	
	_lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_line_thin.png"]];
	[_scrollView addSubview:_lineView];
	
	_textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake( 0, 0, 250, 100 )];
	_textView.delegate = self;
	_textView.editable = YES;
	_textView.font = [UIFont boldSystemFontOfSize:12];
	_textView.text = _content.description;
	_textView.placeholder = NSLocalizedString( @"INPUT_CONTENT", nil );
	_textView.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	_textView.placeholderColor = [UIColor colorWithHex:0x958675 alpha:1];
	_textView.backgroundColor = [UIColor clearColor];
	_textView.contentInset = UIEdgeInsetsZero;
	_textView.layer.shadowColor = [UIColor whiteColor].CGColor;
	_textView.layer.shadowOffset = CGSizeMake( 0, 1 );
	_textView.layer.shadowOpacity = 0.7;
	_textView.layer.shadowRadius = 0;
	_textView.scrollEnabled = NO;
	[_scrollView addSubview:_textView];
	
	[self layoutScrollViewContent];
	
	_pageControlView = [[UIView alloc] init];
	[self addSubview:_pageControlView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
	
	return self;
}

- (void)setPhotoButtonImage:(UIImage *)image
{
	_content.photo = image;
	[_photoButton setImage:image forState:UIControlStateNormal];
	
	CGRect frame = _photoButton.frame;
	frame.size.height = floorf( 241 * image.size.height / image.size.width );
	_photoButton.frame = frame;
	
	[self layoutScrollViewContent];
}

- (void)layoutScrollViewContent
{
	_borderView.frame = CGRectInset( _photoButton.frame, -7, -7 );
	_lineView.frame = CGRectMake( 12, _photoButton.frame.origin.y + _photoButton.frame.size.height + 20, 255, 4 );
	_textView.frame = CGRectMake( 15, _lineView.frame.origin.y + _lineView.frame.size.height, 250, MAX( _textView.contentSize.height, DMRecipeHeight - 350 ) );
	_scrollView.contentSize = CGSizeMake( 280, _textView.frame.origin.y + _textView.frame.size.height + 13 );
}

- (void)backgroundDidTap
{
	[self endEditing:YES];
}

- (void)keyboardWillHide
{
	CGRect frame = _scrollView.frame;
	frame.size.height = DMRecipeHeight - 120;
	_scrollView.frame = frame;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[UIView animateWithDuration:0.5 animations:^{
		CGRect frame = _scrollView.frame;
		frame.size.height = IPHONE5 ? 252 : DMRecipeHeight - 264;
		_scrollView.frame = frame;
	}];
}

- (void)textViewDidChange:(UITextView *)textView
{
	[self layoutScrollViewContent];
	_content.description = textView.text;
}

#pragma mark -

- (void)setCurrentPage:(NSInteger)currentPage numberOfPages:(NSInteger)numberOfPages
{
	for( UIImageView *dotView in _pageControlView.subviews )
	{
		[dotView removeFromSuperview];
	}
	
	for( NSInteger i = 0; i < numberOfPages; i++ )
	{
		UIImageView *dotView = [[UIImageView alloc] initWithFrame:CGRectMake( i * 10, 0, 10, 10 )];
		dotView.image = [UIImage imageNamed:i == currentPage ? @"recipe_page_control_selected.png" : @"recipe_page_control.png"];
		[_pageControlView addSubview:dotView];
	}
	
	CGRect frame = _pageControlView.frame;
	frame.size = CGSizeMake( 10 * numberOfPages, 10 );
	_pageControlView.frame = frame;
	_pageControlView.center = CGPointMake( 154, DMRecipeHeight - 34 );
}

@end
