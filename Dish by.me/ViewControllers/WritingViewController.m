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

@implementation WritingViewController

- (id)initWithPhoto:(UIImage *)photo
{
	self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	DMBarButtonItem *cancelButton = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"CANCEL", @"" ) target:self action:@selector(cancelButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	DMBarButtonItem *uploadButton = [[DMBarButtonItem alloc] initWithType:DMBarButtonItemTypeNormal title:NSLocalizedString( @"UPLOAD", @"" ) target:self action:@selector(uploadButtonDidTouchUpInside)];
	self.navigationItem.rightBarButtonItem = uploadButton;
	
	_photo = photo;
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundDidTap)];
	[self.view addGestureRecognizer:tapRecognizer];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, 320, UIScreenHeight - 64 )];
	_scrollView.delegate = self;
	_scrollView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	_scrollView.contentSize = CGSizeMake( 320, 520 );
	[self.view addSubview:_scrollView];
	
	UIImageView *photoView = [[UIImageView alloc] initWithImage:_photo];
	photoView.frame = CGRectMake( 11, 11, 298, 298 );
	[_scrollView addSubview:photoView];
	
	UIImageView *borderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_writing_border.png"]];
	borderView.frame = CGRectMake( 5, 5, 310, 340 );
	[_scrollView addSubview:borderView];
	
	_nameInput = [[UITextField alloc] initWithFrame:CGRectMake( 20, 310, 280, 20 )];
	_nameInput.placeholder = NSLocalizedString( @"INPUT_DISH_NAME", @"" );
	_nameInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
	_nameInput.font = [UIFont boldSystemFontOfSize:15];
	_nameInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_nameInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	[_nameInput addTarget:self action:@selector(textDidBeginEditting) forControlEvents:UIControlEventEditingDidBegin];
	[_scrollView addSubview:_nameInput];
	
	UIImageView *messageBoxView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"message_box.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 12, 24, 12, 10 )]];
	messageBoxView.frame = CGRectMake( 9, 350, 304, 100 );
	[_scrollView addSubview:messageBoxView];
	
	_messageInput = [[UITextView alloc] initWithFrame:CGRectMake( 15, 360, 290, 70 )];
	_messageInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
	_messageInput.backgroundColor = [UIColor clearColor];
	_messageInput.font = [UIFont boldSystemFontOfSize:15];
	_messageInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_messageInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	[_scrollView addSubview:_messageInput];
	
	UIButton *recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 455, 320, 50 )];
	[recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
	[recipeButton setTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) forState:UIControlStateNormal];
	[recipeButton setTitleColor:[Utils colorWithHex:0x5B5046 alpha:1] forState:UIControlStateNormal];
	[recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
	recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
	recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
	[_scrollView addSubview:recipeButton];
	
	UIImageView *recipeBottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"]];
	recipeBottomLine.frame = CGRectMake( 0, 493, 320, 15 );
	[_scrollView addSubview:recipeBottomLine];
	
	_recipeView = [[RecipeView alloc] initWithTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) recipe:@"\n\n\n\n" closeButtonTarget:self closeButtonAction:@selector(closeButtonDidTouchUpInside)];
	_recipeView.recipeView.text = @"";
	_recipeView.recipeView.editable = YES;
	
	_recipeViewOriginalFrame = _recipeView.frame;
	_recipeViewOriginalFrame.origin.y = ( 200 - _recipeViewOriginalFrame.size.height ) / 2;
	_recipeView.frame = CGRectMake( 7, -_recipeViewOriginalFrame.size.height, _recipeViewOriginalFrame.size.width, _recipeViewOriginalFrame.size.height );
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditting) name:UITextViewTextDidBeginEditingNotification object:nil];
	
	return self;
}


#pragma mark -
#pragma mark Selectors

- (void)cancelButtonDidTouchUpInside
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadButtonDidTouchUpInside
{
	[self dim];
	
	return;
	
	
	NSDictionary *params = @{
						  @"name": _nameInput.text,
		@"description": _messageInput.text
		};
	
	[[DishByMeAPILoader sharedLoader] api:@"/dish" method:@"POST" image:_photo parameters:params success:^(id response) {
		JLLog( @"Success" );
		[self dismissViewControllerAnimated:YES completion:nil];
		
	} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
		JLLog( @"statusCode : %d", statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", message );
	}];
}

- (void)textDidBeginEditting
{
	[_scrollView setContentOffset:CGPointMake( 0, 300 ) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^{
		_scrollView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 - 216 );
	}];
}

- (void)backgroundDidTap
{
	[_nameInput resignFirstResponder];
	[_messageInput resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		_scrollView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 );
	}];
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
		_scrollView.frame = CGRectMake( 0, 0, 320, UIScreenHeight - 64 );
		
	} completion:^(BOOL finished) {
		[[[UIApplication sharedApplication] keyWindow] addSubview:_recipeView];
	}];
}

@end
