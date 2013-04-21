//
//  NSString+ArgumentArray.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 21..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ArgumentArray)

+ (NSString *)stringWithFormat:(NSString *)format arguments:(NSArray *)arguments;

@end
