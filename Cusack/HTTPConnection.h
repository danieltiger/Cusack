//
//  HTTPConnection.h
//  Cusack
//
//  Created by Arik Devens on 9/10/11.
//

#import <Foundation/Foundation.h>


@protocol HTTPConnectionDelegate <NSObject>
@required
- (void)closeConnection:(id)connection;
- (void)newRequestWithURL:(NSURL *)url connection:(id)connection;
@end

@interface HTTPConnection : NSObject {
	NSFileHandle *fileHandle;
	id<HTTPConnectionDelegate> delegate;
	NSString *address;
	
	CFHTTPMessageRef message;
	BOOL isMessageComplete;
}

@property (assign) id<HTTPConnectionDelegate> delegate;

@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, retain) NSString *address;

- (id)initWithFileHandle:(NSFileHandle *)fh;

@end
