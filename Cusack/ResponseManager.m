//
//  ResponseManager.m
//  Cusack
//
//  Created by Arik Devens on 9/14/11.
//

#import "ResponseManager.h"
#import "HTTPServer.h"


ResponseManager *sharedManager;

@implementation ResponseManager

@synthesize server;

+ (void)initialize {
    static BOOL initialized = NO;
	
    if (!initialized) {
        initialized = YES;
		
        sharedManager = [[ResponseManager alloc] init];
    }
}

+ (ResponseManager *)sharedManager {
	return (sharedManager);
}

- (id)init {
	if (self = [super init]) {
	}
	
	return self;
}

- (void)responseWithStatusCode:(int)statusCode andBody:(NSString  *)body {
	[self.server replyWithStatusCode:statusCode message:body];
}

- (void)respondOkWithBody:(NSString *)responseBody {
	[self.server replyWithStatusCode:200 message:responseBody];
}

- (void)respondWith404 {
	[self.server replyWithStatusCode:404 message:@"Route not found."];
}

@end
