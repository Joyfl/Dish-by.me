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
	
	self.ingredientInput = [[UITextField alloc] initWithFrame:CGRectMake( 32, 6, 180, 15 )];
	self.ingredientInput.placeholder = NSLocalizedString( @"INGREDIENT", nil );
	self.ingredientInput.font = [UIFont boldSystemFontOfSize:13];
	[self.contentView addSubview:self.ingredientInput];
	
	return self;
}

@end
