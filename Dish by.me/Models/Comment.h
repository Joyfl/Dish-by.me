//
//  Comment.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 21..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, weak) NSString *userName;
@property (nonatomic, weak) NSString *userPhotoURL;
@property (nonatomic, weak) UIImage *userPhoto;
@property (nonatomic, weak) NSString *message;
@property (nonatomic, weak) NSDate *createdTime;
@property (nonatomic, weak) NSString *relativeCreatedTime;
@property (nonatomic, weak) NSDate *updatedTime;
@property (nonatomic, weak) NSString *relativeUpdatedTime;
@property (nonatomic, assign) CGFloat messageHeight;

+ (Comment *)commentFromDictionary:(NSDictionary *)dictionary;
- (void)updateRelativeTime;
- (void)calculateMessageHeight;

@end
