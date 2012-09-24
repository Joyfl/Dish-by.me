//
//  PhotoEditingViewController.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "WritingViewController.h"
#import "DishByMeBarButtonItem.h"
#import "RecipeView.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation WritingViewController

- (id)initWithPhoto:(UIImage *)_photo
{
	self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	DishByMeBarButtonItem *cancelButton = [[DishByMeBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeNormal title:NSLocalizedString( @"CANCEL", @"" ) target:self action:@selector(cancelButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	DishByMeBarButtonItem *uploadButton = [[DishByMeBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeNormal title:NSLocalizedString( @"UPLOAD", @"" ) target:self action:@selector(uploadButtonDidTouchUpInside)];
	self.navigationItem.rightBarButtonItem = uploadButton;
	[uploadButton release];
	
	photo = [_photo retain];
	
	UIGestureRecognizer *recognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(gestureDidRecognize)];
	self.view.gestureRecognizers = [NSArray arrayWithObject:recognizer];
	[recognizer release];
	
	scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, 320, 416 )];
	scrollView.delegate = self;
	scrollView.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	scrollView.contentSize = CGSizeMake( 320, 520 );
	[self.view addSubview:scrollView];
	
	UIImageView *photoView = [[UIImageView alloc] initWithImage:photo];
	photoView.frame = CGRectMake( 11, 11, 298, 298 );
	[scrollView addSubview:photoView];
	
	UIImageView *borderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_writing_border.png"]];
	borderView.frame = CGRectMake( 5, 5, 310, 340 );
	[scrollView addSubview:borderView];
	
	nameInput = [[UITextField alloc] initWithFrame:CGRectMake( 20, 314, 280, 20 )];
#warning Need LocalizedString
	nameInput.placeholder = @"Dish name";
	nameInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
	nameInput.font = [UIFont boldSystemFontOfSize:15];
	nameInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	nameInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	[nameInput addTarget:self action:@selector(textDidBeginEditting:) forControlEvents:UIControlEventEditingDidBegin];
	[scrollView addSubview:nameInput];
	
	UIImageView *messageBoxTopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_top.png"]];
	messageBoxTopView.frame = CGRectMake( 8, 350, 304, 15 );
	[scrollView addSubview:messageBoxTopView];
	[messageBoxTopView release];
	
	UIImageView *messageBoxCenterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_center.png"]];
	messageBoxCenterView.frame = CGRectMake( 8, 365, 304, 70 );
	[scrollView addSubview:messageBoxCenterView];
	
	UIImageView *messageBoxBottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_bottom.png"]];
	messageBoxBottomView.frame = CGRectMake( 8, 355 + messageBoxCenterView.frame.size.height, 304, 15 );
	[scrollView addSubview:messageBoxBottomView];
	
	messageInput = [[UITextView alloc] initWithFrame:CGRectMake( 15, 360, 290, 70 )];
	messageInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
	messageInput.backgroundColor = [UIColor clearColor];
	messageInput.font = [UIFont boldSystemFontOfSize:15];
	messageInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	messageInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	[scrollView addSubview:messageInput];
	
	UIButton *recipeButton = [[UIButton alloc] initWithFrame:CGRectMake( 0, 455, 320, 50 )];
	[recipeButton addTarget:self action:@selector(recipeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[recipeButton setBackgroundImage:[UIImage imageNamed:@"dish_detail_recipe_button.png"] forState:UIControlStateNormal];
	[recipeButton setTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) forState:UIControlStateNormal];
	[recipeButton setTitleColor:[Utils colorWithHex:0x5B5046 alpha:1] forState:UIControlStateNormal];
	[recipeButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateNormal];
	recipeButton.titleLabel.shadowOffset = CGSizeMake( 0, 1 );
	recipeButton.titleEdgeInsets = UIEdgeInsetsMake( 20, 0, 0, 0 );
	recipeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
	[scrollView addSubview:recipeButton];
	
	UIImageView *bottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"]];
	bottomLine.frame = CGRectMake( 0, 500, 320, 10 );
	[scrollView addSubview:bottomLine];
	
	dim = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dim.png"]];
	dim.alpha = 0;
	[self.view addSubview:dim];
	
#warning closeButton이 제대로 눌리지 않음 - closeButton 터치 후 텍스트필드 터치하면 이벤트 트리거됨.
	recipeView = [[RecipeView alloc] initWithTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) recipe:@"\n\n\n\n" closeButtonTarget:self closeButtonAction:@selector(closeButtonDidTouchUpInside)];
	recipeView.recipeView.text = @"";
	recipeView.recipeView.editable = YES;
	[self.view addSubview:recipeView];
	
	recipeViewOriginalFrame = recipeView.frame;
	recipeViewOriginalFrame.origin.y = ( 200 - recipeViewOriginalFrame.size.height ) / 2;
	recipeView.frame = CGRectMake( 7, -recipeViewOriginalFrame.size.height, recipeViewOriginalFrame.size.width, recipeViewOriginalFrame.size.height );
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditting:) name:UITextViewTextDidBeginEditingNotification object:nil];
	
	loader = [[APILoader alloc] init];
	loader.delegate = self;
	
	return self;
}


#pragma mark -
#pragma mark Selectors

- (void)cancelButtonDidTouchUpInside
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textDidBeginEditting:(id)sender
{
	[UIView animateWithDuration:0.25 animations:^{
		scrollView.frame = CGRectMake( 0, 0, 320, 200 );
	}];
}

- (void)recipeButtonDidTouchUpInside
{
	scrollView.userInteractionEnabled = NO;
	
	[UIView animateWithDuration:0.25 animations:^{
		dim.alpha = 1;
		recipeView.frame = recipeViewOriginalFrame;
	} completion:^(BOOL finished) {
		[recipeView.recipeView becomeFirstResponder];
	}];
}

- (void)closeButtonDidTouchUpInside
{
	[recipeView.recipeView resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		dim.alpha = 0;
		recipeView.frame = CGRectMake( 7, -recipeView.frame.size.height, recipeView.frame.size.width, recipeView.frame.size.height );
		scrollView.frame = CGRectMake( 0, 0, 320, 416 );
	} completion:^(BOOL finished) {
		scrollView.userInteractionEnabled = YES;
	}];
}

- (void)uploadButtonDidTouchUpInside
{
	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								   photo, @"photo",
								   nameInput.text, @"dish_name",
								   messageInput.text, @"message",
								   recipeView.recipeView.text, @"recipe", nil];
#warning Const에 있는걸로 가져다쓰기
	[loader addTokenWithTokenId:0 url:@"http://api.dishby.me/dish" method:APILoaderMethodPOST params:params];
	[loader startLoading];
}


#pragma mark -
#pragma mark APILoaderDelegate

- (BOOL)shouldLoadWithToken:(APILoaderToken *)token
{
	return YES;
}

- (void)loadingDidFinish:(APILoaderToken *)token
{
	NSLog( @"result : %@", token.data );
}

@end
