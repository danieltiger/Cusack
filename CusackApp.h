//
//  CusackApp.h
//  Cusack
//
//  Created by Arik Devens on 9/11/11.
//  Copyright 2011 Posterous, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"


@class HTTPConnection;
@class Request;

@interface CusackApp : NSObject <HTTPServerDelegate> {
	HTTPServer *server;	
	NSMutableDictionary *routes;
	
	int code;
	NSDictionary *headers;
	NSString *body;
}

@property (nonatomic, retain) HTTPServer *server;
@property (nonatomic, retain) NSMutableDictionary *routes;

- (void)processURL:(NSURL *)path connection:(HTTPConnection *)connection;
- (void)stopProcessing;

- (void)get:(NSString *)path withBlock:(void (^)(Request *request))block;

- (void)setupRoutes;

@end
