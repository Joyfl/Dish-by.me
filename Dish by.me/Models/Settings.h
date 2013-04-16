//
//  Setting.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 17..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookSettings : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) BOOL og;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end


@interface Settings : NSObject

@property (nonatomic, strong) FacebookSettings *facebook;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
