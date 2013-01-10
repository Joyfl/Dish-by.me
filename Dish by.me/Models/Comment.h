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
	NSInteger commentId;
	NSInteger userId;
	NSString *userName;
	NSString *userPhotoURL;
	UIImage *userPhoto;
	NSString *message;
	NSDate *createdTime;
	NSString *relativeCreatedTime;
	NSDate *updatedTime;
	NSString *relativeUpdatedTime;
	
	CGFloat cellHeight;
}

@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userPhotoURL;
@property (nonatomic, retain) UIImage *userPhoto;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSDate *createdTime;
@property (nonatomic, retain) NSString *relativeCreatedTime;
@property (nonatomic, retain) NSDate *updatedTime;
@property (nonatomic, retain) NSString *relativeUpdatedTime;
@property (nonatomic, assign) CGFloat cellHeight;

+ (Comment *)commentFromDictionary:(NSDictionary *)dictionary;
- (void)updateRelativeTime;

@end
