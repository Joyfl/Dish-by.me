//
//  DishByMeAPILoader.m
//  Dish by.me
//
//  Created by 전수열 on 13. 2. 23..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DishByMeAPILoader.h"
#import "Utils.h"
#import "UserManager.h"

@implementation DishByMeAPILoader

+ (id)sharedLoader
{
	static dispatch_once_t pred = 0;
    __strong static id __loader = nil;
    dispatch_once( &pred, ^{
        __loader = [[self alloc] init];
    });
    return __loader;
}

- (id)init
{
	self = [super init];
	
	_client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_ROOT_URL]];
	[_client setDefaultHeader:@"Accept" value:@"application/json; version=1.0;"];
	[_client setDefaultHeader:@"Content-Type" value:@"application/json"];
	[_client registerHTTPOperationClass:[AFJSONRequestOperation class]];
	
	return self;
}

- (void)api:(NSString *)api
	 method:(NSString *)method
 parameters:(NSDictionary *)parameters
	success:(void (^)(id response))success
	failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	if( [[UserManager manager] loggedIn] )
	{
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
		[params setObject:[[UserManager manager] accessToken] forKey:@"access_token"];
		parameters = params;
	}
	
	NSURLRequest *request = [_client requestWithMethod:method path:[NSString stringWithFormat:@"/api/%@", api] parameters:parameters];
	AFHTTPRequestOperation *operation = [_client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success( responseObject );
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog( @"URL : %@", operation.request.URL );
		NSDictionary *errorInfo = [[NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil] objectForKey:@"error"];
		failure( operation.response.statusCode, [[errorInfo objectForKey:@"code"] integerValue], [errorInfo objectForKey:@"message"] );
	}];
	
	[_client enqueueHTTPRequestOperation:operation];
}

- (void)loadImageFromURL:(NSURL *)url
				 success:(void (^)(UIImage *image))success
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:success];
	[operation start];
}

@end
