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

#pragma mark -

- (void)api:(NSString *)api
	 method:(NSString *)method
 parameters:(NSDictionary *)parameters
	success:(void (^)(id response))success
	failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	NSURLRequest *request = [_client requestWithMethod:method path:[NSString stringWithFormat:@"/api/%@", api] parameters:[self parametersWithAccessToken:parameters]];
	
	[self sendRequest:request success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSDictionary *errorInfo = [[NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil] objectForKey:@"error"];
		NSInteger errorCode = [[errorInfo objectForKey:@"code"] integerValue];
		
		// AccessToken is expired
		if( errorCode == 2000 )
		{
			JLLog( @"AccessToken is expired" );
			
			[self extendAccessToken:^(id response) {
				JLLog( @"AccessToken is extended" );
				
				[[UserManager manager] setAccessToken:[response objectForKey:@"access_token"]];
				[self api:api method:method parameters:parameters success:success failure:failure];
				
			} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
				JLLog( @"statusCode : %d", statusCode );
				JLLog( @"errorCode : %d", errorCode );
				JLLog( @"message : %@", message );
			}];
			return;
		}
		
		NSLog( @"URL : %@", operation.request.URL );
		failure( operation.response.statusCode, errorCode, [errorInfo objectForKey:@"message"] );
	}];
}

- (void)api:(NSString *)api
	 method:(NSString *)method
	  image:(UIImage *)image
 parameters:(NSDictionary *)parameters
	success:(void (^)(id response))success
	failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	NSURLRequest *request = [_client multipartFormRequestWithMethod:@"POST" path:@"/api/dish" parameters:[self parametersWithAccessToken:parameters] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		[formData appendPartWithFileData:UIImageJPEGRepresentation( image, 1 ) name:@"photo" fileName:@"photo" mimeType:@"image/jpeg"];
	}];
	
	[self sendRequest:request success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSDictionary *errorInfo = [[NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil] objectForKey:@"error"];
		NSInteger errorCode = [[errorInfo objectForKey:@"code"] integerValue];
		
		// AccessToken is expired
		if( errorCode == 2000 )
		{
			JLLog( @"AccessToken is expired" );
			
			[self extendAccessToken:^(id response) {
				JLLog( @"AccessToken is extended" );
				
				[[UserManager manager] setAccessToken:[response objectForKey:@"access_token"]];
				[self api:api method:method image:image parameters:parameters success:success failure:failure];
				
			} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
				JLLog( @"statusCode : %d", statusCode );
				JLLog( @"errorCode : %d", errorCode );
				JLLog( @"message : %@", message );
			}];
			return;
		}
		
		JLLog( @"URL : %@", operation.request.URL );
		failure( operation.response.statusCode, errorCode, [errorInfo objectForKey:@"message"] );
	}];
}


#pragma mark -

- (void)sendRequest:(NSURLRequest *)request
			success:(void (^)(id response))success
			failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	AFHTTPRequestOperation *operation = [_client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success( responseObject );
		
	} failure:failure];
	[_client enqueueHTTPRequestOperation:operation];
}


#pragma mark -

- (NSDictionary *)parametersWithAccessToken:(NSDictionary *)parameters
{
	if( [[UserManager manager] loggedIn] )
	{
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
		NSLog( @"parmas : %@", params );
		[params setObject:[[UserManager manager] accessToken] forKey:@"access_token"];
		NSLog( @"parmas : %@", params );
		return params;
	}
	
	return parameters;
}

- (void)extendAccessToken:(void (^)(id response))success
				  failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	NSDictionary *params = @{ @"access_token": [[UserManager manager] accessToken] };
	[self api:@"/auth/renew" method:@"POST" parameters:params success:success failure:failure];
}


#pragma mark -

- (void)loadImageFromURL:(NSURL *)url
				 context:(id)context
				 success:(void (^)(UIImage *image, __strong id context))success
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
		success( image, context );
	}];
	[operation start];
}

@end
