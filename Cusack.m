#import <Foundation/Foundation.h>
#import "SampleCusackApp.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	SampleCusackApp *app = [[SampleCusackApp alloc] init];
	
    [[NSRunLoop currentRunLoop] run];
	
    [pool drain];
    return 0;
}
