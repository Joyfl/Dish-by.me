//
//  CoverView.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 28..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverView : UIImageView

- (void)open;
- (void)openAfterDelay:(NSTimeInterval)delay;
- (void)closeCompletion:(void (^)(CoverView *coverView))completion;

@end
