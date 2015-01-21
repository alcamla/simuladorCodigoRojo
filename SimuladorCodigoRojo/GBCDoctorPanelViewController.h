//
//  GBCDoctorPanelViewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/5/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBCDoctorPanelViewController : NSViewController

- (IBAction)finishSimulation:(id)sender;
- (void) sentFinalizationMessage;
- (void) initializePanelTimer;
- (void) interruptEventHandlingPanel;
- (void) updatePanelView;
- (void) sendEditedVariables;
- (void) readEditedVariables;
- (void) UpdateAndGetBluetoothVariablesFromSimulator;
- (void) finishPanelTimer;
- (IBAction)changeVenous:(id)sender;

@end

