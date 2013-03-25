//
//  LogManager.m
//  SleepIfUCan
//
//  Created by 전수열 on 13. 1. 28..
//  Copyright (c) 2013년 전수열. All rights reserved.
//

#import "JLLogger.h"

#define LOG_PATH [(NSString *)[NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0] stringByAppendingPathComponent:@"log.txt"]

@implementation JLLogger

+ (JLLogger *)sharedInstance
{
	static JLLogger *logger = nil;
	if( !logger )
	{
		logger = [[JLLogger alloc] init];
//		if( logger.log.length > 0 )
//			JLLog( @"There is a remaining log. Probably application was crashed or network was unavailable recently." );
	}
	return logger;
}

- (id)init
{
	self = [super init];
//	NSLog( @"LOG_PATH : %@", LOG_PATH );
	
	_deviceName = [[UIDevice currentDevice] name];
	_uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	_log = [NSString stringWithContentsOfFile:LOG_PATH encoding:NSUTF8StringEncoding error:nil];
	if( !_log ) _log = @"";
	
	return self;
}

+ (void)log:(NSString *)format, ...
{
	va_list ap;
	va_start( ap, format );
	NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
	va_end( ap );
	
	NSLog( @"%@", message );
	
	JLLogger *logger = [JLLogger sharedInstance];
	logger.log = [logger.log stringByAppendingFormat:@"%@ %@\n", [NSDate date], message];
	[logger.log writeToFile:LOG_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)clearLog
{
//	[@"" writeToFile:LOG_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)sendLog
{
	/*NSLog( @"Send log" );
	
	JLLogger *logger = [JLLogger sharedInstance];
	JLHTTPFormEncodedRequest *req = [[JLHTTPFormEncodedRequest alloc] init];
	req.url = @"http://dev.joyfl.net/sleepifucan/log.php";
	req.method = @"POST";
	[req setParam:logger.deviceName forKey:@"name"];
	[req setParam:logger.uuid forKey:@"uuid"];
	[req setParam:logger.log forKey:@"log"];
	NSString *result = [[NSString alloc] initWithData:[JLHTTPLoader loadSync:req] encoding:NSUTF8StringEncoding];
	NSLog( @"%@", result );
	if( [result isEqualToString:@"ok"] )
		[JLLogger clearLog];
	else
		JLLog( @"Failed sending log." );*/
}

@end
