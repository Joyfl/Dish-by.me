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
	
	_content = content;
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_recipe.png"]];
	[self addSubview:bgView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 245, 0 )];
	titleLabel.text = NSLocalizedString( @"SHOW_RECIPE", nil );
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
	_photoButton.adjustsImageWhenHighlighted = NO;
	if( content.photo )
	{
		[_photoButton setBackgroundImage:content.photo forState:UIControlStateNormal];
	}
	else
	{
		[_photoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
		[DMAPILoader loadImageFromURLString:content.photoURL context:nil success:^(UIImage *image, id context) {
			content.photo = image;
			[_photoButton setBackgroundImage:image forState:UIControlStateNormal];
			[self layoutScrollViewContent];
		}];
	}
	[_scrollView addSubview:_photoButton];
	
	_borderView = [[UIImageView alloc] init];
	_borderView.image = [[UIImage imageNamed:@"dish_tile_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 12, 12 )];
	[_scrollView addSubview:_borderView];
	
	_lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipe_line_thin.png"]];
	[_scrollView addSubview:_lineView];
	
	_textView = [[UITextView alloc] initWithFrame:CGRectMake( 0, 0, 250, 0 )];
	_textView.font = [UIFont boldSystemFontOfSize:12];
	_textView.editable = NO;
	_textView.text = _content.description;
	_textView.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	_textView.backgroundColor = [UIColor clearColor];
	_textView.contentInset = UIEdgeInsetsZero;
	_textView.layer.shadowColor = [UIColor whiteColor].CGColor;
	_textView.layer.shadowOffset = CGSizeMake( 0, 1 );
	_textView.layer.shadowOpacity = 0.7;
	_textView.layer.shadowRadius = 0;
	_textView.scrollEnabled = NO;
	[_scrollView addSubview:_textView];
	
	[self layoutScrollViewContent];
	
	return self;
}

- (void)layoutScrollViewContent
{
	_borderView.frame = CGRectInset( _photoButton.frame, -7, -7 );
	_lineView.frame = CGRectMake( 12, _photoButton.frame.origin.y + _photoButton.frame.size.height + 13, 255, 4 );
	_textView.frame = CGRectMake( 15, _lineView.frame.origin.y + _lineView.frame.size.height, 250, _textView.contentSize.height );
	_scrollView.contentSize = CGSizeMake( 280, _textView.frame.origin.y + _textView.frame.size.height + 13 );
}

@end
