//
//  IngredientCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "IngredientCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation IngredientCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault	reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_minusView = [[UIImageView alloc] initWithFrame:CGRectMake( 6, 8, 20, 20 )];
	_minusView.image = [UIImage imageNamed:@"recipe_button_minus.png"];
	_minusView.layer.shouldRasterize = YES;
	
	self.ingredientInput = [[UITextField alloc] initWithFrame:CGRectMake( 0, 10, 154, 20 )];
	self.ingredientInput.placeholder = NSLocalizedString( @"INGREDIENT", nil );
	self.ingredientInput.font = [UIFont boldSystemFontOfSize:13];
	self.ingredientInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	[self.ingredientInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
	self.ingredientInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	self.ingredientInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	self.ingredientInput.layer.shadowOpacity = 0.7;
	self.ingredientInput.layer.shadowRadius = 0;
	self.ingredientInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[self.contentView addSubview:self.ingredientInput];
	
	UIImageView *separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 163, 8, 4, 20 )];
	separatorLineView.image = [UIImage imageNamed:@"recipe_line_thin_vertical.png"];
	[self.contentView addSubview:separatorLineView];
	
	self.amountInput = [[UITextField alloc] initWithFrame:CGRectMake( 167 + 5, 10, 59 - 5, 20 )];
	self.amountInput.placeholder = NSLocalizedString( @"AMOUNT", nil );
	self.amountInput.font = [UIFont boldSystemFontOfSize:13];
	self.amountInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	[self.amountInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
	self.amountInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	self.amountInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	self.amountInput.layer.shadowOpacity = 0.7;
	self.amountInput.layer.shadowRadius = 0;
	self.amountInput.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	self.amountInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[self.contentView addSubview:self.amountInput];
	
	UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( -27, 37, 255, 4 )];
	lineView.image = [UIImage imageNamed:@"recipe_line_thin.png"];
	[self.contentView addSubview:lineView];
	
	return self;
}

- (void)updateEditControl
{
	if( _minusView.superview )
		return;
	
	for( UIView *subview in self.subviews )
	{
		if( [NSStringFromClass( subview.class ) isEqualToString:@"UITableViewCellEditControl"] )
		{
			UIView *originalEditControl = (UIControl *)subview;
			
			[[originalEditControl.subviews objectAtIndex:0] removeFromSuperview];
			[originalEditControl addSubview:_minusView];
			break;
		}
	}
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
	[super willTransitionToState:state];
	[self updateEditControl];
	
	if( state == 1 )
	{
		[self rotateMinusViewToAngle:0];
	}
	else if( state == 3 )
	{
		[self rotateMinusViewToAngle:-M_PI_2];
	}
}

- (void)rotateMinusViewToAngle:(CGFloat)angle
{
	[UIView animateWithDuration:0.25 animations:^{
		CGAffineTransform transform = CGAffineTransformMakeRotation( angle );
		_minusView.transform = transform;
	}];
}

@end
