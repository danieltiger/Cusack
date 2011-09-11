#import <Foundation/Foundation.h>
#import "App.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	App *app = [[App alloc] init];
	
    [[NSRunLoop currentRunLoop] run];
	
    [pool drain];
    return 0;
}
