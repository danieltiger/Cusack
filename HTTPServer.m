//
//  HTTPServer.m
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//

#import "HTTPServer.h"
#import "HTTPConnection.h"
#import <sys/socket.h>
#import <netinet/in.h>


@interface HTTPServer (PrivateMethods)
- (void)processNextRequestIfNecessary;
@end

@implementation HTTPServer

@synthesize connections, requests, currentRequest;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[fileHandle release];
	[socketPort release];
	[delegate release];	
	
	[requests release];
	[connections release];
	[currentRequest release];
	
	[super dealloc];
}

- (id)initWithPortNumber:(int)pn delegate:(id)dl {
	if (self == [super init]) {
		portNumber = pn;
		delegate = [dl retain];
		
		connections = [[NSMutableArray alloc] init];
		requests = [[NSMutableArray alloc] init];
		
		self.currentRequest = nil;
		
		NSAssert(delegate != nil, @"Please specify a delegate");
		NSAssert([delegate respondsToSelector:@selector(processURL:connection:)],
				 @"Delegate needs to implement 'processURL:connection:'");
		NSAssert([delegate respondsToSelector:@selector(stopProcessing)],
				 @"Delegate needs to implement 'stopProcessing'");
		
//		socketPort = [[NSSocketPort alloc] initWithTCPPort:portNumber];
//		int fd = [socketPort socket];
		
		int fd = -1;
		CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
		if (socket) {
			fd = CFSocketGetNative(socket);
			int yes = 1;
			setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
			
			struct sockaddr_in addr4;
			memset(&addr4, 0, sizeof(addr4));
			addr4.sin_len = sizeof(addr4);
			addr4.sin_family = AF_INET;
			addr4.sin_port = htons(portNumber);
			addr4.sin_addr.s_addr = htonl(INADDR_ANY);
			NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
			
			if (kCFSocketSuccess != CFSocketSetAddress(socket, (CFDataRef)address4)) {
				NSLog(@"Could not bind to address");
			}
		} else {
			NSLog(@"Failed to create a server socket");
		}
		
		fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newConnection:) 
													 name:NSFileHandleConnectionAcceptedNotification 
												   object:nil];
		
		[fileHandle acceptConnectionInBackgroundAndNotify];
	}
	
	return self;
}

- (void)newConnection:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSFileHandle *remoteFileHandle = [userInfo	objectForKey:NSFileHandleNotificationFileHandleItem];
	
	NSNumber *errorNumber = [userInfo objectForKey:@"NSFileHandleError"];
	if (errorNumber) {
		NSLog(@"NSFileHandle Error: %@", errorNumber);
		
		return;
	}
	
	[fileHandle acceptConnectionInBackgroundAndNotify];
	
	if (remoteFileHandle) {
		HTTPConnection *connection = [[HTTPConnection alloc] initWithFileHandle:remoteFileHandle delegate:self];
		
		if (connection) {
			[connections addObject:connection];
			[connection release];
		}
	}
}

- (void)closeConnection:(HTTPConnection *)connection {
	NSUInteger connectionIndex = [connections indexOfObjectIdenticalTo:connection];
	if (connectionIndex == NSNotFound) {
		return;
	}
	
	NSMutableIndexSet *obsoleteRequests = [NSMutableIndexSet indexSet];
	BOOL stopProcessing = NO;

	for (int i = 0; i < [requests count]; i++) {
        NSDictionary *request = [requests objectAtIndex:i];
		
        if ([request objectForKey:@"connection"] == connection) {
            if (request == self.currentRequest) {
				stopProcessing = YES;
			}
			
            [obsoleteRequests addIndex:i];
        }
    }	
	
	NSIndexSet *connectionIndexSet = [NSIndexSet indexSetWithIndex:connectionIndex];
	[requests removeObjectsAtIndexes:obsoleteRequests];
	[connections removeObjectsAtIndexes:connectionIndexSet];
	
	if (stopProcessing) {
		[delegate stopProcessing];
		self.currentRequest = nil;
	}
	
	[self processNextRequestIfNecessary];
}

- (void)newRequestWithURL:(NSURL *)url connection:(HTTPConnection *)connection {
	if (!url) {
		return;
	}
	
	NSDictionary *request = [NSDictionary dictionaryWithObjectsAndKeys:
							 url, @"url", 
							 connection, @"connection", 
							 [NSCalendarDate date], @"date", nil];
	
	[requests addObject:request];
	
	[self processNextRequestIfNecessary];
}

- (void)processNextRequestIfNecessary {
	if (self.currentRequest == nil && [requests count] > 0) {
		self.currentRequest = [requests objectAtIndex:0];
		
		[delegate processURL:[currentRequest objectForKey:@"url"] connection:[currentRequest objectForKey:@"connection"]];
	}
}

- (void)replyWithStatusCode:(int)code headers:(NSDictionary *)headers body:(NSData *)body {
	CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, code, NULL, kCFHTTPVersion1_1);
	
	for (NSString *key in headers) {
		id value = [headers objectForKey:key];
		
		if (![value isKindOfClass:[NSString class]]) {
			value = [value description];
		}
		
		if (![key isKindOfClass:[NSString class]]) {
			key = [key description];
		}
		
		CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)key, (CFStringRef)value);
	}
	
	if (body) {
		NSString *length = [NSString stringWithFormat:@"%d", [body length]];
		CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)@"Content-Length", (CFStringRef)length);
		CFHTTPMessageSetBody(message, (CFDataRef)body);
	}
	
	CFDataRef messageData = CFHTTPMessageCopySerializedMessage(message);
	
	@try {
		NSFileHandle *remoteFileHandle = [[self.currentRequest objectForKey:@"connection"] fileHandle];
		[remoteFileHandle writeData:(NSData *)messageData];
	}
	@catch (NSException *exception) {
		NSLog(@"Error while sending response (%@): %@", [self.currentRequest objectForKey:@"url"], [exception reason]);
	}
	
	CFRelease(messageData);
	CFRelease(message);
	
	NSUInteger index = [requests indexOfObjectIdenticalTo:self.currentRequest];
	if (index != NSNotFound) {
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
		[requests removeObjectsAtIndexes:indexSet];
	}
	
	self.currentRequest = nil;
	[self processNextRequestIfNecessary];
}

- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type {
	NSDictionary *headers = [NSDictionary dictionaryWithObject:type forKey:@"Content-Type"];
	[self replyWithStatusCode:200 headers:headers body:data];
}

- (void)replyWithStatusCode:(int)code message:(NSString *)message {
	NSData *body = [message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	[self replyWithStatusCode:code headers:nil body:body];
}


@end
