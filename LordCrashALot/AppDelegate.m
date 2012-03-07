//
//  AppDelegate.m
//  LordCrashALot
//
//  Created by Georg Kitz on 3/2/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "CrashCountReader.h"
#import "CrashReportRequest.h"
#import "WatchDog.h"

@interface AppDelegate()
@property (nonatomic, strong) WatchDog *watchDog;

- (void)updateStatusItems;
- (void)setupMenu;
- (void)updateCrashReportCount;
- (void)setupUniqueIdentifier;
- (void)setupWatchDog;

@end 

@implementation AppDelegate

@synthesize statusItem = _statusItem;
@synthesize watchDog = _watchDog;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods 

- (void)openLoardCrashALot{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.lord-crash-a-lot.com"]];
}

- (void)updateStatusItems{
    NSDate *syncDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kLastSyncDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateAsString = [formatter stringFromDate:syncDate];
    NSString *lastSyncDate = (dateAsString != nil ? 
                              [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"lastSync", @""), dateAsString] : 
                              NSLocalizedString(@"notSyncedYet", @""));
    
    for (NSMenuItem *item in _statusItem.menu.itemArray) {
        if (item.tag == 999) {
            item.title = lastSyncDate;
            break;
        }
    }
}

- (void)setupMenu{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    item.tag = 999;
    [menu addItem:item];
    
    NSString *identifier = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"id", @""), 
                            [[NSUserDefaults standardUserDefaults] objectForKey:kUniqueIdentifier]];
    item = [[NSMenuItem alloc] initWithTitle:identifier action:nil keyEquivalent:@""];
    [menu addItem:item]; 
    
    item = [NSMenuItem separatorItem];
    [menu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"openLord", @"") action:@selector(openLoardCrashALot) keyEquivalent:@""];
    [menu addItem:item];
    
    item = [NSMenuItem separatorItem];
    [menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"quit", @"") action:@selector(terminate:) keyEquivalent:@"Q"];
    [menu addItem:item];
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    _statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    
    [_statusItem setTitle: NSLocalizedString(@"",@"")];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:menu];
    
    [self updateStatusItems];
}

- (void)updateCrashReportCount{
    NSDate *lastSync = [[NSUserDefaults standardUserDefaults] objectForKey:kLastSyncDate];
    if (!lastSync || [lastSync compare:[NSDate date]] == NSOrderedAscending) {
        
        CrashCountReader *reader = [[CrashCountReader alloc] init];
        CrashCompletionBlock completionBlock = ^(NSInteger totalCrashCount, NSDictionary *detailInformations) {
            
            CrashReportRequest *request = [[CrashReportRequest alloc] init];
            CrashReportCompletion requestCompletion = ^(BOOL success){
                if (success) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastSyncDate];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self updateStatusItems];
                }
            };
            
            [request postCrashesToServerWithDetailInformation:detailInformations completion:requestCompletion];
        };
        
        [reader readCrashCountFromLastSyncDate:lastSync completion:completionBlock];
    }
}

- (void)setupUniqueIdentifier{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kUniqueIdentifier]) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef string = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        
        NSString *stringUUID = (__bridge NSString *)string; 
        LOG(@"UUIID %@", stringUUID);
        [[NSUserDefaults standardUserDefaults] setObject:stringUUID forKey:kUniqueIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        CFRelease(uuid);
        CFRelease(string);
    }
    
}

- (void)setupWatchDog{
    _watchDog = [[WatchDog alloc] init];
    WatchDogCallback callback = ^(BOOL failed){
        if (!failed) {
            [self updateCrashReportCount];
        }
    };
    
    [_watchDog startWatchDogForDirectory:[CrashCountReader pathForOSVersion] callback:callback];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action Methods 

- (void)performSync{
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
   
    [self setupUniqueIdentifier];
    [self setupMenu];
    [self updateCrashReportCount];
    [self setupWatchDog];
}

@end
