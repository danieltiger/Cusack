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

- (Route *)routeForPath:(NSURL *)path {
    NSString *relativePath = [path relativePath];
    
    for (NSString *key in self.routes) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            
            return nil;
        }
        
        if ([regex numberOfMatchesInString:relativePath
                                   options:0
                                     range:NSMakeRange(0, [relativePath length])]) {
            return [self.routes objectForKey:key];
        }
    }
    
    return nil;
}

- (void)processURL:(NSURL *)path connection:(HTTPConnection *)connection {
	Route *route = [self routeForPath:path];
    
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

- (NSString *)regexpForPath:(NSString *)path {
    NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(.*/):.*"
																		   options:NSRegularExpressionCaseInsensitive
																			 error:&error];
	
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		
		return nil;
	}
	
	NSString *regexpPath = [regex stringByReplacingMatchesInString:path
														   options:0
															 range:NSMakeRange(0, [path length])
													  withTemplate:@"$1.*"];
	
	NSLog(@"reg'd: %@", regexpPath);

    return regexpPath;
}

- (void)get:(NSString *)path withBlock:(void (^)(Request *request))block {
	Route *route = [[Route alloc] init];
	route.httpMethod = @"get";
	route.path = path;
	route.block = block;
	route.request = [[[Request alloc] init] autorelease];

	[self.routes setObject:route forKey:[self regexpForPath:path]];	
}

@end


