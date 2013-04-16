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

- (id)initWithSettings:(NSMutableDictionary *)settings
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	self.trackedViewName = [[self class] description];
	
	_settings = settings;
	
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"cellId";
	DMSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if( !cell )
	{
		cell = [[DMSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
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
		cell.textLabel.text = @"페이스북 로그인";
	}
	else
	{
		cell.textLabel.text = @"페이스북 활동 공유";
		cell.on = [[_settings objectForKey:@"facebook_activated"] boolValue];
	}
	
	return cell;
}


#pragma mark -

- (void)switchCell:(DMSwitchCell *)switchCell valueChanged:(BOOL)on atIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.row == 0 )
	{
		if( on )
		{
//			[self dim];
//			FBSession *session = [[FBSession alloc] initWithAppID:@"115946051893330" permissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone urlSchemeSuffix:nil tokenCacheStrategy:nil];
//			[FBSession setActiveSession:session];
//			[session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//				JLLog( @"status : %d", status );
//				switch( status )
//				{
//					case FBSessionStateOpen:
//					{
//						NSDictionary *params = @{ @"facebook_token": [[FBSession activeSession] accessToken] };
//						[[DMAPILoader sharedLoader] api:@"/settings" method:@"PUT" parameters:params success:^(id response) {
//							[self undim];
//							JLLog( @"response : %@", response );
//							
//							[_settings setObject:[NSNumber numberWithBool:on] forKey:@"facebookToken"];
//							
//						} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
//							[self undim];
//							showErrorAlert();
//						}];
//						break;
//					}
//						
//					case FBSessionStateClosedLoginFailed:
//						[self undim];
//						JLLog( @"FBSessionStateClosedLoginFailed (User canceled login to facebook)" );
//						break;
//						
//					default:
//						break;
//				}
//			}];
		}
	}
	else
	{
		NSDictionary *params = @{ @"facebook_activated": [NSNumber numberWithBool:on] };
		[[DMAPILoader sharedLoader] api:@"/settings" method:@"PUT" parameters:params success:^(id response) {
			[_settings setObject:[NSNumber numberWithBool:on] forKey:@"facebook_activated"];
			
		} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
			showErrorAlert();
		}];
	}
}

@end
