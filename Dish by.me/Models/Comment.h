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
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPhotoURL;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *createdTime;
@property (nonatomic, strong) NSString *relativeCreatedTime;
@property (nonatomic, strong) NSDate *updatedTime;
@property (nonatomic, strong) NSString *relativeUpdatedTime;
@property (nonatomic, assign) CGFloat messageHeight;
@property (nonatomic, assign) BOOL sending;

+ (Comment *)commentFromDictionary:(NSDictionary *)dictionary;
- (void)updateRelativeTime;
- (void)calculateMessageHeight;

@end
