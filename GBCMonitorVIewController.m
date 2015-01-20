//
//  GBCMonitorVIewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/19/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import "GBCMonitorVIewController.h"
#import "GBCSimulator.h"

@interface GBCMonitorVIewController ()

// Defining properties for Interface Objects

@property (strong) IBOutlet NSTextField *conscienceValue;
@property (strong) IBOutlet NSTextField *heartRateValue;
@property (strong) IBOutlet NSTextField *oxigenSaturationValue;
@property (strong) IBOutlet NSTextField *respiratoryFrecuencyValue;
@property (strong) IBOutlet NSTextField *arterialPresureValue;
@property (strong) IBOutlet NSTextField *chronometerTextField;


@property (strong, nonatomic) NSDictionary *vitalSingsMonitor;
@property (strong, nonatomic) NSTimer * timerToUpdateMonitorView;
@property (strong, nonatomic) NSTimer * chronometer;
@property (strong, nonatomic) NSMutableArray *chronometerArray;
@property (strong, nonatomic) NSString *hoursString;
@property (strong, nonatomic) NSString *minutesString;
@property (strong, nonatomic) NSString *secondsString;


@end

@implementation GBCMonitorVIewController

bool finalizationCheckMonitor=NO;
bool paussedCheckMonitor=NO;
bool reanudedCheckMonitor=NO;
int hours=0;
int seconds=0;
int minutes=0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Initial View Settings
    self.title=@"Monitor de Signos Vitales";
    
    // Update Initial Values For Elements in View
    [self updateMonitorViewController];
    
    // Initialize Timer to Keep Updating View
    [self initializeMonitorTimer];
    
    // Initialize Chronometer
    [self initializeChronometer];
    
    // Send Init Chronometer Started Message to Main Class: Simulator
    [self sendMessageOfStartedChronometer];
    
}

// Initialize the timer to update Monitor View and Hold the Chronometer

- (void) initializeMonitorTimer{
    
    // Describing a timer which allows us to update the Menu View every 1s
    self.timerToUpdateMonitorView=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(interruptEventHandling)
                                                              userInfo:nil
                                                               repeats:YES];
}

// Initialize the Chronometer Timer

- (void) initializeChronometer{
    
    // Describing a timer which allows us to update the Menu View every 1s
    self.chronometer=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                                   target:self
                                                                 selector:@selector(updateChronometer)
                                                                 userInfo:nil
                                                                  repeats:YES];
}



// Interrupt Process

- (void) interruptEventHandling{

    // Update Monitor View every Timer interrupt
    [self updateMonitorViewController];
    
    // Ask if simulation is paused
    [self askIfChronometerIsPaused];
    
    // Ask if simulation is reanuded
    [self askIfChronometerIsReanuded];
    
    // Ask if simulation is finished
    [self askIfSimulationHasFinished];
}

// Update View Controller

- (void) updateMonitorViewController{
    
    // Update vital signs in monitor view
    [self updateVitalSignsInMonitor];
    
}

// Update Vital Signs

- (void) updateVitalSignsInMonitor{

    // Ask Simulator to send the vital signs and alloc them in monitor dictionary
    self.vitalSingsMonitor= [[GBCSimulator sharedSimulator] getCurrentVitalSigns];
    
    // Assing vital signs values variables from local dictionary to local variables
    [self.conscienceValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Consciencia"]];
    [self.heartRateValue setStringValue: [self.vitalSingsMonitor objectForKey:@"Ritmo Cardiaco"]];
    [self.arterialPresureValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Presión Arterial"]];
    [self.respiratoryFrecuencyValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Frecuencia Respiratoria"]];
    [self.oxigenSaturationValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Saturación de Oxígeno"]];
    
    // Print to Verify!
    //NSLog(@"Signos Vitales Actuales %@ %@ %@ %@ %@", [self.conscienceValue stringValue],[self.heartRateValue stringValue],[self.oxigenSaturationValue stringValue],[self.arterialPresureValue stringValue],[self.respiratoryFrecuencyValue stringValue]);

}

// Update Chronometer

- (void) updateChronometer{
    
    // Update Seconds, minutes and hours
    seconds++;
    
    if (seconds == 60)
    {
        seconds = 0;
        minutes++;
    }
    if (minutes==60) {
        
        minutes=0;
        hours++;
    }
    
    // Dislplay the new chronometer value
    self.chronometerTextField.stringValue = [NSString stringWithFormat:@"%02i:%02i:%02i",hours,minutes,seconds];
    
    // Convert int values to string values to pack them into an array
    self.secondsString= [NSString stringWithFormat:@"%d",seconds];
    self.minutesString= [NSString stringWithFormat:@"%d",minutes];
    self.hoursString= [NSString stringWithFormat:@"%d",hours];
    
    // Pack Chronometer strings into an array
    self.chronometerArray[0] = self.hoursString;
    self.chronometerArray[1] = self.minutesString;
    self.chronometerArray[2] = self.secondsString;
    
    // Send the array
    [self sendChronometerValue];
    
    }

// Stop Chronometer

- (void) finishChoronometer{
    
    // Stop Timer
    [self.chronometer invalidate];
    self.chronometer = nil;
}

// Finish Timer to update

- (void) finishTimerToUpdate{
    
    // Stop Timer
    [self.timerToUpdateMonitorView invalidate];
    self.timerToUpdateMonitorView = nil;
    seconds=0;
    minutes=0;
    hours=0;
    
}
// Ask to Main Class: Simulator if Chronometer has been paused

- (void) askIfChronometerIsPaused{
    
    paussedCheckMonitor=[[GBCSimulator sharedSimulator] sendPausedMessage];

    // Check answer from Simulator
    if (paussedCheckMonitor==YES) {
       
        // Stop Timer
        [self.chronometer invalidate];
        self.chronometer = nil;
        
    }
    
}

// Ask to Main Class: Simulator if Chronometer has been paused

- (void) askIfChronometerIsReanuded{
    
    reanudedCheckMonitor=[[GBCSimulator sharedSimulator] sendReanudedMessage];
    
    // Check answer from Simulator
    if (reanudedCheckMonitor==YES) {
        
        // Tell to Main Class Simulator that simulation has been reanuded
        [[GBCSimulator sharedSimulator] simulationReanudedConfirmation];
        
        // Reinitializite Timer and Chronometer
        [self initializeChronometer];
      
    }
    
}

// Send Chronometer value time to Simulator

- (void) sendChronometerValue{
 
    [[GBCSimulator sharedSimulator] getChronometerValue:self.chronometerArray];
    

}

// Ask to Main Class: Simulator if simulation has finished

- (void) askIfSimulationHasFinished{
    
    finalizationCheckMonitor=[[GBCSimulator sharedSimulator] sentFinalizationMessageFromSimulator];
    
    // Check for Simulator Answer
    if (finalizationCheckMonitor==YES) {
        [self simulationHasFinishedMonitor];
    }

}

- (void) simulationHasFinishedMonitor{
    
    // Finish Chronometer and Timer
    [self finishChoronometer];
    
    // Finish Timer to update
    [self finishTimerToUpdate];
    
    // Close this View
    [self.view.window setIsVisible:NO];
    
}

// Method to tell Main Class: Simulator that the Chronometer has Started

- (void) sendMessageOfStartedChronometer{
    
    [[GBCSimulator sharedSimulator] receiveStartedChronometerMessage];

}

// Lazy Initializations

-(NSMutableArray *)chronometerArray{
    if (!_chronometerArray) {
        _chronometerArray = [[NSMutableArray alloc] init];
    }
    return _chronometerArray;
}

-(NSDictionary *)vitalSingsMonitor{
    if (!_vitalSingsMonitor) {
        _vitalSingsMonitor = [[NSDictionary alloc] init];
    }
    return _vitalSingsMonitor;
}

-(NSTimer *)timerToUpdateMonitorView{
    if (!_timerToUpdateMonitorView) {
        _timerToUpdateMonitorView = [[NSTimer alloc] init];
    }
    return _timerToUpdateMonitorView;
}

-(NSTimer *)chronometer{
    if (!_chronometer) {
        _chronometer = [[NSTimer alloc] init];
    }
    return _chronometer;
}


@end
