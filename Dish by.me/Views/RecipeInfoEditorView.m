//
//  RecipeInfoEditorView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeInfoEditorView.h"
#import "IngredientCell.h"
#import "UIButton+TouchAreaInsets.h"
#import <QuartzCore/QuartzCore.h>

#define tableViewX _tableView.frame.origin.x
#define tableViewY _tableView.frame.origin.y

@implementation RecipeInfoEditorView

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super initWithFrame:CGRectMake( 0, 0, 308, 451 )];
	[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)]];
	
	_recipe = recipe;
	
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
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 21, 59, 255, 330 )];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.editing = YES;
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self addSubview:_tableView];
	
	return self;
}

- (void)backgroundDidTap
{
	[self endEditing:YES];
	CGRect frame = _tableView.frame;
	frame.size.height = 330;
	_tableView.frame = frame;
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 )
		return 1;
	
	if( section == 1 )
		return _recipe.ingredients.count;
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 0 )
		return 160 - tableViewY;
	
	else if( indexPath.section == 1 )
		return 41;
	
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *infoCellId = @"infoCellId";
	static NSString *ingredientCellId = @"ingredientCellId";
	static NSString *addCellId = @"addCellId";
	
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
			_servingsInput.text = [NSString stringWithFormat:@"%d", _recipe.servings];
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
			_minutesInput.text = [NSString stringWithFormat:@"%d", _recipe.minutes];
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
			titleLabel.frame = CGRectMake( ( 255 - titleLabel.frame.size.width ) / 2, 118 - tableViewY, titleLabel.frame.size.width, titleLabel.frame.size.height );
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
	
	else if( indexPath.section == 1 )
	{
		IngredientCell *cell = [tableView dequeueReusableCellWithIdentifier:ingredientCellId];
		if( !cell )
		{
			cell = [[IngredientCell alloc] initWithReuseIdentifier:ingredientCellId];
		}
		
		[cell setIngredient:[_recipe.ingredients objectAtIndex:indexPath.row] atIndexPath:indexPath];
		
		return cell;
	}
	
	else
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIButton *addButton = [[UIButton alloc] initWithFrame:cell.contentView.frame];
			[addButton setImage:[UIImage imageNamed:@"recipe_button_plus.png"] forState:UIControlStateNormal];
			[addButton setTitle:NSLocalizedString( @"ADD_INGREDIENT", nil ) forState:UIControlStateNormal];
			[addButton setTitleColor:[UIColor colorWithHex:0x958675 alpha:1] forState:UIControlStateNormal];
			[addButton setTitleColor:[UIColor colorWithHex:0x3E3931 alpha:1] forState:UIControlStateHighlighted];
			[addButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
			addButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
			addButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
			addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
			addButton.contentEdgeInsets = UIEdgeInsetsMake( 0, 5, 5, 5 );
			addButton.titleEdgeInsets = UIEdgeInsetsMake( 0, 5, 0, 0 );
			[cell.contentView addSubview:addButton];
			
			UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 5, 38, 255, 5 )];
			lineView.image = [UIImage imageNamed:@"recipe_line.png"];
			[cell.contentView addSubview:lineView];
		}
		
		return cell;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == 1 )
		return YES;
	return NO;
}

@end
