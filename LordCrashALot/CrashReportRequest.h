//
//  CrashReportRequest.h
//  LordCrashALot
//
//  Created by Georg Kitz on 3/3/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CrashReportCompletion)(BOOL success);

@interface CrashReportRequest : NSObject<NSURLConnectionDelegate>

- (void)postCrashesToServerWithDetailInformation:(NSDictionary *)dictionary completion:(CrashReportCompletion)completion;

@end
