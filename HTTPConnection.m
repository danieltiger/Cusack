//
//  HTTPConnection.m
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//  Copyright 2011 Posterous, Inc. All rights reserved.
//

#import "HTTPConnection.h"
#import "HTTPServer.h"
#import <netinet/in.h>      // for sockaddr_in
#import <arpa/inet.h>       // for inet_ntoa


@implementation HTTPConnection

@synthesize fileHandle, address;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (message) {
		CFRelease(message);
	}
	
	[delegate release];
	[fileHandle release];
	
	[super dealloc];
}

- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl {
	if (self = [super init]) {
		fileHandle = [fh retain];
		delegate = [dl retain];
		message = NULL;
		isMessageComplete = YES;
		
		CFSocketRef socket = CFSocketCreateWithNative(kCFAllocatorDefault, [fileHandle fileDescriptor], kCFSocketNoCallBack, NULL, NULL);
		CFDataRef addrData = CFSocketCopyPeerAddress(socket);
		CFRelease(socket);
		
		if (addrData) {
			struct sockaddr_in *sock = (struct sockaddr_in *)CFDataGetBytePtr(addrData);
			char *naddr = inet_ntoa(sock->sin_addr);
			self.address = [NSString stringWithCString:naddr];
			CFRelease(addrData);
		} else {
			self.address = @"NULL";
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(dataReceivedNotification:) 
													 name:NSFileHandleReadCompletionNotification 
												   object:fileHandle];
		
		[fileHandle readInBackgroundAndNotify];
	}
	
	return self;
}

- (void)dataReceivedNotification:(NSNotification *)notification {
	NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	if ([data length] == 0) {
		[delegate closeConnection:self];
		
		return;
	}
	
	[fileHandle readInBackgroundAndNotify];
	
	if (isMessageComplete) {
		message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
	}
	
	Boolean success = CFHTTPMessageAppendBytes(message, [data bytes], [data length]);
	
	if (success) {
		if (CFHTTPMessageIsHeaderComplete(message)) {
			isMessageComplete = YES;
			
			CFURLRef url = CFHTTPMessageCopyRequestURL(message);
			[delegate newRequestWithURL:(NSURL *)url connection:self];
			CFRelease(url);
			CFRelease(message);
			message = NULL;
		} else {
			isMessageComplete = NO;
		}
	} else {
		NSLog(@"Incomming message not an HTTP header, ignoring.");
		
		[delegate closeConnection:self];
	}
}

@end
