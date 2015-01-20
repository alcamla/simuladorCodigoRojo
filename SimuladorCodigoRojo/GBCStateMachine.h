//
//  GBCStateMachine.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/13/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBCStateMachine : NSObject

- (void) interruptWithMachineTimer;
- (void) initializeMachineTimer;
- (void) calculateState;
- (void) updateLocalVariables;
- (void) sendNewState;
- (void) getInitialStateSelected;
- (void) setInitialTimerValues;
- (void) askForFinalizationMessageFromSimulator;
- (void) simulationHasFinished;
- (void) finishMachineTimer;

@end
