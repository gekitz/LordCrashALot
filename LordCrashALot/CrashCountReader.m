//
//  CrashCountReader.m
//  LordCrashALot
//
//  Created by Georg Kitz on 3/2/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "CrashCountReader.h"

@interface CrashCountReader()
+ (NSString *)osVersion;
- (BOOL)hasCorrectAttributesForXcodeFileAtPath:(NSString *)filePath syncDate:(NSDate *)date;
@end

@implementation CrashCountReader

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods 

+ (NSString *)osVersion{
    SInt32 versionMajor = 0;
    SInt32 versionMinor = 0;
    Gestalt( gestaltSystemVersionMajor, &versionMajor );
    Gestalt( gestaltSystemVersionMinor, &versionMinor );
    return [NSString stringWithFormat:@"%d.%d.", versionMajor, versionMinor];
}

+ (NSString *)pathForOSVersion{
    
    if ([[CrashCountReader osVersion] rangeOfString:@"10.7"].location != NSNotFound) {
        return [@"~/Library/Logs/DiagnosticReports" stringByExpandingTildeInPath];
    }
    return @"";
}

- (BOOL)hasCorrectAttributesForXcodeFileAtPath:(NSString *)filePath syncDate:(NSDate *)date{
    NSError *error = nil;
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSDictionary *attribute = [manager attributesOfItemAtPath:filePath error:&error];
    
    if (error) {
        LOG(@"[FILEMANAGER FAILED] Error %@", error);
        return NO;
    }
    
    NSDate *creationDate = [attribute objectForKey:NSFileCreationDate];
    if (!date || [date compare:creationDate] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

- (NSString *)retrieveXcodeVersionOfCrashFileAtPath:(NSString *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *fileAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange range = [fileAsString rangeOfString:@"Version:"];
    if (range.location == NSNotFound) {
        return @"undefined";
    }
    
    fileAsString = [fileAsString substringFromIndex:range.location + range.length];
    
    range = [fileAsString rangeOfString:@"\n"];
    if (range.location == NSNotFound) {
        return @"undefined";
    }
    
    NSString *version = [[fileAsString substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return version;
}

- (void)interalReadCrashCountFromLastSyncDate:(NSDate *)date completion:(CrashCompletionBlock)completionBlock{
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSString *path = [CrashCountReader pathForOSVersion];
    
    NSError *error = nil;
    NSArray *pathContentFiles = [manager contentsOfDirectoryAtPath:path error:&error];
    
    if (error) {
        LOG(@"[FILEMANAGER FAILED] Error %@", error);
        return;
    }
    
    NSMutableDictionary *countDictionary = [[NSMutableDictionary alloc] init];
    NSInteger totalCount = 0;
    for (NSString *file in pathContentFiles) {
        if (![file hasPrefix:@"Xcode"] || ![file hasSuffix:@".crash"]) {
            continue;
        }
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,file];
        
        if (![self hasCorrectAttributesForXcodeFileAtPath:filePath syncDate:date]) {
            continue;
        }
        
        NSString *version = [self retrieveXcodeVersionOfCrashFileAtPath:filePath];
        NSNumber *count = [countDictionary objectForKey:version];
        if(!count){
            count = [NSNumber numberWithInt:1];
        } else {
            NSInteger intCount = [count integerValue] + 1;
            count = [NSNumber numberWithInt:intCount];
        }
        
        [countDictionary setObject:count forKey:version];
        totalCount ++;
    }
    
    if(completionBlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(totalCount, countDictionary);        
        });
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods 

- (void)readCrashCountFromLastSyncDate:(NSDate *)date completion:(CrashCompletionBlock)completionBlock{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        [self interalReadCrashCountFromLastSyncDate:date completion:completionBlock]; 
    }); 
}

@end
