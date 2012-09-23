//
//  User.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 23..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
	NSInteger userId;
	NSString *name;
	NSString *bio;
	NSInteger dishCount;
	NSInteger yumCount;
	UIImage *photo;
}

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, assign) NSInteger dishCount;
@property (nonatomic, assign) NSInteger yumCount;
@property (nonatomic, retain) UIImage *photo;

@end
