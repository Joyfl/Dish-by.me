//
//  RecipeInfoViewerView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeInfoViewerView.h"
#import "IngredientCell.h"
#import "UIButton+TouchAreaInsets.h"
#import <QuartzCore/QuartzCore.h>

#define tableViewX _tableView.frame.origin.x + 2
#define tableViewY _tableView.frame.origin.y

@implementation RecipeInfoViewerView

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super initWithFrame:CGRectMake( 0, 0, 308, 451 )];
	
	_recipe = recipe;
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_recipe.png"]];
	bgView.userInteractionEnabled = YES;
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
	
	_checkButton = [[UIButton alloc] initWithFrame:CGRectMake( 270, 24, 20, 20 )];
	_checkButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[_checkButton setBackgroundImage:[UIImage imageNamed:@"recipe_button_check.png"] forState:UIControlStateNormal];
	[self addSubview:_checkButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 14, 59, 276, 330 )];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self addSubview:_tableView];
	
	return self;
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 )
		return 1;
	return _recipe.ingredients.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 0 )
		return 160 - tableViewY;
	return 41;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *infoCellId = @"infoCellId";
	static NSString *ingredientCellId = @"ingredientCellId";
	
	if( indexPath.section == 0 )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIImageView *knifeIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 21 - tableViewX, 70 - tableViewY, 20, 20 )];
			knifeIconView.image = [UIImage imageNamed:@"recipe_icon_knife.png"];
			[cell.contentView addSubview:knifeIconView];
			
			_servingsInput = [[UITextField alloc] initWithFrame:CGRectMake( 47 - tableViewX, 72 - tableViewY, 100, 30 )];
			_servingsInput.text = _recipe.servings ? [NSString stringWithFormat:@"%d", _recipe.servings] : nil;
			_servingsInput.placeholder = NSLocalizedString( @"HOW_MANY_SERVINGS", nil );
			_servingsInput.font = [UIFont boldSystemFontOfSize:12];
			_servingsInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
			[_servingsInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
			_servingsInput.layer.shadowColor = [UIColor whiteColor].CGColor;
			_servingsInput.layer.shadowOffset = CGSizeMake( 0, 1 );
			_servingsInput.layer.shadowOpacity = 0.7;
			_servingsInput.layer.shadowRadius = 0;
			_servingsInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
			[cell.contentView addSubview:_servingsInput];
			
			UIImageView *separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 152 - tableViewX, 70 - tableViewY, 4, 20 )];
			separatorLineView.image = [UIImage imageNamed:@"recipe_line_thin_vertical.png"];
			[cell.contentView addSubview:separatorLineView];
			
			UIImageView *clockIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 161 - tableViewX, 70 - tableViewY, 20, 20 )];
			clockIconView.image = [UIImage imageNamed:@"recipe_icon_clock.png"];
			[cell.contentView addSubview:clockIconView];
			
			_minutesInput = [[UITextField alloc] initWithFrame:CGRectMake( 188 - tableViewX, 72 - tableViewY, 100, 30 )];
			_minutesInput.text = _recipe.minutes ? [NSString stringWithFormat:@"%d", _recipe.minutes] : nil;
			_minutesInput.placeholder = NSLocalizedString( @"HOW_MANY_MINUTES", nil );
			_minutesInput.font = [UIFont boldSystemFontOfSize:12];
			_minutesInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
			[_minutesInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
			_minutesInput.layer.shadowColor = [UIColor whiteColor].CGColor;
			_minutesInput.layer.shadowOffset = CGSizeMake( 0, 1 );
			_minutesInput.layer.shadowOpacity = 0.7;
			_minutesInput.layer.shadowRadius = 0;
			_minutesInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
			[cell.contentView addSubview:_minutesInput];
			
			UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 26 - tableViewX, 100 - tableViewY, 255, 4 )];
			lineView.image = [UIImage imageNamed:@"recipe_line_thin.png"];
			[cell.contentView addSubview:lineView];
			
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 255, 30 )];
			titleLabel.text = NSLocalizedString( @"INGREDIENT", nil );
			titleLabel.font = [UIFont boldSystemFontOfSize:14];
			titleLabel.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.9];
			titleLabel.shadowOffset = CGSizeMake( 0, 1 );
			[titleLabel sizeToFit];
			titleLabel.frame = CGRectMake( ( _tableView.frame.size.width - titleLabel.frame.size.width ) / 2, 118 - tableViewY, titleLabel.frame.size.width, titleLabel.frame.size.height );
			[cell.contentView addSubview:titleLabel];
			
			UIImageView *leftDecoView = [[UIImageView alloc] initWithFrame:CGRectMake( titleLabel.frame.origin.x - 23, 125 - tableViewY, 15, 7 )];
			leftDecoView.image = [UIImage imageNamed:@"recipe_title_deco_left.png"];
			[cell.contentView addSubview:leftDecoView];
			
			UIImageView *rightDecoView = [[UIImageView alloc] initWithFrame:CGRectMake( titleLabel.frame.origin.x + titleLabel.frame.size.width + 8, 125 - tableViewY, 15, 7 )];
			rightDecoView.image = [UIImage imageNamed:@"recipe_title_deco_right.png"];
			[cell.contentView addSubview:rightDecoView];
			
			lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 26 - tableViewX, 155 - tableViewY, 255, 5 )];
			lineView.image = [UIImage imageNamed:@"recipe_line.png"];
			[cell.contentView addSubview:lineView];
		}
		
		return cell;
	}
	
	else
	{
		IngredientCell *cell = [tableView dequeueReusableCellWithIdentifier:ingredientCellId];
		if( !cell )
		{
			cell = [[IngredientCell alloc] initWithReuseIdentifier:ingredientCellId];
			[cell.ingredientInput addTarget:self action:@selector(ingredientInputDidBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
		}
		
		[cell setIngredient:[_recipe.ingredients objectAtIndex:indexPath.row] atIndexPath:indexPath];
		
		return cell;
	}
}

@end
