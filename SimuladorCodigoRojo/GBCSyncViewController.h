//
//  GBCSyncViewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBCSyncViewController : NSViewController

- (IBAction)endSync:(id)sender;
- (void) askForBluetoothConnection;
- (void) updateSyncView;
- (void) initializeSyncTimer;
- (void) interruptWithTimerToUpdateView;
- (void) stopTimer;
- (void) askIfShouldStopTimer;
- (void)viewLoadedMessage;

@end
