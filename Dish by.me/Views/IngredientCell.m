//
//  IngredientCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "IngredientCell.h"

@implementation IngredientCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault	reuseIdentifier:reuseIdentifier];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	self.ingredientInput = [[UITextField alloc] initWithFrame:CGRectMake( 21, 10, 175, 15 )];
	self.ingredientInput.placeholder = NSLocalizedString( @"INGREDIENT", nil );
	self.ingredientInput.font = [UIFont boldSystemFontOfSize:13];
	self.ingredientInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[self.contentView addSubview:self.ingredientInput];
	
	self.amountInput = [[UITextField alloc] initWithFrame:CGRectMake( 199 + 5, 10, 80 - 5, 15 )];
	self.amountInput.placeholder = NSLocalizedString( @"AMOUNT", nil );
	self.amountInput.font = [UIFont boldSystemFontOfSize:13];
	self.amountInput.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	self.amountInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[self.contentView addSubview:self.amountInput];
	
	UIImageView *separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 195, 8, 4, 20 )];
	separatorLineView.image = [UIImage imageNamed:@"recipe_line_thin_vertical.png"];
	[self.contentView addSubview:separatorLineView];
	
	UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 5, 37, 255, 4 )];
	lineView.image = [UIImage imageNamed:@"recipe_line_thin.png"];
	[self.contentView addSubview:lineView];
	
	return self;
}

@end
