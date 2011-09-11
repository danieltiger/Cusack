//
//  App.h
//  Cusack
//
//  Created by Arik Devens on 9/11/11.
//  Copyright 2011 Posterous, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPServer;

@interface App : NSObject {
	HTTPServer *server;
}

@property (nonatomic, retain) HTTPServer *server;

@end
