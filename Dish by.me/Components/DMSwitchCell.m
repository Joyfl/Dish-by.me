//
//  DMSwitchCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 19..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMSwitchCell.h"

@implementation DMSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	_switchView = [[UISwitch alloc] init];
	[_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
	self.accessoryView = _switchView;
	
	return self;
}

- (void)switchValueChanged
{
	[self.delegate switchCell:self valueChanged:_switchView.on atIndexPath:self.indexPath];
}

- (void)setOn:(BOOL)on
{
	[_switchView setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
	[_switchView setOn:on animated:animated];
}

- (BOOL)on
{
	return _switchView.on;
}

@end
