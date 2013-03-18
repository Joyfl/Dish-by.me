//
//  SignUpStepTwoViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 18..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "SignUpStepTwoViewController.h"
#import "DMBarButtonItem.h"
#import <QuartzCore/CALayer.h>
#import "UIViewController+Dim.h"
#import "HTBlock.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import "CurrentUser.h"

@implementation SignUpStepTwoViewController

- (id)initWithUserId:(NSInteger)userId facebookAccessToken:(NSString *)facebookAccessToken
{
	_facebookAccessToken = facebookAccessToken;
	return [self initWithUserId:userId];
}

- (id)initWithUserId:(NSInteger)userId
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.title = NSLocalizedString( @"PROFILE", nil );
	self.navigationItem.rightBarButtonItem = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"DONE", nil ) target:self action:@selector(updateUserInfo)];
	
	_profilePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake( 20, 20, 110, 110 )];
	[_profilePhotoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
	[_profilePhotoButton addTarget:self action:@selector(userPhotoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_profilePhotoButton];
	
	_nameInput = [[UITextField alloc] initWithFrame:CGRectMake( 140, 20, 170, 31 )];
	_nameInput.delegate = self;
	_nameInput.placeholder = NSLocalizedString( @"NAME", @"" );
	_nameInput.font = [UIFont boldSystemFontOfSize:13];
	_nameInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	_nameInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_nameInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	_nameInput.layer.shadowOpacity = 1;
	_nameInput.layer.shadowRadius = 0;
	_nameInput.keyboardType = UIKeyboardTypeEmailAddress;
	_nameInput.returnKeyType = UIReturnKeyNext;
	_nameInput.autocorrectionType = UITextAutocorrectionTypeNo;
	_nameInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[_nameInput setValue:[UIColor colorWithHex:0xC6C3BF alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	[self.view addSubview:_nameInput];
	
	_bioInput = [[UITextField alloc] initWithFrame:CGRectMake( 140, 57, 170, 31 )];
	_bioInput.delegate = self;
	_bioInput.placeholder = NSLocalizedString( @"BIO", @"" );
	_bioInput.font = [UIFont boldSystemFontOfSize:13];
	_bioInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	_bioInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_bioInput.layer.shadowColor = [UIColor whiteColor].CGColor;
	_bioInput.layer.shadowOpacity = 1;
	_bioInput.layer.shadowRadius = 0;
	_bioInput.returnKeyType = UIReturnKeyGo;
	[_bioInput setValue:[UIColor colorWithHex:0xC6C3BF alpha:1] forKeyPath:@"placeholderLabel.textColor"];
	[self.view addSubview:_bioInput];
	
	if( _facebookAccessToken )
	{
		self.trackedViewName = @"SignUpStepTwoViewController (Facebook)";
		
		[self dim];
		
		[[FBRequest requestForGraphPath:@"/me?fields=id,name,bio,picture.width(200).height(200)"] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
			[self undim];
			
			_nameInput.text = user.name;
			_bioInput.text = [user objectForKey:@"bio"];
			
			NSURL *profilePhotoURL = [NSURL URLWithString:[[[user objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
			[_profilePhotoButton setImageWithURL:profilePhotoURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
			
			[_nameInput becomeFirstResponder];
		}];
	}
	else
	{
		self.trackedViewName = [self.class description];
		[_nameInput becomeFirstResponder];
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark -
#pragma mark Selectors

- (void)userPhotoButtonDidTouchUpInside
{
	[_nameInput resignFirstResponder];
	[_bioInput resignFirstResponder];
	
	[[[UIActionSheet alloc] initWithTitle:nil cancelButtonTitle:NSLocalizedString( @"CANCEL", nil ) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString( @"TAKE_A_PHOTO", nil ), NSLocalizedString( @"FROM_LIBRARY", nil )] dismissBlock:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
		
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		
		if( buttonIndex == 0 ) // Camera
		{
			@try
			{
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			}
			@catch( NSException *exception )
			{
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", @"" ) message:NSLocalizedString( @"MESSAGE_NO_SUPPORT_CAMERA", @"" ) delegate:self cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", @"" ) otherButtonTitles:nil] show];
				return;
			}
			
			picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
		}
		else if( buttonIndex == 1 ) // Album
		{
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		}
		else
		{
			return;
		}
		
		picker.allowsEditing = YES;
		[self presentViewController:picker animated:YES completion:nil];
		
		[picker setFinishBlock:^(UIImagePickerController *picker, NSDictionary *info) {
			[picker dismissViewControllerAnimated:YES completion:nil];
			
			UIImage *image = [Utils scaleAndRotateImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
			
			// 카메라로 찍은 경우 앨범에 저장
			if( picker.sourceType == UIImagePickerControllerSourceTypeCamera )
				UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
			
			[_profilePhotoButton setImage:image forState:UIControlStateNormal];
		}];
		
		[picker setCancelBlock:^(UIImagePickerController *picker) {
			[picker dismissViewControllerAnimated:YES completion:nil];
		}];
		
	}] showInView:[[UIApplication sharedApplication] keyWindow]];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if( textField == _nameInput )
	{
		[_bioInput becomeFirstResponder];
		return NO;
	}
	
	[self updateUserInfo];
	
	return NO;
}


#pragma mark -
#pragma mark API

- (void)updateUserInfo
{
	NSString *name = _nameInput.text;
	if( name.length == 0 )
	{
		[_nameInput becomeFirstResponder];
		return;
	}
	
	NSString *bio = _bioInput.text;
	
	[_nameInput resignFirstResponder];
	[_bioInput resignFirstResponder];
	[self dim];
	
	UIImage *profilePhoto = [_profilePhotoButton imageForState:UIControlStateNormal];
	
	NSDictionary *params = @{ @"name": name, @"bio": bio };
	[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" image:profilePhoto parameters:params success:^(id response) {
		[self undimAnimated:NO];
		
		[CurrentUser user].photo = profilePhoto;
		
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"WOW", nil ) message:NSLocalizedString( @"MESSAGE_PROFILE_UPDATE_COMPLETE", nil ) cancelButtonTitle:NSLocalizedString( @"YES", nil ) otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
			
			[self getUser];
			
		}] show];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		
	}];
}

- (void)getUser
{
	[self dim];
	
	JLLog( @"getUser" );
	[[DMAPILoader sharedLoader] api:@"/user" method:@"GET" parameters:nil success:^(id response) {
		JLLog( @"getUser success" );
		
		[self undim];
		
		[[CurrentUser user] updateToDictionary:response];
		[[CurrentUser user] save];
		
		LoginViewController *loginViewController = [self.navigationController.viewControllers objectAtIndex:0];
		[loginViewController.delegate loginViewControllerDidSucceedLogin:loginViewController];
		
		[self dismissViewControllerAnimated:YES completion:nil];
		
		[[FBSession activeSession] closeAndClearTokenInformation];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		[self undim];
		showErrorAlert();
	}];
}

@end
