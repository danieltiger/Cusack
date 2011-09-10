//
//  HTTPServer.m
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//

#import "HTTPServer.h"


@implementation HTTPServer

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[requests release];
	[connections release];
	[fileHandle release];
	[socketPort release];
	[delegate release];
	
	[super dealloc];
}

- (id)initWithPortNumber:(int)pn delegate:(id)dl {
	if (self == [super init]) {
		portNumber = pn;
		delegate = [dl retain];
		
		connections = [[NSMutableArray alloc] init];
		requests = [[NSMutableArray alloc] init];
		
		socketPort = [[NSSocketPort alloc] initWithTCPPort:portNumber];
		int fd = [socketPort socket];
		fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newConnection:) name:NSFileHandleConnectionAcceptedNotification object:nil];
		
		[fileHandle acceptConnectionInBackgroundAndNotify];
	}
	
	return self;
}

- (void)newConnection:(NSNotification *)notification {
	
}

@end
