//
//  DMBookButton.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMBookButton : UIButton

+ (id)bookButtonWithPosition:(CGPoint)position title:(NSString *)title;
+ (id)blueBookButtonWithPosition:(CGPoint)position title:(NSString *)title;

@end