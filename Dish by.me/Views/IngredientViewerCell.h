//
//  IngredientViewerCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 10..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"

@interface IngredientViewerCell : UITableViewCell
{
	UILabel *_ingredientLabel;
	UILabel *_amountLabel;
}

@property (nonatomic, readonly) Ingredient *ingredient;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setIngredient:(Ingredient *)ingredient atIndexPath:(NSIndexPath *)indexPath;

@end
