//
//  IngredientViewerCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "IngredientViewerCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation IngredientViewerCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault	reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_ingredientLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 180, 0 )];
	_ingredientLabel.font = [UIFont boldSystemFontOfSize:13];
	_ingredientLabel.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	_ingredientLabel.backgroundColor = [UIColor clearColor];
	_ingredientLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
	_ingredientLabel.layer.shadowOffset = CGSizeMake( 0, 1 );
	_ingredientLabel.layer.shadowOpacity = 0.7;
	_ingredientLabel.layer.shadowRadius = 0;
	[self.contentView addSubview:_ingredientLabel];
	
	UIImageView *separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 202, 8, 4, 20 )];
	separatorLineView.image = [UIImage imageNamed:@"recipe_line_thin_vertical.png"];
	[self.contentView addSubview:separatorLineView];
	
	_amountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 50, 0 )];
	_amountLabel.font = [UIFont boldSystemFontOfSize:13];
	_amountLabel.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
	_amountLabel.backgroundColor = [UIColor clearColor];
	_amountLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
	_amountLabel.layer.shadowOffset = CGSizeMake( 0, 1 );
	_amountLabel.layer.shadowOpacity = 0.7;
	_amountLabel.layer.shadowRadius = 0;
	[self.contentView addSubview:_amountLabel];
	
	UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 14, 37, 255, 4 )];
	lineView.image = [UIImage imageNamed:@"recipe_line_thin.png"];
	[self.contentView addSubview:lineView];
	
	return self;
}

- (void)setIngredient:(Ingredient *)ingredient atIndexPath:(NSIndexPath *)indexPath
{
	_ingredient = ingredient;
	
	_ingredientLabel.text = _ingredient.name;
	[_ingredientLabel sizeToFit];
	_ingredientLabel.frame = CGRectMake( 18, 10, _ingredientLabel.frame.size.width, _ingredientLabel.frame.size.height );
	
	_amountLabel.text = _ingredient.amount;
	[_amountLabel sizeToFit];
	_amountLabel.frame = CGRectMake( 265 - _amountLabel.frame.size.width, 10, _amountLabel.frame.size.width, _amountLabel.frame.size.height );
}

@end
