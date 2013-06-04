//
//  PhotoEditingViewController.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "WritingViewController.h"
#import "DMBarButtonItem.h"
#import "RecipeView.h"
#import "Utils.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "DMAPILoader.h"
#import "UIResponder+Dim.h"
#import "UIButton+ActivityIndicatorView.h"
#import "RecipeEditorViewController.h"
#import "Recipe.h"
#import "UIView+JLAnimations.h"
#import "Settings.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIButton+TouchAreaInsets.h"
#import "CurrentUser.h"

static const NSInteger PhotoButtonMaxWidth = 298;

@implementation WritingViewController

enum {
	kRowPhoto,
	kRowMessage,
	kRowRecipe,
};

// Private
- (id)init
{
	self = [super init];
	self.view.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	
	DMBarButtonItem *cancelButton = [DMBarButtonItem barButtonItemWithTitle:NSLocalizedString( @"CANCEL", @"" ) target:self action:@selector(cancelButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	DMBarButtonItem *uploadButton = [DMBarButtonItem barButtonItemWithTitle:NSLocalizedString( @"UPLOAD", @"" ) target:self action:@selector(uploadButtonDidTouchUpInside)];
	uploadButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = uploadButton;
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)];
	[self.view addGestureRecognizer:tapRecognizer];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 64 )];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundColor = [UIColor colorWithHex:0xF3EEEA alpha:1];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];
	
	_photoHeight = 232;
	
	_photoButton = [[UIButton alloc] init];
	[_photoButton setImage:[UIImage imageNamed:@"icon_camera.png"] forState:UIControlStateNormal];
	[_photoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
	[_photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	_nameInput = [[UITextField alloc] init];
	_nameInput.placeholder = NSLocalizedString( @"INPUT_DISH_NAME", @"" );
	_nameInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	_nameInput.font = [UIFont boldSystemFontOfSize:15];
	_nameInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_nameInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	[_nameInput addTarget:self action:@selector(textViewDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
	
	_facebookButton = [[UIButton alloc] init];
	_facebookButton.adjustsImageWhenHighlighted = NO;
	_facebookButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:DMUserDefaultsKeyShareToFacebook];
	[_facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
	[_facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_selected.png"] forState:UIControlStateSelected];
	[_facebookButton addTarget:self action:@selector(facebookButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	_descriptionInput = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake( 15, 10, 290, 35 )];
	_descriptionInput.delegate = self;
	_descriptionInput.scrollEnabled = NO;
	_descriptionInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	_descriptionInput.placeholder = NSLocalizedString( @"INPUT_DESCRIPTION", nil );
	_descriptionInput.backgroundColor = [UIColor clearColor];
	_descriptionInput.font = [UIFont boldSystemFontOfSize:15];
	_descriptionInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_descriptionInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	
	_photoCell = [[UITableViewCell alloc] init];
	_photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_borderView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dish_writing_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 45, 12 )]];
	
	[_photoCell.contentView addSubview:_photoButton];
	[_photoCell.contentView addSubview:_borderView];
	[_photoCell.contentView addSubview:_nameInput];
	[_photoCell.contentView addSubview:_facebookButton];
	
	
	_progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"]];
	_progressView.frame = CGRectOffset( _progressView.frame, 0, -_progressView.frame.size.height );
	_progressView.userInteractionEnabled = YES;
	[self.view addSubview:_progressView];
	
	_progressBarBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake( 11, 16, 267, 11 )];
	_progressBarBackgroundView.image = [UIImage imageNamed:@"progress_bar_bg.png"];
	[_progressView addSubview:_progressBarBackgroundView];
	
	_progressBar = [[UIImageView alloc] initWithFrame:CGRectMake( 1, 1, 0, 8 )];
	_progressBar.image = [[UIImage imageNamed:@"progress_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 0, 4, 0, 4 )];
	[_progressBarBackgroundView addSubview:_progressBar];
	
	_progressFailedLabel = [[UILabel alloc] init];
	_progressFailedLabel.text = NSLocalizedString( @"UPLOAD_FAILURE", @"업로드 실패" );
	_progressFailedLabel.textColor = [UIColor colorWithHex:0x8E8F8F alpha:1];
	_progressFailedLabel.backgroundColor = [UIColor clearColor];
	_progressFailedLabel.font = [UIFont boldSystemFontOfSize:14];
	_progressFailedLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.5];
	_progressFailedLabel.shadowOffset = CGSizeMake( 0, 1 );
	[_progressFailedLabel sizeToFit];
	_progressFailedLabel.center = CGPointMake( 160, 22 );
	_progressFailedLabel.hidden = YES;
	[_progressView addSubview:_progressFailedLabel];
	
	// 업로드 실패시 왼쪽에 뜨는 X 버튼
	_cancelButton = [[UIButton alloc] initWithFrame:CGRectMake( 10, 12, 20, 21 )];
	_cancelButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"progress_cancel_button.png"] forState:UIControlStateNormal];
	[_cancelButton addTarget:self action:@selector(stopButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_progressView addSubview:_cancelButton];
	
	_progressButton = [[UIButton alloc] initWithFrame:CGRectMake( 289, 12, 20, 21 )];
	_progressButton.touchAreaInsets = UIEdgeInsetsMake( 10, 10, 10, 10 );
	[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_cancel_button.png"] forState:UIControlStateNormal];
	[_progressButton addTarget:self action:@selector(progressButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[_progressView addSubview:_progressButton];
	
	return self;
}

// 새 요리
- (id)initWithNewDish
{
	self = [self init];
	self.trackedViewName = @"WritingViewController (New)";
	self.navigationItem.title = NSLocalizedString( @"NEW_DISH", @"새 요리" );
	
	_recipeView = [[RecipeEditorViewController alloc] initWithRecipe:nil];
	_recipeView.delegate = self;
	_recipeView.view.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 );
	
	return self;
}

//
// 수정
//
- (id)initWithDish:(Dish *)dish
{
	self = [self init];
	self.trackedViewName = @"WritingViewController (Edit)";
	self.navigationItem.title = NSLocalizedString( @"EDIT_DISH", @"요리 수정" );
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	_editingDishId = dish.dishId;
	
	[_photoButton setBackgroundImageWithURL:[NSURL URLWithString:dish.thumbnailURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[_photoButton setImage:nil forState:UIControlStateNormal];
		[_photoButton setBackgroundImage:image forState:UIControlStateNormal];
		[self resizePhotoButton];
	} failure:nil];
	[_photoButton setBackgroundImageWithURL:[NSURL URLWithString:dish.photoURL] placeholderImage:[_photoButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
	
	_nameInput.text = dish.dishName;
	_descriptionInput.text = dish.description;
	
	_recipeView = [[RecipeEditorViewController alloc] initWithRecipe:dish.recipe];
	_recipeView.delegate = self;
	_recipeView.view.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 );
	
	return self;
}

// 포크
- (id)initWithOriginalDishId:(NSInteger)dishId
{
	self = [self init];
	self.trackedViewName = @"WritingViewController (Fork)";
	self.navigationItem.title = NSLocalizedString( @"DO_FORK", @"포크하기" );
	
	_originalDishId = dishId;
	
	_recipeView = [[RecipeEditorViewController alloc] initWithRecipe:nil];
	_recipeView.delegate = self;
	_recipeView.view.center = CGPointMake( UIScreenWidth / 2, UIScreenHeight / 2 );
	
	return self;
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( indexPath.row == kRowPhoto )
		return _photoHeight + 52;
	
	if( indexPath.row == kRowMessage )
		return _descriptionInput.contentSize.height + 30;
	
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *messageCellId = @"messageCellId";
	static NSString *recipeCellId = @"recipeCellId";
	
	UITableViewCell *cell = nil;
	
	if( indexPath.row == kRowPhoto )
	{
		cell = _photoCell;
		
		_photoButton.frame = CGRectMake( 11, 11, PhotoButtonMaxWidth, _photoHeight );
		_borderView.frame = _borderView.frame = CGRectMake( 5, 5, 310, _photoButton.frame.size.height + 42 );
		_nameInput.frame = CGRectMake( 20, _photoHeight + 12, 280, 20 );
		_facebookButton.frame = CGRectMake( 279, _photoHeight + 9, 24, 25 );
	}
	
	else if( indexPath.row == kRowMessage )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:messageCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			_messageBoxView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"message_box.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 24, 12, 10 )]];
			[cell.contentView addSubview:_messageBoxView];
			[cell.contentView addSubview:_descriptionInput];
		}
		
		_messageBoxView.frame = CGRectMake( 9, 0, 304, _descriptionInput.contentSize.height + 20 );
	}
	
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:recipeCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recipeCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIView *recipeButtonContainer = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 50 )];
			[cell.contentView addSubview:recipeButtonContainer];
			
			_recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, 320, 50 )];
			[_recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[_recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
			[_recipeButton setTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) forState:UIControlStateNormal];
			[_recipeButton setTitleColor:[UIColor colorWithHex:0x5B5046 alpha:1] forState:UIControlStateNormal];
			[_recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
			_recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
			_recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
			_recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
			[recipeButtonContainer addSubview:_recipeButton];
			
			CALayer *maskLayer = [CALayer layer];
			maskLayer.bounds = CGRectMake( 0, 0, 640, 100 );
			maskLayer.contents = (id)[UIImage imageNamed:@"placeholder"].CGImage;
			recipeButtonContainer.layer.mask = maskLayer;
			
			UIImageView *recipeBottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"]];
			recipeBottomLine.frame = CGRectMake( 0, 38, 320, 15 );
			[cell.contentView addSubview:recipeBottomLine];
		}
	}
	
	return cell;
}


#pragma mark -
#pragma mark Selectors

- (void)cancelButtonDidTouchUpInside
{
	if( _isPhotoChanged || _nameInput.text.length > 0 || _descriptionInput.text.length > 0 || _recipeView.recipe.servings > 0 || _recipeView.recipe.minutes > 0 || _recipeView.recipe.ingredients.count > 0 || _recipeView.recipe.contents.count > 0 )
	{
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_REALLY_CANCEL", nil ) cancelButtonTitle:NSLocalizedString( @"OH_MY_MISTAKE", nil ) otherButtonTitles:@[NSLocalizedString( @"YES", nil )] dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
			
			if( buttonIndex == 1 )
				[self dismissViewControllerAnimated:YES completion:nil];
			
		}] show];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)textViewDidBeginEditing:(id)sender
{
	[_tableView setContentOffset:CGPointMake( 0, _photoButton.frame.size.height - (IPHONE5 ? 112 : 24) ) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 - 216 );
	}];
}

- (void)textViewDidChange:(UITextView *)textView
{
	[_tableView beginUpdates];
	[_tableView endUpdates];
	
	[UIView animateWithDuration:0.25 animations:^{
		CGRect frame = _messageBoxView.frame;
		frame.size.height = _descriptionInput.contentSize.height + 20;
		_messageBoxView.frame = frame;
		
		frame = _descriptionInput.frame;
		frame.size.height = _descriptionInput.contentSize.height;
		_descriptionInput.frame = frame;
	}];
}

- (void)backgroundDidTap
{
	[self.view endEditing:YES];
	
	[UIView animateWithDuration:0.25 animations:^{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 );
	}];
}

- (void)photoButtonDidTouchUpInside
{
	[self backgroundDidTap];		
	[self presentActionSheet];
}

- (void)facebookButtonDidTouchUpInside
{
	// 페이스북 연동이 안되어있는데 페이스북 공유를 원할 경우
	if( !_facebookButton.selected && ![Settings sharedSettings].facebook )
	{
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_FACEBOOK_NOT_CONNECTED", nil ) cancelButtonTitle:NSLocalizedString( @"NO_THANKS", nil ) otherButtonTitles:@[NSLocalizedString( @"YES", nil )] dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
			if( buttonIndex == 1 )
			{
				// 아래 코드는 SettingsViewController의 코드와 동일함.
				[self.navigationController dim];
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
								[self.navigationController undim];
								JLLog( @"response : %@", response );
								
								[Settings sharedSettings].facebook = [[FacebookSettings alloc] initWithDictionary:response];
								_facebookButton.selected = YES;
								
							} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
								
								[self.navigationController undim];
								
								if( errorCode == 1401 )
								{
									[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:NSLocalizedString( @"MESSAGE_THIS_FACEBOOK_ACCOUNT_IS_ALREADY_LINKED", nil ) cancelButtonTitle:NSLocalizedString( @"I_GOT_IT", nil ) otherButtonTitles:nil dismissBlock:nil] show];
								}
								else
								{
									showErrorAlert();
								}
							}];
							break;
						}
							
						case FBSessionStateClosedLoginFailed:
							[self.navigationController undim];
							JLLog( @"FBSessionStateClosedLoginFailed (User canceled login to facebook)" );
							break;
							
						default:
							break;
					}
				}];
			}
		}] show];
		return;
	}
	_facebookButton.selected = !_facebookButton.selected;
	[[NSUserDefaults standardUserDefaults] setBool:_facebookButton.selected forKey:DMUserDefaultsKeyShareToFacebook];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)recipeButtonDidTouchUpInside
{
	[self backgroundDidTap];
	[self.navigationController dim];
	
	[UIView animateWithDuration:0.25 animations:^{
		_recipeButton.frame = CGRectMake( 0, 50, 320, 50 );
	}];
	
	self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[_recipeView presentAnimation];
		[self presentViewController:_recipeView animated:NO completion:nil];
	});
}

- (void)recipeEditorViewControllerWillDismiss:(RecipeEditorViewController *)recipeEditorView
{
	[self.navigationController undim];
}

- (void)recipeEditorViewControllerDidDismiss:(RecipeEditorViewController *)recipeEditorView
{
	[UIView animateWithDuration:0.25 animations:^{
		_recipeButton.frame = CGRectMake( 0, 0, 320, 50 );
	}];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)presentActionSheet
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString( @"CANCEL", @"" ) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString( @"TAKE_A_PHOTO", @"" ), NSLocalizedString( @"FROM_LIBRARY", @"" ), nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
	
	picker.delegate = self;
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:YES completion:nil];
	
	UIImage *image = [Utils scaleAndRotateImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
	
	// 카메라로 찍은 경우 앨범에 저장
	if( picker.sourceType == UIImagePickerControllerSourceTypeCamera )
		UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	[_photoButton setImage:nil forState:UIControlStateNormal];
	[_photoButton setBackgroundImage:image forState:UIControlStateNormal];
	[self resizePhotoButton];
	
	_isPhotoChanged = YES;
}

- (void)resizePhotoButton
{
	UIImage *image = [_photoButton backgroundImageForState:UIControlStateNormal];
	_photoHeight = PhotoButtonMaxWidth * image.size.height / image.size.width;
	[_tableView reloadData];
}

- (void)uploadButtonDidTouchUpInside
{
	if( !_nameInput.text.length )
	{
		[_nameInput setValue:[UIColor colorWithHex:0x5B1612 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		[_nameInput shakeCount:3 radius:4 duration:0.05 delay:0 completion:^{
			[_nameInput becomeFirstResponder];
		}];
		return;
	}
	else if( !_descriptionInput.text.length )
	{
		_descriptionInput.placeHolderLabel.textColor = [UIColor colorWithHex:0x5B1612 alpha:1];
		[_descriptionInput shakeCount:3 radius:4 duration:0.05 delay:0 completion:^{
			[_descriptionInput becomeFirstResponder];
		}];
		return;
	}
	
	[self backgroundDidTap];
	
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	_tableView.userInteractionEnabled = NO;
	[_tableView dim];
	
	dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ), ^{
		//
		// 업로드 UI 보여주기
		//
		dispatch_async( dispatch_get_main_queue(), ^{
			_progressState = DMProgressStateLoading;
			
			_progressBarBackgroundView.hidden = NO;
			_progressFailedLabel.hidden = YES;
			_cancelButton.hidden = YES;
			_progressButton.adjustsImageWhenHighlighted = YES;
			
			[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_cancel_button.png"] forState:UIControlStateNormal];
			
			[UIView animateWithDuration:0.25 animations:^{
				CGRect frame = _progressView.frame;
				frame.origin.y = 0;
				_progressView.frame = frame;
			}];
		} );
		
		UIImage *image = [_photoButton backgroundImageForState:UIControlStateNormal];
		
		
		//
		// 기본 내용
		//
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
									   @{ @"name": _nameInput.text,
									   @"description": _descriptionInput.text,
									   @"facebook_share": [NSNumber numberWithBool:_facebookButton.selected] }];
		
		// 요리를 포크할 경우
		if( _originalDishId )
		{
			[params setObject:[NSString stringWithFormat:@"%d", _originalDishId] forKey:@"forked_from"];
		}
		
		
		//
		// 레시피
		//
		NSMutableDictionary *ingredients = [NSMutableDictionary dictionary];
		
		// 재료 파라미터
		for( NSInteger i = 0; i < _recipeView.recipe.ingredients.count; i++ )
		{
			Ingredient *ingredient = [_recipeView.recipe.ingredients objectAtIndex:i];
			if( ingredient.name )
			{
				[ingredients setObject:ingredient.name forKey:[NSString stringWithFormat:@"ingredient_name_%d", i]];
				[ingredients setObject:ingredient.amount ? ingredient.amount : @"" forKey:[NSString stringWithFormat:@"ingredient_amount_%d", i]];
				JLLog( @"%@ = %@", [NSString stringWithFormat:@"ingredient_name_%d", i], ingredient.name );
				JLLog( @"%@ = %@", [NSString stringWithFormat:@"ingredient_amount_%d", i], ingredient.amount );
			}
		}
		
		// 사진, 레시피 파라미터
		// recipe_photo_%d : 레시피 사진 또는 URL
		// recipe_description_%d : 레시피 설명
		NSMutableArray *photos = [NSMutableArray array];
		NSMutableArray *names = [NSMutableArray array];
		
		if( _isPhotoChanged )
		{
			JLLog( @"새로운 사진이 등록되었음" );
			[photos addObject:image];
			[names addObject:@"photo"];
		}
		else
		{
			JLLog( @"새로운 사진이 등록되지 않았음" );
		}
		
		for( NSInteger i = 0; i < _recipeView.recipe.contents.count; i++ )
		{
			RecipeContent *content = [_recipeView.recipe.contents objectAtIndex:i];
			[params setObject:content.description.length > 0 ? content.description : @"" forKey:[NSString stringWithFormat:@"recipe_description_%d", i]];
			
			// 새로운 사진이 올라오지 않았을 경우 : photoURL을 POST 파라미터로 넘김
			if( content.photoURL )
			{
				JLLog( @"%d번째 레시피에 새로운 사진이 등록되지 않았음", i );
				[params setObject:content.photoURL forKey:[NSString stringWithFormat:@"recipe_photo_%d", i]];
				JLLog( @"%@ = %@", [NSString stringWithFormat:@"recipe_photo_%d", i], content.photoURL );
			}
			// 새로운 사진이 등록되었을 경우 : Multipart로 사진 바이너리 전송
			else if( content.photo )
			{
				JLLog( @"%d번째 레시피에 새로운 사진이 등록되었음", i );
				[photos addObject:content.photo];
				[names addObject:[NSString stringWithFormat:@"recipe_photo_%d", i]];
				JLLog( @"%@ = %@", [NSString stringWithFormat:@"recipe_photo_%d", i], content.photo );
			}
			
			// 사진이 없는 경우
			else
			{
				JLLog( @"No photo at index : %d", i );
				self.navigationItem.leftBarButtonItem.enabled = YES;
				self.navigationItem.rightBarButtonItem.enabled = YES;
				_tableView.userInteractionEnabled = YES;
				[_tableView undim];
				
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:[NSString stringWithFormat:NSLocalizedString( @"MESSAGE_NO_PHOTO_ON_N_TH_RECIPE", nil ), i + 1] delegate:nil cancelButtonTitle:NSLocalizedString( @"OH_MY_MISTAKE", nil ) otherButtonTitles:nil] show];
				
				return;
			}
		}
		
		if( _recipeView.recipe.servings > 0 )
		{
			[params setObject:[NSString stringWithFormat:@"%d", _recipeView.recipe.servings] forKey:@"servings"];
		}
		
		if( _recipeView.recipe.minutes > 0 )
		{
			[params setObject:[NSString stringWithFormat:@"%d", _recipeView.recipe.minutes] forKey:@"minutes"];
		}
		
		if( ingredients.count > 0 )
		{
			// name과 amount가 각각 들어가므로 2로 나눠줌
			[params setObject:[NSString stringWithFormat:@"%d", ingredients.count / 2] forKey:@"ingredient_count"];
			[params addEntriesFromDictionary:ingredients];
		}
		
		if( _recipeView.recipe.contents.count > 0 )
			[params setObject:[NSString stringWithFormat:@"%d", _recipeView.recipe.contents.count] forKey:@"recipe_count"];
		
		
		//
		// 업로드
		//
		NSString *api = nil;
		NSString *method = nil;
		if( !_editingDishId )
		{
			api = @"/dish";
			method = @"POST";
		}
		else
		{
			api = [NSString stringWithFormat:@"/dish/%d", _editingDishId];
			method = @"PUT";
		}
		
		JLLog( @"params : %@", params );
		
		_uploadOperation = [[DMAPILoader sharedLoader] api:api method:method images:photos forNames:names fileNames:names parameters:params upload:^(long long bytesLoaded, long long bytesTotal) {
			
			dispatch_async( dispatch_get_main_queue(), ^{
				CGRect frame = _progressBar.frame;
				frame.size.width = 265.0 * bytesLoaded / bytesTotal;
				_progressBar.frame = frame;
			} );
			
		} download:nil success:^(id response) {
			JLLog( @"Success : %@", response );
			
			[[(AppDelegate *)[UIApplication sharedApplication].delegate dishListViewController] updateDishes];
			
			dispatch_async( dispatch_get_main_queue(), ^{
				_progressState = DMProgressStateIdle;
				
				_progressButton.adjustsImageWhenHighlighted = NO;
				[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_check_icon.png"] forState:UIControlStateNormal];
				
				ProfileViewController *profileViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate profileViewController];
				profileViewController.user.dishCount ++;
				[profileViewController updateDishes];
				
				double delayInSeconds = 1.0;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[self.delegate writingViewControllerDidFinishUpload:self];
					[self dismissViewControllerAnimated:YES completion:nil];
				});
			} );
			
		} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
			self.navigationItem.leftBarButtonItem.enabled = YES;
			self.navigationItem.rightBarButtonItem.enabled = YES;
			_tableView.userInteractionEnabled = YES;
			[_tableView undim];
			
			JLLog( @"statusCode : %d", statusCode );
			JLLog( @"errorCode : %d", errorCode );
			JLLog( @"message : %@", message );
			
			dispatch_async( dispatch_get_main_queue(), ^{
				_progressState = DMProgressStateFailure;
				
				_progressBarBackgroundView.hidden = YES;
				_progressFailedLabel.hidden = NO;
				_cancelButton.hidden = NO;
				
				CGRect frame = _progressBar.frame;
				frame.size.width = 0;
				_progressBar.frame = frame;
				
				[_progressButton setBackgroundImage:[UIImage imageNamed:@"progress_retry_button.png"] forState:UIControlStateNormal];
			} );
		}];
	} );
}

- (void)progressButtonDidTouchUpInside
{
	// 업로드 취소
	if( _progressState == DMProgressStateLoading )
	{
		[_uploadOperation cancel];
		[self stopButtonDidTouchUpInside];
	}
	
	// 다시 시도
	else if( _progressState == DMProgressStateFailure )
	{
		[self uploadButtonDidTouchUpInside];
	}
}

- (void)stopButtonDidTouchUpInside
{
	_progressState = DMProgressStateIdle;
	_uploadOperation = nil;
	
	dispatch_async( dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:0.25 animations:^{
			CGRect frame = _progressView.frame;
			frame.origin.y = -_progressView.frame.size.height;
			_progressView.frame = frame;
		}];
		
		self.navigationItem.leftBarButtonItem.enabled = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		_tableView.userInteractionEnabled = YES;
		[_tableView undim];
	} );
}

@end
