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
	
	_photoButton = [[UIButton alloc] init];
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
	[_facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
	[_facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_selected.png"] forState:UIControlStateSelected];
	[_facebookButton addTarget:self action:@selector(facebookButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	_descriptionInput = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake( 15, 10, 290, 70 )];
	_descriptionInput.delegate = self;
	_descriptionInput.textColor = [UIColor colorWithHex:0x808283 alpha:1];
	_descriptionInput.placeholder = NSLocalizedString( @"INPUT_DESCRIPTION", nil );
	_descriptionInput.backgroundColor = [UIColor clearColor];
	_descriptionInput.font = [UIFont boldSystemFontOfSize:15];
	_descriptionInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_descriptionInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	
	_photoHeight = PhotoButtonMaxWidth;
	
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

// 수정
- (id)initWithDish:(Dish *)dish
{
	self = [self init];
	self.trackedViewName = @"WritingViewController (Edit)";
	self.navigationItem.title = NSLocalizedString( @"EDIT_DISH", @"요리 수정" );
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	_editingDishId = dish.dishId;
	
	if( dish.photo )
	{
		[_photoButton setBackgroundImage:dish.photo forState:UIControlStateNormal];
		[self resizePhotoButton];
	}
	else
	{
		if( dish.photoURL )
		{
			[DMAPILoader loadImageFromURLString:dish.photoURL context:nil success:^(UIImage *image, id context) {
				dish.photo = image;
				[_photoButton setBackgroundImage:image forState:UIControlStateNormal];
				[self resizePhotoButton];
			}];
		}
	}
	
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
		return 110;
	
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *photoCellId = @"photoCellId";
	static NSString *messageCellId = @"messageCellId";
	static NSString *recipeCellId = @"recipeCellId";
	
	UITableViewCell *cell = nil;
	
	if( indexPath.row == kRowPhoto )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:photoCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell.contentView addSubview:_photoButton];
			
			_borderView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dish_writing_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 45, 12 )]];
			[cell.contentView addSubview:_borderView];
			[cell.contentView addSubview:_nameInput];
			[cell.contentView addSubview:_facebookButton];
		}
		
		NSLog( @"photoHeight : %d", _photoHeight );
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
			
			UIImageView *messageBoxView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"message_box.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 24, 12, 10 )]];
			messageBoxView.frame = CGRectMake( 9, 0, 304, 100 );
			[cell.contentView addSubview:messageBoxView];
			[cell.contentView addSubview:_descriptionInput];
		}
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
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadButtonDidTouchUpInside
{
	if( !_nameInput.text.length )
	{
		[_nameInput setValue:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1] forKeyPath:@"placeholderLabel.textColor"];
		[_nameInput shakeCount:3 radius:4 duration:0.05 delay:0 completion:^{
			[_nameInput becomeFirstResponder];
		}];
		return;
	}
	else if( !_descriptionInput.text.length )
	{
		_descriptionInput.placeHolderLabel.textColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
		[_descriptionInput shakeCount:3 radius:4 duration:0.05 delay:0 completion:^{
			[_descriptionInput becomeFirstResponder];
		}];
		return;
	}
	
	UIImage *image = [_photoButton backgroundImageForState:UIControlStateNormal];
	
	[self backgroundDidTap];
	[self dim];
	[(DMBarButtonItem *)self.navigationItem.rightBarButtonItem button].showsActivityIndicatorView = YES;
	
	NSMutableDictionary *recipe = [NSMutableDictionary dictionary];
	[recipe setObject:[NSString stringWithFormat:@"%d", _recipeView.recipe.servings] forKey:@"servings"];
	[recipe setObject:[NSString stringWithFormat:@"%d", _recipeView.recipe.minutes] forKey:@"minutes"];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
								   @{ @"name": _nameInput.text,
								   @"description": _descriptionInput.text,
								   @"facebook_share": [NSNumber numberWithBool:_facebookButton.selected],
								   @"servings": [NSString stringWithFormat:@"%d", _recipeView.recipe.servings],
								   @"minutes": [NSString stringWithFormat:@"%d", _recipeView.recipe.minutes],
								   @"recipe_count": [NSString stringWithFormat:@"%d", _recipeView.recipe.contents.count] }];
	
	// 요리를 포크할 경우
	if( _originalDishId )
	{
		[params setObject:[NSString stringWithFormat:@"%d", _originalDishId] forKey:@"forked_from"];
	}
	
	NSInteger ingredientCount = 0;
	
	// 재료 파라미터
	for( NSInteger i = 0; i < _recipeView.recipe.ingredients.count; i++ )
	{
		Ingredient *ingredient = [_recipeView.recipe.ingredients objectAtIndex:i];
		if( ingredient.name )
		{
			[params setObject:ingredient.name forKey:[NSString stringWithFormat:@"ingredient_name_%d", i]];
			[params setObject:ingredient.amount ? ingredient.amount : @"" forKey:[NSString stringWithFormat:@"ingredient_amount_%d", i]];
			ingredientCount ++;
		}
	}
	
	[params setObject:[NSString stringWithFormat:@"%d", _recipeView.recipe.ingredients.count] forKey:@"ingredient_count"];
	
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
		[params setObject:content.description forKey:[NSString stringWithFormat:@"recipe_description_%d", i]];
		
		// 새로운 사진이 올라오지 않았을 경우 : photoURL을 POST 파라미터로 넘김
		if( content.photoURL )
		{
			JLLog( @"%d번째 레시피에 새로운 사진이 등록되지 않았음", i );
			[params setObject:content.photoURL forKey:[NSString stringWithFormat:@"recipe_photo_%d", i]];
		}
		// 새로운 사진이 등록되었을 경우 : Multipart로 사진 바이너리 전송
		else if( content.photo )
		{
			JLLog( @"%d번째 레시피에 새로운 사진이 등록되었음", i );
			[photos addObject:content.photo];
			[names addObject:[NSString stringWithFormat:@"recipe_photo_%d", i]];
		}
		
		// 사진이 없는 경우
		else
		{
			JLLog( @"No photo at index : %d", i );
			[self undim];
			[(DMBarButtonItem *)self.navigationItem.rightBarButtonItem button].showsActivityIndicatorView = NO;
			
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"OOPS", nil ) message:[NSString stringWithFormat:NSLocalizedString( @"MESSAGE_NO_PHOTO_ON_N_TH_RECIPE", nil ), i + 1] delegate:nil cancelButtonTitle:NSLocalizedString( @"OH_MY_MISTAKE", nil ) otherButtonTitles:nil] show];
			
			return;
		}
	}
	
	JLLog( @"params : %@", params );
	
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
	
	[[DMAPILoader sharedLoader] api:api method:method images:photos forNames:names fileNames:names parameters:params success:^(id response) {
		JLLog( @"Success" );
		[self undim];
		[self dismissViewControllerAnimated:YES completion:nil];
		[self.delegate writingViewControllerDidFinishUpload:self];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		[self undim];
		[(DMBarButtonItem *)self.navigationItem.rightBarButtonItem button].showsActivityIndicatorView = NO;
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)textViewDidBeginEditing:(id)sender
{
	[_tableView setContentOffset:CGPointMake( 0, _photoButton.frame.size.height - 40 ) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 - 216 );
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
								
								[Settings sharedSettings].facebook = [[FacebookSettings alloc] initWithDictionary:response];
								_facebookButton.selected = YES;
								
							} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
								
								[self undim];
								
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
							[self undim];
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
}

- (void)recipeButtonDidTouchUpInside
{
	[self backgroundDidTap];
	
	[UIView animateWithDuration:0.25 animations:^{
		_recipeButton.frame = CGRectMake( 0, 50, 320, 50 );
	}];
	
	[_recipeView presentAfterDelay:0.1];
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

@end
