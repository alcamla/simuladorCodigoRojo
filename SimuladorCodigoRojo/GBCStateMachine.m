//
//  GBCStateMachine.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/13/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCStateMachine.h"
#import "GBCSimulator.h"

@interface GBCStateMachine()

// Others

@property(strong, nonatomic) NSTimer *timerToUpdateMachine;
@property(strong, nonatomic) NSDictionary *bluetoothVariablesMachine;
@property(strong, nonatomic) NSDictionary *editedVariablesMachine;
@property(strong, nonatomic) NSMutableArray *chronometerMachine;
@property(strong, nonatomic) NSString *currentStateMachine;
@property(strong, nonatomic) NSString *lastStateMachine;

// Editables Variables

@property(strong, nonatomic) NSString *bleeding;
@property(strong, nonatomic) NSString *diagnostic;
@property(strong, nonatomic) NSString *medicine;
@property(strong, nonatomic) NSString *crystalloid;
@property(strong, nonatomic) NSString *events;
@property(strong, nonatomic) NSString *venous;
@property(strong, nonatomic) NSString *orders;
@property(strong, nonatomic) NSString *liquids;
@property(strong, nonatomic) NSString *tubes;

// Bluetooth Variables

@property(strong, nonatomic) NSString *massage;
@property(strong, nonatomic) NSString *oxygen;
@property(strong, nonatomic) NSString *probe;
@property(strong, nonatomic) NSString *blanket;
@property(strong, nonatomic) NSString *vitalSigns;


@end

@implementation GBCStateMachine

// Local variables Defining

bool finalizationMessage=NO;
NSInteger hoursMachine=0;
NSInteger minutesMachine=0;
NSInteger secondsMachine=0;

// Trasition Times

/*
NSInteger initTime=0;
NSInteger postpartoTime=2;
NSInteger softShockTime=5;
NSInteger softTransitoryTime=10;
NSInteger moderedShockTime=12;
*/

// Initial Time Settings For Short Proofs

NSInteger initTime=0;
NSInteger postpartoTime=1;
NSInteger softShockTime=2;
NSInteger softTransitoryTime=3;
NSInteger moderedShockTime=4;

 
// Initialize Machine Timer to Update State

- (void) initializeMachineTimer{
    
    // Describing a timer which allows us to update the Sync View every 1s
    self.timerToUpdateMachine=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(interruptWithMachineTimer)
                                                              userInfo:nil
                                                               repeats:YES];
    
    // Receive Initial State From Main Class: Simulator
    [self getInitialStateSelected];
    
}

// Method to Receive Initial State From Main Class: Simulator

- (void) getInitialStateSelected{

    self.currentStateMachine=[[GBCSimulator sharedSimulator] sendInitialStateSelected];
    [self setInitialTimerValues];
}

// Method to Init Timer Constants according to the Initial State Selected

- (void) setInitialTimerValues{

    if ([self.currentStateMachine isEqualToString:@"Postparto"]==YES) {
        
        self.currentStateMachine=@"Postparto";
        initTime=0;
    }
    else if ([self.currentStateMachine isEqualToString:@"Choque Leve"]==YES) {
        
        self.currentStateMachine=@"Choque Leve";
        initTime=postpartoTime;
    }
    else if ([self.currentStateMachine isEqualToString:@"Choque Moderado"]==YES) {
        
        self.currentStateMachine=@"Choque Moderado";
        initTime=softShockTime;
    }
    else if ([self.currentStateMachine isEqualToString:@"Choque Grave"]==YES) {
       
        self.currentStateMachine=@"Choque Grave";
        initTime=softTransitoryTime;
    }
    else if ([self.currentStateMachine isEqualToString:@"Estable"]==YES) {
        
        self.currentStateMachine=@"Estable";
    }
    
}

// Where the timer interrupt and where we ask to Main Class Simulator for all important variables values

- (void) interruptWithMachineTimer{
    
    // Ask for Bluetooth Variables
    self.bluetoothVariablesMachine=[[GBCSimulator sharedSimulator] getBluetoothVariables];
   
    // Ask for Editables Variables
    self.editedVariablesMachine=[[GBCSimulator sharedSimulator] sendEditableVariables];
    
    // Ask for Choronometer Value
    self.chronometerMachine=[[GBCSimulator sharedSimulator] sendChronometerValue];
    
    // Separate variables for local analysis
    [self updateLocalVariables];
    
    // Ask to Main Class Simultaror if Simulation has finished
    [self askForFinalizationMessageFromSimulator];
    
}

// Set to Local Variables

- (void) updateLocalVariables{
    
    // Assigning local Values for Chorometer
    hoursMachine=[self.chronometerMachine[0] integerValue];
    minutesMachine=[self.chronometerMachine[1] integerValue];
    secondsMachine=[self.chronometerMachine[2] integerValue];
    
    
    // Assingning local Variables Values for Bluetooth Variables
    self.massage=[self.bluetoothVariablesMachine objectForKey:@"Masaje"];
    self.oxygen=[self.bluetoothVariablesMachine objectForKey:@"Oxígeno"];
    self.probe=[self.bluetoothVariablesMachine objectForKey:@"Sonda Urinaria"];
    self.blanket=[self.bluetoothVariablesMachine objectForKey:@"Manta"];
    self.vitalSigns=[self.bluetoothVariablesMachine objectForKey:@"Medición de Signos"];
    self.venous=[self.bluetoothVariablesMachine objectForKey:@"Vías Venosas"];
    
    // Assingning local Variables Values for Editable Variables
    self.bleeding=[self.editedVariablesMachine objectForKey:@"Sangrado Observado"];
    self.diagnostic=[self.editedVariablesMachine objectForKey:@"Diagnóstico"];
    self.medicine=[self.editedVariablesMachine objectForKey:@"Medicamentos Aplicados"];
    self.crystalloid=[self.editedVariablesMachine objectForKey:@"Cristaloides"];
    self.events=[self.editedVariablesMachine objectForKey:@"Anotación de Eventos"];
    //self.venous=[self.editedVariablesMachine objectForKey:@"Vías Venosas"];
    self.orders=[self.editedVariablesMachine objectForKey:@"Ordenes de Laboratorio"];
    self.liquids=[self.editedVariablesMachine objectForKey:@"Calentar Líquidos"];
    self.tubes=[self.editedVariablesMachine objectForKey:@"Marcar Tubos"];
    
    // Calculate State
    [self calculateState];

}

// Method to Calculate State with New Variables Information

- (void) calculateState{
    
    // Save the current state in other variables for asking later if the state has changed after this analysis
    self.lastStateMachine=self.currentStateMachine;
    
    // State Postparto
    if ([self.currentStateMachine isEqualToString:@"Postparto"]==YES) {
        
        NSLog(@"El Estado Actual es Postparto");
        // Time Condition
        if (minutesMachine+initTime<postpartoTime) {
            
            // Steps Condition
            if (([self.medicine isEqualToString:@"Yes"] && [self.massage isEqualToString:@"Yes"] && [self.bleeding isEqualToString:@"Yes"])==YES){
                
                // Set Next State
                self.currentStateMachine=@"Estable";
            }
        }
        else if (minutesMachine+initTime>=postpartoTime){
            
            // Set Next State
            self.currentStateMachine=@"Choque Leve";
        }
        
    }
    
    // State Choque Leve
    else if ([self.currentStateMachine isEqualToString:@"Choque Leve"]==YES) {
        
        NSLog(@"El Estado Actual es Choque Leve");
        // Time Condition
        if (minutesMachine+initTime<softShockTime) {
            
            // Steps Condition
            if (([self.medicine isEqualToString:@"Yes"] && [self.massage isEqualToString:@"Yes"] && [self.crystalloid isEqualToString:@"Yes"] && [self.bleeding isEqualToString:@"Yes"] && [self.diagnostic isEqualToString:@"Yes"] && [self.venous isEqualToString:@"Yes"])==YES) {
                
                // Set Next State
                self.currentStateMachine=@"Transitorio Leve";
            }
        }
        else if (minutesMachine+initTime>=softShockTime){
            
            // Set Next State
            self.currentStateMachine=@"Choque Moderado";
        }
    
    }
    
    // State Transitorio Leve
    else if ([self.currentStateMachine isEqualToString:@"Transitorio Leve"]==YES) {
        
        NSLog(@"El Estado Actual es Transitorio Leve");
        // Time Condition
        if (minutesMachine+initTime<softTransitoryTime) {
            
            // Steps Condition
            if (([self.medicine isEqualToString:@"Yes"] && [self.massage isEqualToString:@"Yes"] && [self.crystalloid isEqualToString:@"Yes"] && [self.bleeding isEqualToString:@"Yes"] && [self.diagnostic isEqualToString:@"Yes"] && [self.venous isEqualToString:@"Yes"] && [self.oxygen isEqualToString:@"Yes"] && [self.blanket isEqualToString:@"Yes"] && [self.probe isEqualToString:@"Yes"])==YES) {
                
                // Set next State
                self.currentStateMachine=@"Estable";
            }
        }
        else if (minutesMachine+initTime>=softTransitoryTime){
            
            // Set Next State
            self.currentStateMachine=@"Choque Moderado";
        }
    }
    
    // State Choque Moderado
    else if ([self.currentStateMachine isEqualToString:@"Choque Moderado"]==YES) {
        
        NSLog(@"El Estado Actual es Choque Moderado");
        // Time Condition
        if (minutesMachine+initTime<moderedShockTime) {
            
            // Steps Condition
            if (([self.medicine isEqualToString:@"Yes"] && [self.massage isEqualToString:@"Yes"] && [self.crystalloid isEqualToString:@"Yes"] && [self.bleeding isEqualToString:@"Yes"] && [self.diagnostic isEqualToString:@"Yes"] && [self.venous isEqualToString:@"Yes"] && [self.oxygen isEqualToString:@"Yes"] && [self.blanket isEqualToString:@"Yes"] && [self.probe isEqualToString:@"Yes"])==YES) {
                
            // Set Next State
            self.currentStateMachine=@"Estable";
            }
        }
        else if (minutesMachine+initTime>=moderedShockTime){
            
            // Set Next State
            self.currentStateMachine=@"Choque Grave";
        }
    }
    
    // State Choque Grave
    else if ([self.currentStateMachine isEqualToString:@"Choque Grave"]==YES) {
        
        NSLog(@"El Estado Actual es Choque Grave");
        // Steps Condition
        if (([self.medicine isEqualToString:@"Yes"] && [self.massage isEqualToString:@"Yes"] && [self.crystalloid isEqualToString:@"Yes"] && [self.bleeding isEqualToString:@"Yes"] && [self.diagnostic isEqualToString:@"Yes"] && [self.venous isEqualToString:@"Yes"] && [self.oxygen isEqualToString:@"Yes"] && [self.blanket isEqualToString:@"Yes"] && [self.probe isEqualToString:@"Yes"])==YES) {
            
            // Set Next State
            self.currentStateMachine=@"Estable";
        }

        
    }
    
    // State Estable
    else if ([self.currentStateMachine isEqualToString:@"Estable"]==YES) {
        NSLog(@"El Estado Actual es Estable");
        
    }

    // Send to Main Class: Simulator New Calculated State
    [self sendNewState];
}

// Method to Send to Main Class: Simulator New Calculated State

- (void) sendNewState{

    // Check if state has changed
    
    if (self.currentStateMachine!=self.lastStateMachine) {
        [[GBCSimulator sharedSimulator] receiveCurrentState:self.currentStateMachine];
    }
    
}

// Ask to Main Class: Simulator if Simulation has finished

- (void) askForFinalizationMessageFromSimulator{

    finalizationMessage=[[GBCSimulator sharedSimulator] sentFinalizationMessageFromSimulator];
    
    // Check the Simulator Answer
    if (finalizationMessage==YES) {
        [self simulationHasFinished];
    }
}

- (void) simulationHasFinished{
    
    // Stop the Machine timer
    [self finishMachineTimer];

}

// Method to stop the Machine Timer

- (void) finishMachineTimer{
    
    // Stop Timer
    [self.timerToUpdateMachine invalidate];
    self.timerToUpdateMachine = nil;

}

// Lazy Initializations

- (NSTimer *)timerToUpdateMachine{
    if (!_timerToUpdateMachine) {
        _timerToUpdateMachine = [[NSTimer alloc] init];
    }
    return _timerToUpdateMachine;
}

- (NSDictionary *)bluetoothVariablesMachine{
    if (!_bluetoothVariablesMachine) {
        _bluetoothVariablesMachine = [[NSDictionary alloc] init];
    }
    return _bluetoothVariablesMachine;
}

- (NSDictionary *)editedVariablesMachine{
    if (!_editedVariablesMachine) {
        _editedVariablesMachine = [[NSDictionary alloc] init];
    }
    return _editedVariablesMachine;
}

- (NSMutableArray *)chronometerMachine{
    if (!_chronometerMachine) {
        _chronometerMachine = [[NSMutableArray alloc] init];
    }
    return _chronometerMachine;
}


@end
