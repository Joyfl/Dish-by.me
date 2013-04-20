//
//  Notification.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 20..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic, assign) NSInteger notificationId;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *url;

+ (id)notificationFromDictionary:(NSDictionary *)dictionary;

@end
