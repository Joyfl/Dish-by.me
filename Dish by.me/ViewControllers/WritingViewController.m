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

@implementation WritingViewController

- (id)initWithPhoto:(UIImage *)photo
{
	self = [super init];
	self.view.backgroundColor = [Utils colorWithHex:0xF3EEEA alpha:1];
	
	DMBarButtonItem *cancelButton = [[DMBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeNormal title:NSLocalizedString( @"CANCEL", @"" ) target:self action:@selector(cancelButtonDidTouchUpInside)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	DMBarButtonItem *uploadButton = [[DMBarButtonItem alloc] initWithType:DishByMeBarButtonItemTypeNormal title:NSLocalizedString( @"UPLOAD", @"" ) target:self action:@selector(uploadButtonDidTouchUpInside)];
	self.navigationItem.rightBarButtonItem = uploadButton;
	[uploadButton release];
	
	_photo = [photo retain];
	
	UIGestureRecognizer *recognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(gestureDidRecognize)];
	self.view.gestureRecognizers = [NSArray arrayWithObject:recognizer];
	[recognizer release];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, 320, 416 )];
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
	
	_nameInput = [[UITextField alloc] initWithFrame:CGRectMake( 20, 314, 280, 20 )];
	_nameInput.placeholder = NSLocalizedString( @"INPUT_DISH_NAME", @"" );
	_nameInput.textColor = [Utils colorWithHex:0x808283 alpha:1];
	_nameInput.font = [UIFont boldSystemFontOfSize:15];
	_nameInput.layer.shadowOffset = CGSizeMake( 0, 1 );
	_nameInput.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
	[_nameInput addTarget:self action:@selector(textDidBeginEditting:) forControlEvents:UIControlEventEditingDidBegin];
	[_scrollView addSubview:_nameInput];
	
	UIImageView *messageBoxTopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_top.png"]];
	messageBoxTopView.frame = CGRectMake( 8, 350, 304, 15 );
	[_scrollView addSubview:messageBoxTopView];
	[messageBoxTopView release];
	
	UIImageView *messageBoxCenterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_center.png"]];
	messageBoxCenterView.frame = CGRectMake( 8, 365, 304, 70 );
	[_scrollView addSubview:messageBoxCenterView];
	
	UIImageView *messageBoxBottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_box_bottom.png"]];
	messageBoxBottomView.frame = CGRectMake( 8, 355 + messageBoxCenterView.frame.size.height, 304, 15 );
	[_scrollView addSubview:messageBoxBottomView];
	
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
	
	UIImageView *bottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dish_detail_recipe_bottom_line.png"]];
	bottomLine.frame = CGRectMake( 0, 500, 320, 10 );
	[_scrollView addSubview:bottomLine];
	
	_dim = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dim.png"]];
	_dim.alpha = 0;
	[self.view addSubview:_dim];
	
#warning closeButton이 제대로 눌리지 않음 - closeButton 터치 후 텍스트필드 터치하면 이벤트 트리거됨.
	_recipeView = [[RecipeView alloc] initWithTitle:NSLocalizedString( @"WRITE_RECIPE", @"" ) recipe:@"\n\n\n\n" closeButtonTarget:self closeButtonAction:@selector(closeButtonDidTouchUpInside)];
	_recipeView.recipeView.text = @"";
	_recipeView.recipeView.editable = YES;
	[self.view addSubview:_recipeView];
	
	_recipeViewOriginalFrame = _recipeView.frame;
	_recipeViewOriginalFrame.origin.y = ( 200 - _recipeViewOriginalFrame.size.height ) / 2;
	_recipeView.frame = CGRectMake( 7, -_recipeViewOriginalFrame.size.height, _recipeViewOriginalFrame.size.width, _recipeViewOriginalFrame.size.height );
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditting:) name:UITextViewTextDidBeginEditingNotification object:nil];
	
	_loader = [[JLHTTPLoader alloc] init];
	_loader.delegate = self;
	
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
		_scrollView.frame = CGRectMake( 0, 0, 320, 200 );
	}];
}

- (void)recipeButtonDidTouchUpInside
{
	_scrollView.userInteractionEnabled = NO;
	
	[UIView animateWithDuration:0.25 animations:^{
		_dim.alpha = 1;
		_recipeView.frame = _recipeViewOriginalFrame;
	} completion:^(BOOL finished) {
		[_recipeView.recipeView becomeFirstResponder];
	}];
}

- (void)closeButtonDidTouchUpInside
{
	[_recipeView.recipeView resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^{
		_dim.alpha = 0;
		_recipeView.frame = CGRectMake( 7, -_recipeView.frame.size.height, _recipeView.frame.size.width, _recipeView.frame.size.height );
		_scrollView.frame = CGRectMake( 0, 0, 320, 416 );
	} completion:^(BOOL finished) {
		_scrollView.userInteractionEnabled = YES;
	}];
}

- (void)uploadButtonDidTouchUpInside
{
	_scrollView.userInteractionEnabled = NO;
	
	[UIView animateWithDuration:0.25 animations:^{
		_dim.alpha = 1;
	}];
	 
//	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//								   _photo, @"photo",
//								   _nameInput.text, @"dish_name",
//								   _messageInput.text, @"message",
//								   [(AppDelegate *)[UIApplication sharedApplication].delegate currentWritingForkedFrom], @"forked_from",
//								   _recipeView.recipeView.text, @"recipe", nil];
#warning Const에 있는걸로 가져다쓰기
//	[_loader addTokenWithTokenId:0 url:@"http://api.dishby.me/dish" method:JLHTTPLoaderMethodPOST params:params];
	[_loader startLoading];
}


#pragma mark -
#pragma mark JLHTTPLoaderDelegate

- (void)loaderDidFinishLoading:(JLHTTPResponse *)response
{
	NSDictionary *data = [Utils parseJSON:response.body];
	if( [[data objectForKey:@"status"] isEqualToString:@"ok"] )
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
