//
//  WatchDog.h
//  LordCrashALot
//
//  Created by Georg Kitz on 3/3/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WatchDogCallback)(BOOL failed);

@interface WatchDog : NSObject{
    int _directoryFileDescriptor;
    int _kernelQueue;
    CFFileDescriptorRef _fileDescriptor;
}

- (void)startWatchDogForDirectory:(NSString *)directory callback:(WatchDogCallback) callback;

@end
