//
//  GBCSimulator.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/29/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBCState.h"
#import "GBCBluetoothManager.h"

@interface GBCSimulator : NSObject <GBCRedCodeBluetoothDelegate>

+ (instancetype)sharedSimulator;
- (NSDictionary *) getCurrentVitalSigns;
- (void) stateSelectedIs:(NSString *)stateReceived;
- (BOOL) askIfBluetoothIsConnected;
- (void)createBluetoothObject;
- (BOOL)isCalibrationReady;
- (BOOL)areSensorsReady;
- (void) readBluetoothVariables;
- (NSDictionary *) getBluetoothVariables;
- (void) getChronometerValue:(NSArray *)chronometer;
- (void) receiveFinalizationMessage;
- (BOOL) sentFinalizationMessageFromSimulator;
- (void) getEditedVariablesValues:(NSMutableDictionary *) editedVariablesDictionaryFromPanel;
- (void) getPausedMessage;
- (BOOL) sendPausedMessage;
- (void) getReanudedMessage;
- (BOOL) sendReanudedMessage;
- (void) simulationReanudedConfirmation;
- (NSMutableDictionary *) sendEditableVariables;
- (void) receiveStartedChronometerMessage;
- (NSMutableArray *) sendChronometerValue;
- (void) receiveCurrentState: (NSString *)currentStateFromMachine;
- (NSString *) sendInitialStateSelected;
- (void) receiveStartedInitializationMessage;
- (void) simulationHasFinished;
- (void) modifyReadWriteVariables;
- (NSString *) sendCurrentState;



@end