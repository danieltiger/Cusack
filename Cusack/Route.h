//
//  Route.h
//  Cusack
//
//  Created by Arik Devens on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Request;

typedef void (^methodToCall)(Request *request);

@interface Route : NSObject {
	NSString *httpMethod;
	NSString *path;
	Request *request;
	methodToCall block;
}

@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) Request *request;
@property (nonatomic, copy) methodToCall block;

@end
