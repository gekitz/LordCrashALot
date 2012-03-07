//
//  WatchDog.m
//  LordCrashALot
//
//  Created by Georg Kitz on 3/3/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "WatchDog.h"
#import <fcntl.h>
#import <unistd.h>
#import <sys/event.h>

@interface WatchDog()
@property (nonatomic, strong) WatchDogCallback callback;
- (void)performCallback;
- (void)cleanup;
@end

static void kernelCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info){
    
    int kq = CFFileDescriptorGetNativeDescriptor(kqRef);
	if (kq < 0) {
        return;   
    }

	struct kevent event;
	struct timespec timeout = {0, 0};
	if (kevent(kq, NULL, 0, &event, 1, &timeout) == 1){
    
        WatchDog *watchDog = (__bridge WatchDog *)info;
        [watchDog performCallback];
        
    }
	CFFileDescriptorEnableCallBacks(kqRef, kCFFileDescriptorReadCallBack);
}

@implementation WatchDog

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getter/Setter Methods 

@synthesize callback = _callback;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods 

- (void)performCallback{
    if (_callback) {
        _callback(NO);
    }
}

- (void)cleanup{
    
    self.callback = nil;
    
    if (_directoryFileDescriptor) {
        close(_directoryFileDescriptor);
    }
    
    if (_kernelQueue) {
        close(_kernelQueue);
    }
    
    if (_fileDescriptor) {
        CFRelease(_fileDescriptor), _fileDescriptor = NULL;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods 

- (void)startWatchDogForDirectory:(NSString *)directory callback:(WatchDogCallback)callback{

    [self cleanup];
    self.callback = callback;
    
    _directoryFileDescriptor = open([directory fileSystemRepresentation], O_EVTONLY);
	if (_directoryFileDescriptor < 0) {
        goto error_handling;
    }
    
	_kernelQueue = kqueue();
	if (_kernelQueue < 0){
        goto error_handling;
	}
    
	struct kevent eventToAdd;
	eventToAdd.ident  = _directoryFileDescriptor;
	eventToAdd.filter = EVFILT_VNODE;		
	eventToAdd.flags  = EV_ADD | EV_CLEAR;	
	eventToAdd.fflags = NOTE_WRITE;		
	eventToAdd.data   = 0;				
	eventToAdd.udata  = NULL;			
    
	if (kevent(_kernelQueue, &eventToAdd, 1, NULL, 0, NULL)){
        goto error_handling;
	}
    
	CFFileDescriptorContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
	_fileDescriptor = CFFileDescriptorCreate(NULL, _kernelQueue, true, kernelCallback, &context);	
	if (_fileDescriptor == NULL){
        goto error_handling;
	}
    
	CFRunLoopSourceRef runLoopSource = CFFileDescriptorCreateRunLoopSource(NULL, _fileDescriptor, 0);
	if (!runLoopSource){
        goto error_handling;
	}
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
	CFRelease(runLoopSource);
    
	CFFileDescriptorEnableCallBacks(_fileDescriptor, kCFFileDescriptorReadCallBack);
    return;
    
//ERROR HANDLING:
error_handling:
    if (_callback) {
        _callback(YES);
    }
    
    [self cleanup];
}

- (void)dealloc{
    [self cleanup];
}

@end
