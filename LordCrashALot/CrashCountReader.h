//
//  CrashCountReader.h
//  LordCrashALot
//
//  Created by Georg Kitz on 3/2/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CrashCompletionBlock)(NSInteger totalCrashCount, NSDictionary *detailInformation);

@interface CrashCountReader : NSObject

- (void)readCrashCountFromLastSyncDate:(NSDate *)date completion:(CrashCompletionBlock)completionBlock;
+ (NSString *)pathForOSVersion;
@end
