//
//  IngredientCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"

@interface IngredientEditorCell : UITableViewCell
{
	UIImageView *_minusView;
}

@property (nonatomic, readonly) Ingredient *ingredient;
@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) UITextField *ingredientInput;
@property (nonatomic, readonly) UITextField *amountInput;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setIngredient:(Ingredient *)ingredient atIndexPath:(NSIndexPath *)indexPath;

@end
