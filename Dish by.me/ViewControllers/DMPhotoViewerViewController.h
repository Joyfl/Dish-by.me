//
//  DMPhotoViewerViewController.h
//  Dish by.me
//
//  Created by 전수열 on 13. 5. 14..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface DMPhotoViewerViewController : GAITrackedViewController <UIScrollViewDelegate>
{
	UIScrollView *_scrollView;
}

@property (nonatomic, assign) CGRect originRect;
@property (nonatomic, readonly) UIImageView *imageView;

@end
