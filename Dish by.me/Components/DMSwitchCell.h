//
//  DMSwitchCell.h
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 19..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMSwitchCellDelegate;

@interface DMSwitchCell : UITableViewCell
{
	UISwitch *_switchView;
}

@property (nonatomic, weak) id<DMSwitchCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end


@protocol DMSwitchCellDelegate

- (void)switchCell:(DMSwitchCell *)switchCell valueChanged:(BOOL)on atIndexPath:(NSIndexPath *)indexPath;

@end