//
//  CameraOverlayViewController.m
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import "CameraOverlayViewController.h"

@implementation CameraOverlayViewController

- (id)initWithPicker:(UIImagePickerController *)picker
{
	self = [super init];
	self.trackedViewName = [[self class] description];
	
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake( 0, -20, 320, 54 )];
	topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
	[self.view addSubview:topView];
	
	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake( 0, 354, 320, 54 )];
	bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
	[self.view addSubview:bottomView];
	
	return self;
}

@end
