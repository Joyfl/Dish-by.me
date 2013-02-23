//
//  LogManager.h
//  SleepIfUCan
//
//  Created by 전수열 on 13. 1. 28..
//  Copyright (c) 2013년 전수열. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JLLog( format, ... ) [JLLogger log:@"%s [Line %d] " format, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
//#define JLLog( format, ... ) [JLLogger log:format, ##__VA_ARGS__]

@interface JLLogger : NSObject

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *log;

+ (void)log:(NSString *)format, ...;
+ (void)clearLog;
+ (void)sendLog;

@end
