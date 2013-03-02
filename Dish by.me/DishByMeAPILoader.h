//
//  DishByMeAPILoader.h
//  Dish by.me
//
//  Created by 전수열 on 13. 2. 23..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "AFNetworking.h"

@interface DishByMeAPILoader : NSObject
{
	AFHTTPClient *_client;
}

+ (id)sharedLoader;

- (void)api:(NSString *)api
	 method:(NSString *)method
 parameters:(NSDictionary *)parameters
	success:(void (^)(id response))success
	failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure;

- (void)api:(NSString *)api
	 method:(NSString *)method
	  image:(UIImage *)image
 parameters:(NSDictionary *)parameters
	success:(void (^)(id response))success
	failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure;

- (void)loadImageFromURL:(NSURL *)url
				 context:(id)context
				 success:(void (^)(UIImage *image, __strong id context))success;

@end
