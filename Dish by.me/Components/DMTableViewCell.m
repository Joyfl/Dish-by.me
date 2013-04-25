//
//  DMTableViewself.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 25..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMTableViewCell.h"

@implementation DMTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	self.textLabel.font = [UIFont systemFontOfSize:16];
	self.textLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
	self.textLabel.backgroundColor = self.detailTextLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.07];
	self.textLabel.shadowOffset = CGSizeMake( 0, 1 );
	
	self.detailTextLabel.font = [UIFont systemFontOfSize:15];
	self.detailTextLabel.textColor = [UIColor colorWithHex:0x888583 alpha:1];
	self.detailTextLabel.backgroundColor = self.detailTextLabel.backgroundColor = [UIColor clearColor];
	self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.04];
	self.detailTextLabel.shadowOffset = CGSizeMake( 0, 1 );
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	UITableView *tableView = (UITableView *)self.superview;
	NSIndexPath *indexPath = [tableView indexPathForCell:self];
	
	NSInteger rowCount = [tableView numberOfRowsInSection:indexPath.section];
	
	if( rowCount == 1 )
		self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 8, 8, 8, 8 )]];
	
	else if( indexPath.row == 0 )
		self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped_top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 8, 8, 2, 8 )]];
	
	else if( indexPath.row == rowCount - 1 )
		self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped_bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 8, 8, 8 )]];
	
	else
		self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped_middle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 2, 2, 2 )]];
}

@end
