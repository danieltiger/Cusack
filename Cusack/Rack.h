//
//  Rack.h
//  Cusack
//
//  Created by Arik Devens on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ruby/Ruby.h>


@interface Rack : NSObject {
    VALUE rackc;
}

VALUE method_rackc_init(VALUE self,VALUE env);

@end
