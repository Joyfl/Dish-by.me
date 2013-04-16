//
//  FacebookSettingsViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 16..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "FacebookSettingsViewController.h"
#import "DMBarButtonItem.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIResponder+Dim.h"

@implementation FacebookSettingsViewController

- (id)initWithFacebookSettings:(NSMutableDictionary *)facebookSettings
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	self.navigationItem.title = NSLocalizedString( @"FACEBOOK", nil );
	
	_facebookSettings = facebookSettings;
	
	[DMBarButtonItem setBackButtonToViewController:self];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundView.hidden = YES;
	[self.view addSubview:_tableView];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[_tableView reloadData];
}


#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *switchCellId = @"switchCellId";
	static NSString *disconnectCellId = @"disconnectCellId";
	
	if( indexPath.section == 0 )
	{
		DMSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:switchCellId];
		if( !cell )
		{
			cell = [[DMSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchCellId];
			cell.delegate = self;
			cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			cell.textLabel.backgroundColor = cell.detailTextLabel.backgroundColor = [UIColor clearColor];
			cell.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.07];
			cell.textLabel.shadowOffset = CGSizeMake( 0, 1 );
		}
		
		cell.indexPath = indexPath;
		
		if( indexPath.row == 0 )
		{
			cell.textLabel.text = NSLocalizedString( @"SHARE_ACTIVITIES", nil );
			cell.on = [[_facebookSettings objectForKey:@"og"] boolValue];
		}
		
		return cell;
	}
	
	// 연동 해제
	else
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:disconnectCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:disconnectCellId];
			cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			cell.textLabel.backgroundColor = cell.detailTextLabel.backgroundColor = [UIColor clearColor];
			cell.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.07];
			cell.textLabel.shadowOffset = CGSizeMake( 0, 1 );
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.textLabel.text = NSLocalizedString( @"DISCONNECT", nil );
		}
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if( indexPath.section == 1 )
	{
		
	}
}


#pragma mark -

- (void)switchCell:(DMSwitchCell *)switchCell valueChanged:(BOOL)on atIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.row == 0 )
	{
		NSDictionary *params = @{ @"facebook_activated": [NSNumber numberWithBool:on] };
		[[DMAPILoader sharedLoader] api:@"/settings" method:@"PUT" parameters:params success:^(id response) {
			[_facebookSettings setObject:[NSNumber numberWithBool:on] forKey:@"facebook_activated"];
			
		} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
			showErrorAlert();
		}];
	}
}

@end
