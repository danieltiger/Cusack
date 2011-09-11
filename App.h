//
//  App.h
//  Cusack
//
//  Created by Arik Devens on 9/11/11.
//  Copyright 2011 Posterous, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"


@class HTTPConnection;

@interface App : NSObject <HTTPServerDelegate> {
	HTTPServer *server;
}

@property (nonatomic, retain) HTTPServer *server;

- (void)processURL:(NSURL *)path connection:(HTTPConnection *)connection;
- (void)stopProcessing;

@end
