//
//  Rack.m
//  Cusack
//
//  Created by Arik Devens on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Rack.h"

@implementation Rack

- (void)Init_rackc {
    rackc = rb_define_module("RackC");
    rb_define_singleton_method(rackc, "call", method_rackc_init, 1);
}

VALUE method_rackc_init(VALUE self,VALUE env) {
    VALUE rack_arr;
    VALUE headers;
    VALUE* request_path;
    
    request_path = rb_hash_aref(env, (VALUE *)rb_str_new2("REQUEST_PATH"));
    
    rack_arr = rb_ary_new();
    headers = rb_hash_new();
    
    rb_hash_aset(headers, (VALUE *)rb_str_new2("Content-Type"), (VALUE *)rb_str_new2("plain"));
    
    rb_ary_push(rack_arr, INT2NUM(200)); //response code here
    rb_ary_push(rack_arr, headers); //header hash here
    rb_ary_push(rack_arr, request_path); //body here
    
    return rack_arr;
}


@end
