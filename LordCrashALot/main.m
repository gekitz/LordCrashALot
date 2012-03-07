//
//  main.m
//  LordCrashALot
//
//  Created by Georg Kitz on 3/2/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSApplication * application = [NSApplication sharedApplication];
        
        AppDelegate * appDelegate = [[AppDelegate alloc] init];
        
        [application setDelegate:appDelegate];
        [application run];
    }
    
    
    return EXIT_SUCCESS;
}
