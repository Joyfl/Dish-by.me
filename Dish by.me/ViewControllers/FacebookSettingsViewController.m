//
//  FacebookSettingsViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 2. 25..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "FacebookSettingsViewController.h"

@implementation FacebookSettingsViewController

enum {
	kSectionShareSettings,
	kSectionNotifications,
	kSectionLogout
};

- (id)init
{
    self = [super init];
	self.trackedViewName = [[self class] description];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundView.hidden = YES;
	[self.view addSubview:_tableView];
	
    return self;
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if( section == kSectionShareSettings )
		return NSLocalizedString( @"SHARE_SETTINGS", @"공유 설정" );
	
	else if( section == kSectionNotifications )
		return NSLocalizedString( @"PUSH_NOTIFICATIONS_SETTINGS", @"푸시 알림 설정" );
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == kSectionShareSettings )
		return 1;
	
	else if( section == kSectionNotifications )
		return 5;
	
	else if( section == kSectionLogout )
		return 1;
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"cellId";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if( !cell )
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
		cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.textLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
		cell.textLabel.backgroundColor = cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.07];
		cell.textLabel.shadowOffset = CGSizeMake( 0, 1 );
	}
	
//	NSInteger rowCount = [tableView numberOfRowsInSection:indexPath.section];
//
//	if( rowCount == 1 )
//		cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 8, 8, 8, 8 )]];
//
//	else if( indexPath.row == 0 )
//		cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped_top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 8, 8, 2, 8 )]];
//
//	else if( indexPath.row == rowCount - 1 )
//		cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped_bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 8, 8, 8 )]];
//
//	else
//		cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_grouped_middle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 2, 2, 2 )]];
//
//	cell.accessoryView = nil;
	
	if( indexPath.section == kSectionShareSettings )
	{
		if( indexPath.row == 0 )
		{
			cell.textLabel.text = @"Facebook";
		}
	}
	
	else if( indexPath.section == kSectionNotifications )
	{
		cell.textLabel.text = @"댓글";
	}
	
	else if( indexPath.section == kSectionLogout )
	{
		cell.textLabel.text = @"로그아웃";
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if( indexPath.section == kSectionLogout )
	{
		
	}
	
	[tableView reloadData];
}

@end
