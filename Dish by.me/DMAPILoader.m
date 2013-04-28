//
//  DishByMeAPILoader.m
//  Dish by.me
//
//  Created by 전수열 on 13. 2. 23..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DMAPILoader.h"
#import "Utils.h"
#import "CurrentUser.h"
#import "AFImageCache.h"

@implementation DMAPILoader

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
//		if( error )
//		{
//			JLLog( @"%@", error );
//			return;
//		}
		
		if( error )
		{
			if( error.code == -1001 )
			{
				JLLog( @"요청시간 초과 : %@", error );
				return;
			}
			else if( error.code == -1009 )
			{
				JLLog( @"오프라인 : %@", error );
				return;
			}
			else
			{
				JLLog( @"Error : %@", error );
			}
		}
		
		NSDictionary *errorInfo = [[NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil] objectForKey:@"error"];
		NSInteger errorCode = [[errorInfo objectForKey:@"code"] integerValue];
		
		// AccessToken is expired
		if( errorCode == 2000 )
		{
			JLLog( @"AccessToken is expired: %@", [CurrentUser user].accessToken );
			
			[self extendAccessToken:^(id response) {
				JLLog( @"AccessToken is extended: %@", [response objectForKey:@"access_token"] );
				
				[[CurrentUser user] setAccessToken:[response objectForKey:@"access_token"]];
				[self api:api method:method parameters:parameters success:success failure:failure];
				
			} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
				JLLog( @"statusCode : %d", statusCode );
				JLLog( @"errorCode : %d", errorCode );
				JLLog( @"message : %@", message );
			}];
			return;
		}
		
		JLLog( @"URL(%@) : %@", method, operation.request.URL );
		JLLog( @"statusCode : %d", operation.response.statusCode );
		JLLog( @"errorCode : %d", errorCode );
		JLLog( @"message : %@", [errorInfo objectForKey:@"message"] );
		if( failure )
			failure( operation.response.statusCode, errorCode, [errorInfo objectForKey:@"message"] );
	}];
}

- (void)api:(NSString *)api
	 method:(NSString *)method
	  image:(UIImage *)image
	forName:(NSString *)name
   fileName:(NSString *)fileName
 parameters:(NSDictionary *)parameters
	success:(void (^)(id response))success
	failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	if( !image )
	{
		[self api:api method:method parameters:parameters success:success failure:failure];
		return;
	}
	
	NSURLRequest *request = [_client multipartFormRequestWithMethod:method path:[NSString stringWithFormat:@"/api/%@", api] parameters:[self parametersWithAccessToken:parameters] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		[formData appendPartWithFileData:UIImageJPEGRepresentation( image, 1 ) name:name fileName:fileName mimeType:@"image/jpeg"];
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
				
				[[CurrentUser user] setAccessToken:[response objectForKey:@"access_token"]];
				[self api:api method:method image:image forName:name fileName:fileName parameters:parameters success:success failure:failure];
				
			} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
				JLLog( @"statusCode : %d", statusCode );
				JLLog( @"errorCode : %d", errorCode );
				JLLog( @"message : %@", message );
			}];
			return;
		}
		
		JLLog( @"URL(%@) : %@", method, operation.request.URL );
		failure( operation.response.statusCode, errorCode, [errorInfo objectForKey:@"message"] );
	}];
}

- (void)api:(NSString *)api
	 method:(NSString *)method
	 images:(NSArray *)images
   forNames:(NSArray *)names
  fileNames:(NSArray *)fileNames
 parameters:(NSDictionary *)parameters
	success:(void (^)(id response))success
	failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	if( !images || images.count == 0 )
	{
		[self api:api method:method parameters:parameters success:success failure:failure];
		return;
	}
	
	if( images.count != names.count || names.count != fileNames.count )
	{
		JLLog( @"Must be image.count == names.count == fileNames.count" );
		return;
	}
	
	NSURLRequest *request = [_client multipartFormRequestWithMethod:method path:[NSString stringWithFormat:@"/api/%@", api] parameters:[self parametersWithAccessToken:parameters] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		
		for( NSInteger i = 0; i < images.count; i++ )
		{
			UIImage *image = [images objectAtIndex:i];
			NSString *name = [names objectAtIndex:i];
			NSString *fileName = [fileNames objectAtIndex:i];
			[formData appendPartWithFileData:UIImageJPEGRepresentation( image, 1 ) name:name fileName:fileName mimeType:@"image/jpeg"];
		}
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
				
				[[CurrentUser user] setAccessToken:[response objectForKey:@"access_token"]];
				[self api:api method:method images:images forNames:names fileNames:fileNames parameters:parameters success:success failure:failure];
				
			} failure:^(NSInteger statusCode, NSInteger errorCode, NSString *message) {
				JLLog( @"statusCode : %d", statusCode );
				JLLog( @"errorCode : %d", errorCode );
				JLLog( @"message : %@", message );
			}];
			return;
		}
		
		JLLog( @"URL(%@) : %@", method, operation.request.URL );
		failure( operation.response.statusCode, errorCode, [errorInfo objectForKey:@"message"] );
	}];
}


#pragma mark -

- (void)sendRequest:(NSURLRequest *)request
			success:(void (^)(id response))success
			failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	AFHTTPRequestOperation *operation = [_client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if( success )
			success( responseObject );
		
	} failure:failure];
	[_client enqueueHTTPRequestOperation:operation];
}


#pragma mark -

- (NSDictionary *)parametersWithAccessToken:(NSDictionary *)parameters
{
	if( [[CurrentUser user] loggedIn] )
	{
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
		[params setObject:[[CurrentUser user] accessToken] forKey:@"access_token"];
		return params;
	}
	
	return parameters;
}

- (void)extendAccessToken:(void (^)(id response))success
				  failure:(void (^)(NSInteger statusCode, NSInteger errorCode, NSString *message))failure
{
	NSDictionary *params = @{ @"access_token": [[CurrentUser user] accessToken] };
	[self api:@"/auth/renew" method:@"POST" parameters:params success:success failure:failure];
}


#pragma mark -

+ (void)loadImageFromURLString:(NSString *)urlString
					   context:(id)context
					   success:(void (^)(UIImage *image, __strong id context))success
{
	[DMAPILoader loadImageFromURL:[NSURL URLWithString:urlString] context:context success:success];
}

+ (void)loadImageFromURL:(NSURL *)url
				 context:(id)context
				 success:(void (^)(UIImage *image, __strong id context))success
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	UIImage *cachedImage = [[AFImageCache sharedImageCache] cachedImageForRequest:request];
	if( cachedImage )
	{
		if( success )
			success( cachedImage, context );
		return;
	}
	
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
		[[AFImageCache sharedImageCache] cacheImage:image forRequest:request];
		if( success )
			success( image, context );
	}];
	[operation start];
}

@end
