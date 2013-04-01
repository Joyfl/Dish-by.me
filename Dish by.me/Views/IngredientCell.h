//
//  IngredientCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 1..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngredientCell : UITableViewCell

@property (nonatomic, strong) UITextField *ingredientInput;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
