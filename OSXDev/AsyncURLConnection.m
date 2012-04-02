//
//  AsyncURLConnection.m
//  OSXDev
//
//  Created by J.C. Yang on 12. 3. 27..
//  Copyright (c) 2012년 Cocoaine team. All rights reserved.
//

#import "AsyncURLConnection.h"

@interface AsyncURLConnection (PrivateMethods)
- (NSString *)stringWithNewUUID;
@end

@implementation AsyncURLConnection

@synthesize identifier = _identifier;
@synthesize data = _data;
@synthesize requestType = _requestType;
@synthesize URL = _URL;
@synthesize response = _response;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(NetworkRequestType)requestType {
	self = [super initWithRequest:request delegate:delegate];
	if (self) {
		// custom async connection
		_identifier = [[self stringWithNewUUID] retain];
		_data = [[NSMutableData alloc] initWithCapacity:0];
        _requestType = requestType;
		_URL = [[request URL] retain];
	}
	
	return self;
}

- (void)dealloc
{
    [_identifier release];
	[_response release];
    [_data release];
	[_URL release];
	
    [super dealloc];
}

// MARK: -
// MARK: << Public methods >>
- (void)resetDataLength {
	[_data setLength:0];
}

- (void)appendData:(NSData *)data {
    [_data appendData:data];
}

- (NSString *)identifier {
    return [[_identifier retain] autorelease];
}

- (NSData *)data {
    return [[_data retain] autorelease];
}

- (NSURL *)URL {
    return [[_URL retain] autorelease];
}

- (NetworkRequestType)requestType {
    return _requestType;
}

- (NSString *)description {
    NSString *description = [super description];
    return [description stringByAppendingFormat:@" (requestType = %d, identifier = %@)", self.requestType, self.identifier];
}

@end

@implementation AsyncURLConnection (PrivateMethods)

- (NSString *)stringWithNewUUID {
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
    NSString *newUUID = (NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}

@end
