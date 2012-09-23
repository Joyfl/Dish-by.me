//
//  RecipeView.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeView : UIView

- (id)initWithRecipe:(NSString *)recipe closeButtonTarget:(id)target closeButtonAction:(SEL)action;

@end
