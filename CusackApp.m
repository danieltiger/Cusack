//
//  CusackApp.m
//  Cusack
//
//  Created by Arik Devens on 9/11/11.
//

#import "CusackApp.h"
#import "Route.h"
#import "Request.h"
#import "ResponseManager.h"


@implementation CusackApp

@synthesize server, routes;

- (void)dealloc {
	server.delegate = nil;
	[server release];
	
	[routes release];
	
	[super dealloc];
}

- (id)init {
	if (self = [super init]) {
		self.server = [[[HTTPServer alloc] initWithPortNumber:1723] autorelease];
		self.server.delegate = self;
		
		[[ResponseManager sharedManager] setServer:server];
		
		self.routes = [[NSMutableDictionary alloc] init];
		
		[self setupRoutes];
	}
	
	return self;
}

- (void)setupRoutes {
}

- (void)processURL:(NSURL *)path connection:(HTTPConnection *)connection {
	Route *route = [self.routes objectForKey:[path relativePath]];
	
	if (route) {
		void (^methodToCall)() = route.block;
		methodToCall(route.request);	
	} else {
		[[ResponseManager sharedManager] respondWith404];
	}
}

- (void)stopProcessing {
	NSLog(@"Stop Processing!");
}


- (void)get:(NSString *)path withBlock:(void (^)(Request *request))block {
	Route *route = [[Route alloc] init];
	route.httpMethod = @"get";
	route.path = path;
	route.block = block;
	route.request = [[[Request alloc] init] autorelease];
	
	[self.routes setObject:route forKey:path];
	
//	path = [path stringByReplacingOccurrencesOfRegex:@"(:(\\w+)|\\*)" usingBlock:
//			^NSString *(NSInteger captureCount, NSString *const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL *const stop) {
//				if ([capturedStrings[1] isEqualToString:@"*"]) {
//					[keys addObject:@"wildcards"];
//					return @"(.*?)";
//				}
//				
//				[keys addObject:capturedStrings[2]];
//				return @"([^/]+)";
//			}];
//	
//	path = [NSString stringWithFormat:@"^%@$", path];	
	
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*\/:(.*)"
																		   options:NSRegularExpressionCaseInsensitive
																			 error:&error];
	
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		
		return;
	}
	
	NSString *regexpPath = [regex stringByReplacingMatchesInString:path
														   options:0
															 range:NSMakeRange(0, [path length])
													  withTemplate:@".*"];
	
	NSLog(@"reg'd: %@", regexpPath);
}

@end


