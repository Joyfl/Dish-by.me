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
	
	_minusView = [[UIImageView alloc] initWithFrame:CGRectMake( 15, 8, 20, 20 )];
	_minusView.image = [UIImage imageNamed:@"recipe_button_minus.png"];
	_minusView.layer.shouldRasterize = YES;
	
	_ingredientInput = [[UITextField alloc] initWithFrame:CGRectMake( 9, 10, 154, 20 )];
	_ingredientInput.placeholder = NSLocalizedString( @"INGREDIENT", nil );
	_ingredientInput.font = [UIFont boldSystemFontOfSize:13];
	_ingredientInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	[_ingredientInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
	_ingredientInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	_ingredientInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_ingredientInput.layer.shadowOpacity = 0.7;
	_ingredientInput.layer.shadowRadius = 0;
	_ingredientInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[self.contentView addSubview:_ingredientInput];
	
	UIImageView *separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 170, 8, 4, 20 )];
	separatorLineView.image = [UIImage imageNamed:@"recipe_line_thin_vertical.png"];
	[self.contentView addSubview:separatorLineView];
	
	_amountInput = [[UITextField alloc] initWithFrame:CGRectMake( 179, 10, 54, 20 )];
	_amountInput.placeholder = NSLocalizedString( @"AMOUNT", nil );
	_amountInput.font = [UIFont boldSystemFontOfSize:13];
	_amountInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	[_amountInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
	_amountInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	_amountInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_amountInput.layer.shadowOpacity = 0.7;
	_amountInput.layer.shadowRadius = 0;
	_amountInput.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	_amountInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[self.contentView addSubview:_amountInput];
	
	UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( -18, 37, 255, 4 )];
	lineView.image = [UIImage imageNamed:@"recipe_line_thin.png"];
	[self.contentView addSubview:lineView];
	
	return self;
}

- (void)updateEditControl
{
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

- (void)setIngredient:(Ingredient *)ingredient atIndexPath:(NSIndexPath *)indexPath
{
	_ingredient = ingredient;
	_ingredientInput.text = _ingredient.name;
	_amountInput.text = _ingredient.amount;
	[self updateEditControl];
}

@end
