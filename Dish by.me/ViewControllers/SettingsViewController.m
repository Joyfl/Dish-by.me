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
#import "DMTextFieldViewController.h"
#import "DMTableViewCell.h"

@implementation SettingsViewController

enum {
	kSectionAccountSettings,
	kSectionShareSettings,
	kSectionNotifications,
	kSectionLogout,
	sectionCount
};

// 계정 
enum {
	kRowChangeEmail,
	kRowChangePassword,
};

enum {
	kRowFacebook,
	shareSettingsRowCount
};

enum {
	kRowFollow,
	kRowBookmark,
	kRowComment,
	kRowFork,
	notificationSettingsRowCount
};

- (id)init
{
    self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	self.navigationItem.title = NSLocalizedString( @"SETTINGS", nil );
	
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

- (void)viewWillAppear:(BOOL)animated
{
	[_tableView reloadData];
}


#pragma mark -

- (void)loadSettings
{
	JLLog( @"Load Settings" );
	
	_tableView.hidden = YES;
	
	[[DMAPILoader sharedLoader] api:@"/settings" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"설정 로드 완료 : %@", response );
		
		_settings = [[Settings alloc] initWithDictionary:response];
		
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
	if( section == kSectionAccountSettings )
		return 2;
	
	if( section == kSectionShareSettings )
		return shareSettingsRowCount;
	
	else if( section == kSectionNotifications )
		return notificationSettingsRowCount;
	
	else if( section == kSectionLogout )
		return 1;
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if( section == sectionCount - 1 )
		return 0;
	return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	static NSString *headerViewId = @"headerViewId";
	UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
	if( !headerView )
	{
		headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
		headerView.textLabel.font = [UIFont boldSystemFontOfSize:15];
		headerView.textLabel.textColor = [UIColor colorWithHex:0x726C6C alpha:1];
		headerView.textLabel.shadowColor = [UIColor whiteColor];
		headerView.textLabel.shadowOffset = CGSizeMake( 0, 1 );
	}
	
	if( section == kSectionAccountSettings )
		headerView.textLabel.text = NSLocalizedString( @"ACCOUNT_SETTINGS", @"계정 설정" );
	
	else if( section == kSectionShareSettings )
		headerView.textLabel.text = NSLocalizedString( @"SHARE_SETTINGS", @"공유 설정" );
	
	else if( section == kSectionNotifications )
		headerView.textLabel.text = NSLocalizedString( @"PUSH_NOTIFICATIONS_SETTINGS", @"푸시 알림 설정" );
	
	else
		headerView.textLabel.text = nil;
	
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if( section == kSectionLogout )
		return 50;
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	static NSString *footerViewId = @"footerViewId";
	UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerViewId];
	if( !footerView )
	{
		footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:footerViewId];
		footerView.textLabel.font = [UIFont systemFontOfSize:14];
		footerView.textLabel.textColor = [UIColor colorWithHex:0x4A4746 alpha:1];
		footerView.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.07];
		footerView.textLabel.shadowOffset = CGSizeMake( 0, 1 );
	}
	
	if( section == kSectionLogout )
		footerView.textLabel.text = [NSString stringWithFormat:@"Version : %@ (Build %@)", VERSION, BUILD];
	
	else
		footerView.textLabel.text = nil;
	
	return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *switchCellId = @"switchCellId";
	static NSString *cellId = @"cellId";
	
	if( indexPath.section == kSectionAccountSettings )
	{
		DMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
		
		if( !cell )
		{
			cell = [[DMTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		if( indexPath.row == kRowChangeEmail )
		{
			cell.textLabel.text = NSLocalizedString( @"CHANGE_EMAIL", nil );
			cell.detailTextLabel.text = [CurrentUser user].email;
		}
		else if( indexPath.row == kRowChangePassword )
		{
			cell.textLabel.text = NSLocalizedString( @"CHANGE_PASSWORD", nil );
			cell.detailTextLabel.text = nil;
		}
		
		return cell;
	}
	
	else if( indexPath.section == kSectionShareSettings )
	{
		DMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
		
		if( !cell )
		{
			cell = [[DMTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		if( indexPath.row == kRowFacebook )
		{
			cell.textLabel.text = NSLocalizedString( @"FACEBOOK", nil );
			cell.detailTextLabel.text = _settings.facebook ? _settings.facebook.name : nil;
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
		}
		
		cell.indexPath = indexPath;
		
		if( indexPath.row == kRowFollow )
		{
			cell.textLabel.text = NSLocalizedString( @"FOLLOW", nil );
			cell.on = _settings.notifications.follow;
		}
		
		else if( indexPath.row == kRowBookmark )
		{
			cell.textLabel.text = NSLocalizedString( @"BOOKMARK", nil );
			cell.on = _settings.notifications.bookmark;
		}
		
		else if( indexPath.row == kRowComment )
		{
			cell.textLabel.text = NSLocalizedString( @"COMMENT", nil );
			cell.on = _settings.notifications.comment;
		}
		
		else if( indexPath.row == kRowFork )
		{
			cell.textLabel.text = NSLocalizedString( @"FORK", nil );
			cell.on = _settings.notifications.fork;
		}
		
		return cell;
	}
		
	else if( indexPath.section == kSectionLogout )
	{
		DMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if( !cell )
		{
			cell = [[DMTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
		}
		
		cell.textLabel.text = NSLocalizedString( @"LOGOUT", nil );
		cell.detailTextLabel.text = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if( indexPath.section == kSectionAccountSettings )
	{
		if( indexPath.row == kRowChangeEmail )
		{
			DMTextFieldViewController *textFieldViewController = [[DMTextFieldViewController alloc] initWithTitle:NSLocalizedString( @"CHANGE_EMAIL", nil ) shouldComplete:^BOOL(DMTextFieldViewController *textFieldViewController, NSString *text) {
				
				[textFieldViewController dim];
				
				NSDictionary *params = @{ @"email": text };
				[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" parameters:params success:^(id response) {
					
					[CurrentUser user].email = text;
					[_tableView reloadData];
					[textFieldViewController.navigationController popViewControllerAnimated:YES];
					[textFieldViewController undim];
					
				} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
					showErrorAlert();
					[textFieldViewController undim];
				}];
				
				return NO;
			}];
			textFieldViewController.trackedViewName = @"DMTextFieldViewController (Email)";
			textFieldViewController.textField.placeholder = [CurrentUser user].email;
			[self.navigationController pushViewController:textFieldViewController animated:YES];
		}
		
		else if( indexPath.row == kRowChangePassword )
		{
			DMTextFieldViewController *textFieldViewController = [[DMTextFieldViewController alloc] initWithTitle:NSLocalizedString( @"CHANGE_PASSWORD", nil ) shouldComplete:^BOOL(DMTextFieldViewController *textFieldViewController, NSString *text) {
				
				[textFieldViewController dim];
				
				NSDictionary *params = @{ @"password": [Utils sha1:text] };
				[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" parameters:params success:^(id response) {
					
					[textFieldViewController.navigationController popViewControllerAnimated:YES];
					[textFieldViewController undim];
					
				} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
					showErrorAlert();
					[textFieldViewController undim];
				}];
				
				return NO;
			}];
			textFieldViewController.trackedViewName = @"DMTextFieldViewController (Password)";
			textFieldViewController.textField.secureTextEntry = YES;
			textFieldViewController.textField.placeholder = @"********";
			[self.navigationController pushViewController:textFieldViewController animated:YES];
		}
	}
	
	if( indexPath.section == kSectionShareSettings )
	{
		if( indexPath.row == kRowFacebook )
		{
			// 연동되어있을 경우
			if( _settings.facebook )
			{
				FacebookSettingsViewController *facebookSettingsViewController = [[FacebookSettingsViewController alloc] initWithSettings:_settings];
				[self.navigationController pushViewController:facebookSettingsViewController animated:YES];
			}
			else
			{
				[self dim];
				FBSession *session = [[FBSession alloc] initWithAppID:@"115946051893330" permissions:@[@"publish_actions", @"email"] defaultAudience:FBSessionDefaultAudienceEveryone urlSchemeSuffix:nil tokenCacheStrategy:nil];
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
								
								_settings.facebook = [[FacebookSettings alloc] initWithDictionary:response];
								[_tableView reloadData];
								
								FacebookSettingsViewController *facebookSettingsViewController = [[FacebookSettingsViewController alloc] initWithSettings:_settings];
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
		[[[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"REALLY_LOGOUT", nil ) cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:NSLocalizedString( @"LOGOUT", nil ) otherButtonTitles:nil dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
			if( buttonIndex == 0 )
			{
				[[CurrentUser user] logout];
				
				AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
				[appDelegate presentAuthViewControllerWithClosingAnimation:YES];
			}
		}] showInView:self.tabBarController.view];
	}
}


#pragma mark -
#pragma mark DMSwitchCellDelegate

- (void)switchCell:(DMSwitchCell *)switchCell valueChanged:(BOOL)on atIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.section == kSectionNotifications )
	{
		NSDictionary *params = nil;
		
		if( indexPath.row == kRowFollow )
		{
			params = @{ @"follow": [NSNumber numberWithBool:on] };
		}
		
		else if( indexPath.row == kRowBookmark )
		{
			params = @{ @"bookmark": [NSNumber numberWithBool:on] };
		}
		
		else if( indexPath.row == kRowComment )
		{
			params = @{ @"comment": [NSNumber numberWithBool:on] };
		}
		
		else if( indexPath.row == kRowFork )
		{
			params = @{ @"fork": [NSNumber numberWithBool:on] };
		}
		
		[[DMAPILoader sharedLoader] api:@"/setting/notifications" method:@"PUT" parameters:params success:^(id response) {
			
			JLLog( @"response : %@", response );
			
		} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
			showErrorAlert();
		}];
	}
}


@end
