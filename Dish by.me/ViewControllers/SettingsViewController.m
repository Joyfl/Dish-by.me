//
//  SettingsViewController.m
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 14..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "SettingsViewController.h"
#import "CurrentUser.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIViewController+Dim.h"
#import "AuthViewController.h"
#import "AppDelegate.h"

@implementation SettingsViewController

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
	
	_sharingSettings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:DMUserDefaultsKeySharingSettings]];
	
    return self;
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{	
	if( section == kSectionShareSettings )
		return NSLocalizedString( @"SHARE_SETTINGS", @"공유 설정" );
	
	else if( section == kSectionNotifications )
		return NSLocalizedString( @"PUSH_NOTIFICATIONS_SETTINGS", @"푸시 알림 설정" );
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if( section == kSectionLogout )
		return [NSString stringWithFormat:@"Version : %@ (Build %@)", VERSION, BUILD];
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *switchCellId = @"switchCellId";
	static NSString *cellId = @"cellId";
	
	if( indexPath.section < 2 )
	{
		DMSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:switchCellId];
		
		if( !cell )
		{
			cell = [[DMSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:switchCellId];
			cell.delegate = self;
			cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			cell.textLabel.backgroundColor = cell.detailTextLabel.backgroundColor = [UIColor clearColor];
			cell.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.07];
			cell.textLabel.shadowOffset = CGSizeMake( 0, 1 );
		}
		
		cell.indexPath = indexPath;
		
		if( indexPath.section == kSectionShareSettings )
		{
			if( indexPath.row == 0 )
			{
				cell.textLabel.text = @"Facebook";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.on = [[_sharingSettings objectForKey:@"facebook"] boolValue];
			}
		}
		
		else if( indexPath.section == kSectionNotifications )
		{
			cell.textLabel.text = @"댓글";
		}
		
		return cell;
	}
		
	else if( indexPath.section == kSectionLogout )
	{
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
		
		cell.textLabel.text = @"로그아웃";
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if( indexPath.section == kSectionShareSettings )
	{
		if( indexPath.section == 0 )
		{
			
		}
	}
	
	else if( indexPath.section == kSectionLogout )
	{
		[[CurrentUser user] logout];
		
		AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
		[AuthViewController presentAuthViewControllerFromViewController:appDelegate.tabBarController delegate:appDelegate];
	}
	
	[tableView reloadData];
}


#pragma mark -
#pragma mark DMSwitchCellDelegate

- (void)switchCell:(DMSwitchCell *)switchCell valueChanged:(BOOL)on atIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == kSectionShareSettings )
	{
		// Facebook
		if( indexPath.row == 0 )
		{
			if( on == YES )
			{
				[self dim];
				[FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
					JLLog( @"status : %d", status );
					switch( status )
					{
						case FBSessionStateOpen:
						{
							NSDictionary *params = @{ @"facebook_token": [[FBSession activeSession] accessToken] };
							[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" parameters:params success:^(id response) {
								[self undim];
								JLLog( @"response : %@", response );
							} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
								[self undim];
								showErrorAlert();
							}];
							break;
						}
							
						case FBSessionStateClosedLoginFailed:
							[self undim];
							JLLog( @"FBSessionStateClosedLoginFailed (User canceled login to facebook)" );
							break;
							
						default:
							break;
					}
				}];
			}
			
			
			
			
			[_sharingSettings setObject:[NSNumber numberWithBool:on] forKey:@"facebook"];
			[[NSUserDefaults standardUserDefaults] setObject:_sharingSettings forKey:DMUserDefaultsKeySharingSettings];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}


@end
