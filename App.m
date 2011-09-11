//
//  App.m
//  Cusack
//
//  Created by Arik Devens on 9/11/11.
//  Copyright 2011 Posterous, Inc. All rights reserved.
//

#import "App.h"
#import "HTTPServer.h"
#import "HTTPConnection.h"


@implementation App

@synthesize server;

- (id)init {
	if (self = [super init]) {
		self.server = [[[HTTPServer alloc] initWithPortNumber:1723 delegate:self] autorelease];
	}
	
	return self;
}

- (void)processURL:(NSURL *)path connection:(HTTPConnection *)connection {
	NSString *urlString = [@"http:/" stringByAppendingString:[path absoluteString]];	
    NSURL *url = [NSURL URLWithString:urlString];
	NSLog(@"URL: %@", urlString);

    if (url) {
		[server replyWithStatusCode:200 message:@"Hello!"];
    } else {
        NSString *errorMsg = [NSString stringWithFormat:@"Error in URL: %@", urlString];
        NSLog(@"%@", errorMsg);
        [server replyWithStatusCode:400 // Bad Request
                            message:errorMsg];
    }	
}

- (void)stopProcessing {
	NSLog(@"Stop!");
}

@end
