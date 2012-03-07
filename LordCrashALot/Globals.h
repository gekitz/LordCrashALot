//
//  Globals.h
//  LordCrashALot
//
//  Created by Georg Kitz on 3/6/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#ifndef LordCrashALot_Globals_h
#define LordCrashALot_Globals_h

#define DEBUG_ENABLED 0

#ifdef DEBUG_ENABLED
#define LOG NSLog
#else
#define LOG
#endif

#define kLastSyncDate @"lord.crash.a.lot.last.sync.date"
#define kUniqueIdentifier @"lord.crash.a.lot.last.unique.identifier"

#endif
