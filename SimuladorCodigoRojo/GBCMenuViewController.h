//
//  GBCMenuViewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/19/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBCMenuViewController : NSViewController

- (IBAction)goToSync:(id)sender;
- (IBAction)goToConfirm:(id)sender;
- (void) initializeMenuTimer;
- (void) updateMenuView;
- (void) getAndSendSelectedState;
- (void) sendStartedMessage;
- (void) stopTimer;

@end
