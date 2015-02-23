//
//  GBCMonitorVIewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/19/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlotItem.h"


@interface GBCMonitorVIewController : NSViewController

@property (nonatomic, strong) PlotItem *plotItem;

- (void) updateMonitorViewController;
- (void) updateVitalSignsInMonitor;
- (void) updateChronometer;
- (void) sendChronometerValue;
- (void) initializeMonitorTimer;
- (void) finishChoronometer;
- (void) askIfSimulationIsPaused;
- (void) interruptEventHandling;
- (void) askIfSimulationHasFinished;
- (void) simulationHasFinishedMonitor;
- (void) initializeChronometer;
- (void) finishTimerToUpdate;
- (void) sendMessageOfStartedChronometer;
- (void) askForStateToSetBeepFrecuency;
- (void) askForInitialStateAndSetInitialFrecuency;
- (void) playBeep;

@end
