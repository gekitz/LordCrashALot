//
//  CrashReportRequest.m
//  LordCrashALot
//
//  Created by Georg Kitz on 3/3/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "CrashReportRequest.h"

@interface CrashReportRequest()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) CrashReportCompletion completion;
- (void)cleanup;
@end

@implementation CrashReportRequest

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getter/Setter Methods 

@synthesize connection = _connection;
@synthesize data = _data;
@synthesize completion = _completion;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods 

- (void)cleanup{
    if (_connection) {
        [_connection cancel];
        self.connection = nil;
    }
    
    if (_data) {
        self.data = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods 

- (void)postCrashesToServerWithDetailInformation:(NSDictionary *)dictionary completion:(CrashReportCompletion)completion{

    self.completion = completion; 

    NSURL *postCrashesURL = [[NSURL alloc] initWithString:@"http://lord-crash-a-lot.jantschnig.com/report.php"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:postCrashesURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.];
 
    NSError *error = nil;
    
    NSMutableDictionary *mutabledict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [mutabledict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kUniqueIdentifier] forKey:@"uid"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutabledict options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    [self cleanup];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (_connection) {
        self.data = [NSMutableData data];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark URLConnectionDelegate Methods 

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (_completion) {
        _completion(NO);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (_completion) {
        _completion(YES);
    }
}

@end
