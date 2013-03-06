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
#import "DishByMeAPILoader.h"
#import "NSObject+Dim.h"

static const NSInteger PhotoButtonMaxWidth = 298;

@implementation WritingViewController

enum {
	kRowPhoto,
	kRowMessage,
	kRowRecipe,
};

- (id)init
{
	return [self initWithOriginalDishId:0];
}

- (id)initWithOriginalDishId:(NSInteger)dishId
{
	self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	if( !dishId )
	{
		self.trackedViewName = @"WritingViewController (New)";
		self.navigationItem.title = NSLocalizedString( @"NEW_DISH", @"새 요리" );
	}
	else
	{
		self.trackedViewName = @"WritingViewController (Fork)";
		self.navigationItem.title = NSLocalizedString( @"DO_FORK", @"포크하기" );
	}
	
	DMBarButtonItem *cancelButton = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"CANCEL", @"" ) target:self action:@selector(cancelButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	DMBarButtonItem *uploadButton = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"UPLOAD", @"" ) target:self action:@selector(uploadButtonDidTouchUpInside)];
	self.navigationItem.rightBarButtonItem = uploadButton;
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)];
	[self.view addGestureRecognizer:tapRecognizer];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 64 )];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];
	
	_recipeView = [[RecipeView alloc] initWithTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) recipe:@"\n\n\n\n" closeButtonTarget:self closeButtonAction:@selector(closeButtonDidTouchUpInside)];
	_recipeView.recipeView.text = @"";
	_recipeView.recipeView.editable = YES;
	
	_recipeViewOriginalFrame = _recipeView.frame;
	_recipeViewOriginalFrame.origin.y = ( 200 - _recipeViewOriginalFrame.size.height ) / 2;
	_recipeView.frame = CGRectMake( 7, -_recipeViewOriginalFrame.size.height, _recipeViewOriginalFrame.size.width, _recipeViewOriginalFrame.size.height );
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditting:) name:UITextViewTextDidBeginEditingNotification object:nil];
	
	_photoHeight = PhotoButtonMaxWidth;
	
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
			
			_photoButton = [[UIButton alloc] init];
			[_photoButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
			[_photoButton addTarget:self action:@selector(photoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:_photoButton];
			
			_borderView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dish_writing_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 12, 45, 12 )]];
			[cell.contentView addSubview:_borderView];
			
			_nameInput = [[UITextField alloc] init];
			_nameInput.placeholder = NSLocalizedString( @"INPUT_DISH_NAME", @"" );
			_nameInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
			_nameInput.font = [UIFont boldSystemFontOfSize:15];
			_nameInput.layer.shadowOffset = CGSizeMake( 0, 1 );
			_nameInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
			[_nameInput addTarget:self action:@selector(textDidBeginEditting:) forControlEvents:UIControlEventEditingDidBegin];
			[cell.contentView addSubview:_nameInput];
		}
		
		_photoButton.frame = CGRectMake( 11, 11, PhotoButtonMaxWidth, _photoHeight );
		_borderView.frame = _borderView.frame = CGRectMake( 5, 5, 310, _photoButton.frame.size.height + 42 );
		_nameInput.frame = CGRectMake( 20, _photoHeight + 12, 280, 20 );
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
			
			_messageInput = [[UITextView alloc] initWithFrame:CGRectMake( 15, 10, 290, 70 )];
			_messageInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
			_messageInput.backgroundColor = [UIColor clearColor];
			_messageInput.font = [UIFont boldSystemFontOfSize:15];
			_messageInput.layer.shadowOffset = CGSizeMake( 0, 1 );
			_messageInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
			[cell.contentView addSubview:_messageInput];
		}
	}
	
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:recipeCellId];
		if( !cell )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recipeCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIButton *recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, 320, 50 )];
			[recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
			[recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
			[recipeButton setTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) forState:UIControlStateNormal];
			[recipeButton setTitleColor:[Utils colorWithHex:0x5B5046 alpha:1] forState:UIControlStateNormal];
			[recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
			recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
			recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
			recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
			[cell.contentView addSubview:recipeButton];
			
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
	UIImage *image = [_photoButton imageForState:UIControlStateNormal];
	if( !image )
	{
		NSLog( @"No Image!" );
		return;
	}
	
	[self backgroundDidTap];
	[self dim];
	
	NSDictionary *params = @{ @"name": _nameInput.text,
						   @"description": _messageInput.text,
						   @"recipe": _recipeView.recipeView.text };
	
	[[DishByMeAPILoader sharedLoader] api:@"/dish" method:@"POST" image:image parameters:params success:^(id response) {
		JLLog( @"Success" );
		[self undim];
		[self dismissViewControllerAnimated:YES completion:nil];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		[self undim];
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)textDidBeginEditting:(id)sender
{
	if( [sender respondsToSelector:@selector(object)] && [[sender object] isEqual:_recipeView.recipeView] )
		return;
	
	[_tableView setContentOffset:CGPointMake( 0, 300 ) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 - 216 );
	}];
}

- (void)backgroundDidTap
{
	[_nameInput resignFirstResponder];
	[_messageInput resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 );
	}];
}

- (void)photoButtonDidTouchUpInside
{
	[self presentActionSheet];
}

- (void)recipeButtonDidTouchUpInside
{
	[self dim];
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:_recipeView];
	
	[UIView animateWithDuration:0.25 animations:^{
		_recipeView.frame = _recipeViewOriginalFrame;
	} completion:^(BOOL finished) {
		[_recipeView.recipeView becomeFirstResponder];
	}];
}

- (void)closeButtonDidTouchUpInside
{
	[self undim];
	
	[_recipeView.recipeView resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		_recipeView.frame = CGRectMake( 7, -_recipeView.frame.size.height, _recipeView.frame.size.width, _recipeView.frame.size.height );
		_tableView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 );
		
	} completion:^(BOOL finished) {
		[[[UIApplication sharedApplication] keyWindow] addSubview:_recipeView];
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
	
	NSLog( @"Album : %@", info );
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
	// 카메라로 찍은 경우 앨범에 저장
	if( picker.sourceType == UIImagePickerControllerSourceTypeCamera )
		UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
	
	_photoHeight = PhotoButtonMaxWidth * image.size.height / image.size.width;
	[_photoButton setImage:image forState:UIControlStateNormal];
	[_tableView reloadData];
}

@end
