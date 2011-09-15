//
//  SampleCusackApp.m
//  Cusack
//
//  Created by Arik Devens on 9/14/11.
//

#import "SampleCusackApp.h"
#import "ResponseManager.h"


@implementation SampleCusackApp

- (void)setupRoutes {
	[self get:@"/post/:id" withBlock:^(Request *request) {
		[[ResponseManager sharedManager] respondOkWithBody:@"You just hit the post controller!"];
	}];	
}

@end
