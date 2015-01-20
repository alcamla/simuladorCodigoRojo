//
//  GBCMonitorVIewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/19/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBCMonitorVIewController : NSViewController

- (void) updateMonitorViewController;
- (void) updateVitalSignsInMonitor;
- (void) updateChronometer;
- (void) sendChronometerValue;
- (void) initializeMonitorTimer;
- (void) finishChoronometer;
- (void) askIfChronometerIsPaused;
- (void) interruptEventHandling;
- (void) askIfSimulationHasFinished;
- (void) simulationHasFinishedMonitor;
- (void) askIfChronometerIsReanuded;
- (void) initializeChronometer;
- (void) finishTimerToUpdate;
- (void) sendMessageOfStartedChronometer;

@end
