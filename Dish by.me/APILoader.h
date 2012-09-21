//
//  APILoader.h
//  Dish by.me
//
//  Created by 전 수열 on 12. 9. 16..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	APILoaderMethodGET = 0,
	APILoaderMethodPOST = 1,
	APILoaderMethodPUT = 2,
	APILoaderMethodDELETE = 3
};

@interface APILoaderToken : NSObject
{	
	NSInteger _tokenId;
	NSString *_url;
	NSInteger _method;
	NSMutableDictionary *_params;
	NSString *_data;
}

- (id)initWithTokenId:(NSInteger)tokenId url:(NSString *)url method:(NSInteger)method params:(NSMutableDictionary *)params;

@property (nonatomic, assign) NSInteger tokenId;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) NSInteger method;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSString *data;

@end



@protocol APILoaderDelegate;

@interface APILoader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLAuthenticationChallengeSender>
{
	NSMutableData *_responseData;
	NSMutableArray *_queue;
	
	id<APILoaderDelegate> delegate;
	BOOL loading;
}

- (void)addTokenWithTokenId:(NSInteger)tokenId url:(NSString *)url method:(NSInteger)method params:(NSMutableDictionary *)params;
- (void)addToken:(APILoaderToken *)token;
- (void)startLoading;
- (APILoaderToken *)tokenAtIndex:(NSInteger)index;

@property (retain, nonatomic) id<APILoaderDelegate> delegate;
@property (nonatomic, readonly) NSInteger queueLength;
@property (nonatomic, readonly) BOOL loading;

@end


@protocol APILoaderDelegate

- (BOOL)shouldLoadWithToken:(APILoaderToken *)token;

@required
- (void)loadingDidFinish:(APILoaderToken *)token;

@end