//
//  Comment.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject
{
	NSInteger userId;
	NSString *name;
	NSString *message;
	UIImage *userPhoto;
}

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) UIImage *userPhoto;

@end
