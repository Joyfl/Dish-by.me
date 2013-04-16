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
#import "UIResponder+Dim.h"
#import "AuthViewController.h"
#import "AppDelegate.h"
#import "FacebookSettingsViewController.h"

@implementation SettingsViewController

enum {
	kSectionShareSettings,
	kSectionNotifications,
	kSectionLogout,
	sectionCount
};

enum {
	kRowFacebook,
	shareSettingsRowCount
};

enum {
	notificationSettingsRowCount
};

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 114 ) style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundView.hidden = YES;
	[self.view addSubview:_tableView];
	
	_loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_loadingIndicatorView.center = CGPointMake( UIScreenWidth / 2, 20 );
	[_loadingIndicatorView startAnimating];
	[self.view addSubview:_loadingIndicatorView];
	
	[self loadSettings];
	
    return self;
}


#pragma mark -

- (void)loadSettings
{
	JLLog( @"Load Settings" );
	
	_tableView.hidden = YES;
	
	[[DMAPILoader sharedLoader] api:@"/settings" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"설정 로드 완료 : %@", response );
		
		_settings = [NSMutableDictionary dictionaryWithDictionary:response];
		
		[_loadingIndicatorView removeFromSuperview];
		_tableView.hidden = NO;
		[_tableView reloadData];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		
	}];
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == kSectionShareSettings )
		return shareSettingsRowCount;
	
	else if( section == kSectionNotifications )
		return notificationSettingsRowCount;
	
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
	
	if( indexPath.section == kSectionShareSettings )
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:switchCellId];
		
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:switchCellId];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
			cell.textLabel.backgroundColor = cell.detailTextLabel.backgroundColor = [UIColor clearColor];
			cell.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.07];
			cell.textLabel.shadowOffset = CGSizeMake( 0, 1 );
		}
		
		if( indexPath.row == kRowFacebook )
		{
			cell.textLabel.text = NSLocalizedString( @"FACEBOOK", nil );
			cell.detailTextLabel.text = [_settings objectForKey:@"facebook"] ? [[_settings objectForKey:@"facebook"] objectForKey:@"name"] : nil;
		}
		
		return cell;
	}
	
	else if( indexPath.section == kSectionNotifications )
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
		
		cell.textLabel.text = @"댓글";
		
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
		if( indexPath.section == kRowFacebook )
		{
			// 연동되어있을 경우
			if( [_settings objectForKey:@"facebook"] )
			{
				FacebookSettingsViewController *facebookSettingsViewController = [[FacebookSettingsViewController alloc] initWithFacebookSettings:[_settings objectForKey:@"facebook"]];
				[self.navigationController pushViewController:facebookSettingsViewController animated:YES];
			}
			else
			{
				[self dim];
				FBSession *session = [[FBSession alloc] initWithAppID:@"115946051893330" permissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone urlSchemeSuffix:nil tokenCacheStrategy:nil];
				[FBSession setActiveSession:session];
				[session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
					JLLog( @"status : %d", status );
					switch( status )
					{
						case FBSessionStateOpen:
						{
							NSDictionary *params = @{ @"facebook_token": [[FBSession activeSession] accessToken] };
							[[DMAPILoader sharedLoader] api:@"/setting/facebook" method:@"PUT" parameters:params success:^(id response) {
								[self undim];
								JLLog( @"response : %@", response );
								
								[_settings setObject:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"og"] forKey:@"facebook"];
								[_tableView reloadData];
								
								FacebookSettingsViewController *facebookSettingsViewController = [[FacebookSettingsViewController alloc] initWithFacebookSettings:[_settings objectForKey:@"facebook"]];
								[self.navigationController pushViewController:facebookSettingsViewController animated:YES];
								
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
	
}


@end
