//
//  HTTPServer.h
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//

#import <Foundation/Foundation.h>

@class HTTPConnection;

@interface HTTPServer : NSObject {
	int portNumber;
	id delegate;
	
	NSSocketPort *socketPort;
	NSFileHandle *fileHandle;
	
	NSMutableArray *connections;
	NSMutableArray *requests;
	
	NSDictionary *currentRequest;
}

@property (nonatomic, retain) NSMutableArray *connections;
@property (nonatomic, retain) NSMutableArray *requests;
@property (nonatomic, retain) NSDictionary *currentRequest;

- (id)initWithPortNumber:(int)pn delegate:(id)dl;

- (void)closeConnection:(HTTPConnection *)connection;
- (void)newRequestWithURL:(NSURL *)url connection:(HTTPConnection *)connection;

- (void)replyWithStatusCode:(int)code headers:(NSDictionary *)headers body:(NSData *)body;
- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type;
- (void)replyWithStatusCode:(int)code message:(NSString *)message;

@end
