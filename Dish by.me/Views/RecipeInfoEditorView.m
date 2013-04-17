//
//  RecipeInfoEditorView.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "RecipeInfoEditorView.h"
#import "IngredientEditorCell.h"
#import "UIButton+TouchAreaInsets.h"
#import <QuartzCore/QuartzCore.h>

#define tableViewX _tableView.frame.origin.x + 2
#define tableViewY _tableView.frame.origin.y

@implementation RecipeInfoEditorView

- (id)initWithRecipe:(Recipe *)recipe
{
	self = [super initWithFrame:CGRectMake( 0, 0, 308, UIScreenHeight - 30 )];
	
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)];
	recognizer.delegate = self;
	[self addGestureRecognizer:recognizer];
	
	_recipe = recipe;
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.frame];
	bgView.image = [[UIImage imageNamed:@"bg_recipe.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 70, 0, 70, 0 )];
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
	
	self.checkButton = [[UIButton alloc] initWithFrame:CGRectMake( 270, 24, 20, 20 )];
	self.checkButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[self.checkButton setBackgroundImage:[UIImage imageNamed:@"recipe_button_check.png"] forState:UIControlStateNormal];
	[self addSubview:self.checkButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 14, 59, 276, UIScreenHeight - 150 )];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.editing = YES;
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self addSubview:_tableView];
	
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return ![[touch.view.class description] isEqualToString:@"UITableViewCellEditControl"];
}

- (void)backgroundDidTap
{
	[self endEditing:YES];
	CGRect frame = _tableView.frame;
	frame.size.height = UIScreenHeight - 150;
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
			
			_servingsInput = [[UITextField alloc] initWithFrame:CGRectMake( 47 - tableViewX, 72 - tableViewY, 98, 30 )];
			_servingsInput.text = _recipe.servings ? [NSString stringWithFormat:@"%d", _recipe.servings] : nil;
			_servingsInput.placeholder = NSLocalizedString( @"HOW_MANY_SERVINGS", nil );
			_servingsInput.font = [UIFont boldSystemFontOfSize:12];
			_servingsInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
			[_servingsInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
			_servingsInput.keyboardType = UIKeyboardTypeNumberPad;
			_servingsInput.layer.shadowColor = [UIColor whiteColor].CGColor;
			_servingsInput.layer.shadowOffset = CGSizeMake( 0, 1 );
			_servingsInput.layer.shadowOpacity = 0.7;
			_servingsInput.layer.shadowRadius = 0;
			_servingsInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
			[_servingsInput addTarget:self action:@selector(inputEdittingChange:) forControlEvents:UIControlEventEditingChanged];
			[_servingsInput becomeFirstResponder];
			[cell.contentView addSubview:_servingsInput];
			
			_servingsLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 0, 12 )];
			_servingsLabel.text = NSLocalizedString( @"SERVINGS", nil );
			_servingsLabel.font = [UIFont boldSystemFontOfSize:12];
			_servingsLabel.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
			_servingsLabel.shadowColor = [UIColor whiteColor];
			_servingsLabel.shadowOffset = CGSizeMake( 0, 1 );
			_servingsLabel.backgroundColor = [UIColor clearColor];
			_servingsLabel.hidden = YES;
			_servingsLabel.userInteractionEnabled = YES;
			[_servingsLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:_servingsInput action:@selector(becomeFirstResponder)]];
			[_servingsLabel sizeToFit];
			[cell.contentView addSubview:_servingsLabel];
			
			UIImageView *separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake( 149 - tableViewX, 70 - tableViewY, 4, 20 )];
			separatorLineView.image = [UIImage imageNamed:@"recipe_line_thin_vertical.png"];
			[cell.contentView addSubview:separatorLineView];
			
			UIImageView *clockIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 158 - tableViewX, 70 - tableViewY, 20, 20 )];
			clockIconView.image = [UIImage imageNamed:@"recipe_icon_clock.png"];
			[cell.contentView addSubview:clockIconView];
			
			_minutesInput = [[UITextField alloc] initWithFrame:CGRectMake( 185 - tableViewX, 72 - tableViewY, 98, 30 )];
			_minutesInput.text = _recipe.minutes ? [NSString stringWithFormat:@"%d", _recipe.minutes] : nil;
			_minutesInput.placeholder = NSLocalizedString( @"HOW_MANY_MINUTES", nil );
			_minutesInput.font = [UIFont boldSystemFontOfSize:12];
			_minutesInput.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
			[_minutesInput setValue:[UIColor colorWithHex:0x958675 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
			_minutesInput.keyboardType = UIKeyboardTypeNumberPad;
			_minutesInput.layer.shadowColor = [UIColor whiteColor].CGColor;
			_minutesInput.layer.shadowOffset = CGSizeMake( 0, 1 );
			_minutesInput.layer.shadowOpacity = 0.7;
			_minutesInput.layer.shadowRadius = 0;
			_minutesInput.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
			[_minutesInput addTarget:self action:@selector(inputEdittingChange:) forControlEvents:UIControlEventEditingChanged];
			[cell.contentView addSubview:_minutesInput];
			
			_minutesLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 0, 12 )];
			_minutesLabel.text = NSLocalizedString( @"MINUTES", nil );
			_minutesLabel.font = [UIFont boldSystemFontOfSize:12];
			_minutesLabel.textColor = [UIColor colorWithHex:0x4A433C alpha:1];
			_minutesLabel.shadowColor = [UIColor whiteColor];
			_minutesLabel.shadowOffset = CGSizeMake( 0, 1 );
			_minutesLabel.backgroundColor = [UIColor clearColor];
			_minutesLabel.hidden = YES;
			_minutesLabel.userInteractionEnabled = YES;
			[_minutesLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:_minutesInput action:@selector(becomeFirstResponder)]];
			[_minutesLabel sizeToFit];
			[cell.contentView addSubview:_minutesLabel];
			
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
	
	else if( indexPath.section == 1 )
	{
		IngredientEditorCell *cell = [tableView dequeueReusableCellWithIdentifier:ingredientCellId];
		if( !cell )
		{
			cell = [[IngredientEditorCell alloc] initWithReuseIdentifier:ingredientCellId];
			[cell.ingredientInput addTarget:self action:@selector(ingredientCellInputDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
			[cell.amountInput addTarget:self action:@selector(ingredientCellInputDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
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
			addButton.contentEdgeInsets = UIEdgeInsetsMake( 0, 15, 5, 5 );
			addButton.titleEdgeInsets = UIEdgeInsetsMake( 0, 5, 0, 0 );
			[addButton addTarget:self action:@selector(addButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:addButton];
			
			UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 14, 38, 255, 5 )];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_recipe.ingredients removeObjectAtIndex:indexPath.row];
	
	[tableView beginUpdates];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];
}

- (void)inputEdittingChange:(UITextField *)input
{
	UILabel *label;
	NSString *placeholder;
	
	if( input == _servingsInput )
	{
		label = _servingsLabel;
		placeholder = NSLocalizedString( @"HOW_MANY_SERVINGS", nil );
	}
	else
	{
		label = _minutesLabel;
		placeholder = NSLocalizedString( @"HOW_MANY_MINUTES", nil );
	}
	
	if( input.text.length == 0 )
	{
		label.hidden = YES;
		input.placeholder = placeholder;
		CGRect frame = input.frame;
		frame.size.width = 98;
		input.frame = frame;
		return;
	}
	
	label.hidden = NO;
	input.placeholder = nil;
	
	[input sizeToFit];
	
	NSInteger maxWidth = 98 - label.frame.size.width;
	if( input.frame.size.width >=  maxWidth)
	{
		CGRect frame = input.frame;
		frame.size.width = maxWidth;
		input.frame = frame;
	}
	
	label.frame = CGRectMake( input.frame.origin.x + input.frame.size.width - 3, input.frame.origin.y - 1, label.frame.size.width, label.frame.size.height );
}

- (void)ingredientCellInputDidBeginEditing:(UITextField *)input
{
	[UIView animateWithDuration:0.5 animations:^{
		CGRect frame = _tableView.frame;
		frame.size.height = UIScreenHeight - 294;
		_tableView.frame = frame;
	}];
	
	IngredientEditorCell *cell = (IngredientEditorCell *)input.superview.superview;
	[_tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)addButtonDidTouchUpInside
{
	Ingredient *ingredient = [[Ingredient alloc] init];
	[_recipe.ingredients addObject:ingredient];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_recipe.ingredients.count - 1 inSection:1];
	
	[_tableView beginUpdates];
	[_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	[_tableView endUpdates];
	
	IngredientEditorCell *cell = (IngredientEditorCell *)[_tableView cellForRowAtIndexPath:newIndexPath];
	[cell.ingredientInput becomeFirstResponder];
	
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

@end
