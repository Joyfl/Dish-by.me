//
//  SignUpStepTwoViewController.m
//  Dish by.me
//
//  Created by 전수열 on 13. 3. 18..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "SignUpProfileViewController.h"
#import "DMBarButtonItem.h"
#import <QuartzCore/CALayer.h>
#import "HTBlock.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AuthViewController.h"
#import "CurrentUser.h"
#import "DMBookButton.h"
#import "UIButton+ActivityIndicatorView.h"

@implementation SignUpProfileViewController

- (id)initWithUserId:(NSInteger)userId facebookUserInfo:(NSDictionary *)facebookUserInfo
{
	_facebookUserInfo = facebookUserInfo;
	return [self initWithUserId:userId];
}

- (id)initWithUserId:(NSInteger)userId
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	
	self.navigationItem.title = NSLocalizedString( @"PROFILE", nil );
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 20 )];
	bgView.image = [UIImage imageNamed:@"book_background.png"];
	[self.view addSubview:bgView];
	
	UIImageView *paperView = [[UIImageView alloc] initWithFrame:CGRectMake( 7, 7, 305, 230 )];
	paperView.image = [[UIImage imageNamed:@"book_paper.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 10, 10, 10, 10 )];
	[self.view addSubview:paperView];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = NSLocalizedString( @"PROFILE", nil );
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
	titleLabel.textColor = [UIColor colorWithHex:0x4B4A47 alpha:1];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	[titleLabel sizeToFit];
	titleLabel.frame = CGRectOffset( titleLabel.frame, 160 - titleLabel.frame.size.width / 2, 30 );
	[self.view addSubview:titleLabel];
	
	UIImageView *borderView = [[UIImageView alloc] initWithFrame:CGRectMake( 28, 70, 90, 90 )];
	borderView.image = [[UIImage imageNamed:@"dish_tile_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 15, 15, 15, 15 )];
	[self.view addSubview:borderView];
	
	_userPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake( 35, 76, 76, 76 )];
	[_userPhotoButton setBackgroundImage:[UIImage imageNamed:@"profile_placeholder.png"] forState:UIControlStateNormal];
	[_userPhotoButton addTarget:self action:@selector(userPhotoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_userPhotoButton];
	
	_nameInput = [self inputFieldAtYPosition:87 placeholder:NSLocalizedString( @"NAME", nil )];
	_nameInput.returnKeyType = UIReturnKeyNext;
	[_nameInput addTarget:self action:@selector(inputFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:_nameInput];
	
	_bioInput = [self inputFieldAtYPosition:_nameInput.frame.origin.y + 40 placeholder:NSLocalizedString( @"BIO", nil )];
	_bioInput.returnKeyType = UIReturnKeyDone;
	[self.view addSubview:_bioInput];
	
	for( NSInteger i = 0; i < 2; i++ )
	{
		UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake( 127, 112 + 40 * i, 162, 5 )];
		lineView.image = [[UIImage imageNamed:@"book_line.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 5, 0, 5 )];
		[self.view addSubview:lineView];
	}
	
	_doneButton = [DMBookButton bookButtonWithPosition:CGPointMake( 30, 180 ) title:NSLocalizedString( @"DONE", nil )];
	_doneButton.enabled = NO;
	[_doneButton addTarget:self action:@selector(updateUserInfo) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_doneButton];
	
	// 페이스북으로 가입한 사용자들은 페이스북에서 정보 가져오기
	if( _facebookUserInfo )
	{
		self.trackedViewName = @"SignUpStepTwoViewController (Facebook)";
		
		_nameInput.text = [_facebookUserInfo objectForKey:@"name"];
		_bioInput.text = [_facebookUserInfo objectForKey:@"bio"];
		
		[self inputFieldEditingChanged:_nameInput];
		
		NSURL *profilePhotoURL = [NSURL URLWithString:[[[_facebookUserInfo objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
		[_userPhotoButton setImageWithURL:profilePhotoURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
		
		[_nameInput becomeFirstResponder];
	}
	else
	{
		self.trackedViewName = [self.class description];
		[_nameInput becomeFirstResponder];
	}
	
	return self;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (UITextField *)inputFieldAtYPosition:(CGFloat)y placeholder:(NSString *)placeholder
{
	UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake( 130, y, 155, 20 )];
	inputField.delegate = self;
	inputField.placeholder = placeholder;
	inputField.font = [UIFont boldSystemFontOfSize:13];
	inputField.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
	inputField.backgroundColor = [UIColor clearColor];
	inputField.layer.shadowOffset = CGSizeMake( 0, 1 );
	inputField.layer.shadowColor = [UIColor whiteColor].CGColor;
	inputField.layer.shadowOpacity = 1;
	inputField.layer.shadowRadius = 0;
	inputField.autocorrectionType = UITextAutocorrectionTypeNo;
	inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	return inputField;
}

- (void)inputFieldEditingChanged:(UITextField *)inputField
{
	if( _nameInput.text.length == 0 )
	{
		[_nameInput setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		_doneButton.enabled = NO;
	}
	else
	{
		_nameInput.textColor = [UIColor colorWithHex:0xADA8A3 alpha:1];
		_doneButton.enabled = YES;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if( textField.text.length > 0 )
	{
		if( textField == _nameInput )
		{
			[_bioInput becomeFirstResponder];
		}
		else if( _doneButton.enabled )
		{
			[self updateUserInfo];
		}
	}
	
	return NO;
}


#pragma mark -
#pragma mark Selectors

- (void)userPhotoButtonDidTouchUpInside
{
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
			
			[_userPhotoButton setImage:image forState:UIControlStateNormal];
		}];
		
		[picker setCancelBlock:^(UIImagePickerController *picker) {
			[picker dismissViewControllerAnimated:YES completion:nil];
		}];
		
	}] showInView:[[UIApplication sharedApplication] keyWindow]];
}


#pragma mark -
#pragma mark API

- (void)updateUserInfo
{
	NSString *name = _nameInput.text;
	if( name.length == 0 )
	{
		[_nameInput setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		[_nameInput becomeFirstResponder];
		return;
	}
	
	NSString *bio = _bioInput.text;
	
	[self.view endEditing:YES];
	[self setControlsEnabled:NO];
	
	UIImage *profilePhoto = [_userPhotoButton imageForState:UIControlStateNormal];
	
	NSDictionary *params = @{ @"name": name, @"bio": bio };
	[[DMAPILoader sharedLoader] api:@"/user" method:@"PUT" image:profilePhoto forName:@"photo" fileName:@"photo" parameters:params success:^(id response) {		
		[CurrentUser user].photo = profilePhoto;
		
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"WOW", nil ) message:NSLocalizedString( @"MESSAGE_PROFILE_UPDATE_COMPLETE", nil ) cancelButtonTitle:NSLocalizedString( @"YES", nil ) otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
			
			[(AuthViewController *)[self.navigationController.viewControllers objectAtIndex:0] getUserAndDismissViewController];
			
		}] show];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		[self setControlsEnabled:YES];
	}];
}

- (void)setControlsEnabled:(BOOL)controlsEnabled
{
	_nameInput.enabled = _bioInput.enabled = controlsEnabled;
	_doneButton.showsActivityIndicatorView = !controlsEnabled;
}

@end
