//
//  HTTPConnection.h
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//  Copyright 2011 Posterous, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>


@interface HTTPConnection : NSObject {
	NSFileHandle *fileHandle;
	id delegate;
	NSString *address;
	
	CFHTTPMessageRef message;
	BOOL isMessageComplete;
}

@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, retain) NSString *address;

- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl;

@end
