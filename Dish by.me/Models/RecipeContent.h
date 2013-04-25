//
//  RecipeContent.h
//  Dish by.me
//
//  Created by 전수열 on 13. 4. 2..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipeContent : NSObject

@property (nonatomic, assign) NSInteger photoWidth;
@property (nonatomic, assign) NSInteger photoHeight;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *description;

+ (id)recipeContentFromDictionary:(NSDictionary *)dictionary;

@end
