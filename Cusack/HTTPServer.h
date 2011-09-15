//
//  HTTPServer.h
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"


@protocol HTTPServerDelegate <NSObject>
@required
- (void)processURL:(NSURL *)path connection:(HTTPConnection *)connection;
- (void)stopProcessing;
@end

@interface HTTPServer : NSObject <HTTPConnectionDelegate> {
	int portNumber;
	id<HTTPServerDelegate> delegate;
	
	NSSocketPort *socketPort;
	NSFileHandle *fileHandle;
	
	NSMutableArray *connections;
	NSMutableArray *requests;
	
	NSDictionary *currentRequest;
}

@property (assign) id<HTTPServerDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *connections;
@property (nonatomic, retain) NSMutableArray *requests;
@property (nonatomic, retain) NSDictionary *currentRequest;

- (id)initWithPortNumber:(int)pn;

- (void)closeConnection:(HTTPConnection *)connection;
- (void)newRequestWithURL:(NSURL *)url connection:(HTTPConnection *)connection;

- (void)replyWithStatusCode:(int)code headers:(NSDictionary *)headers body:(NSData *)body;
- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type;
- (void)replyWithStatusCode:(int)code message:(NSString *)message;

@end
