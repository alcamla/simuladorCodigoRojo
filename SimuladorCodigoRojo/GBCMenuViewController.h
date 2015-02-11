//
//  GBCMenuViewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/19/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GBCBluetoothManager.h"

@interface GBCMenuViewController : NSViewController<GBCRedCodeBluetoothPresenterDelegate>

@property (strong) IBOutlet GBCBluetoothManager *bluetoothManager;
- (IBAction)goToSync:(id)sender;
- (IBAction)goToConfirm:(id)sender;

- (void) initializeMenuTimer;
- (void) updateMenuView;
- (void) getAndSendSelectedState;
- (void) sendStartedMessage;
- (void) stopTimer;

@end
