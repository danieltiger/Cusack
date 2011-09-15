//
//  ResponseManager.h
//  Cusack
//
//  Created by Arik Devens on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ResponseManager;
@class HTTPServer;

extern ResponseManager *sharedManager;

@interface ResponseManager : NSObject {
	HTTPServer *server;
}

@property (nonatomic, retain) HTTPServer *server;

+ (ResponseManager *)sharedManager;

- (void)responseWithStatusCode:(int)statusCode andBody:(NSString  *)body;
- (void)respondOkWithBody:(NSString *)responseBody;
- (void)respondWith404;

@end
