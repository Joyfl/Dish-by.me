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
	NSInteger dishCount;
	NSInteger yumCount;
}

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger dishCount;
@property (nonatomic, assign) NSInteger yumCount;

@end
