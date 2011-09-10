//
//  HTTPServer.h
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//

#import <Foundation/Foundation.h>


@interface HTTPServer : NSObject {
	int portNumber;
	id delegate;
	
	NSSocketPort *socketPort;
	NSFileHandle *fileHandle;
	
	NSMutableArray *connections;
	NSMutableArray *requests;
}

@end
