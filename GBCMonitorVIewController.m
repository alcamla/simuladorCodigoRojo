//
//  GBCMonitorVIewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/19/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import "GBCMonitorVIewController.h"
#import "GBCSimulator.h"
#import "PlotItem.h"
#import "RealTimePlot.h"
#import "PlotView.h"
#import "ecgsyn.h"

@interface GBCMonitorVIewController ()

// Defining properties for Interface Objects

@property (strong) IBOutlet NSTextField *conscienceValue;
@property (strong) IBOutlet NSTextField *heartRateValue;
@property (strong) IBOutlet NSTextField *oxigenSaturationValue;
@property (strong) IBOutlet NSTextField *respiratoryFrecuencyValue;
@property (strong) IBOutlet NSTextField *arterialPresureValue;
@property (strong) IBOutlet NSTextField *chronometerTextField;

@property (nonatomic, strong) PlotItem *plotItem;
@property (weak) IBOutlet PlotView *plotView;

@property(nonatomic, strong) NSMutableArray *ecgVector;


@property (strong, nonatomic) NSDictionary *vitalSingsMonitor;
@property (strong, nonatomic) NSTimer * timerToUpdateMonitorView;
@property (strong, nonatomic) NSTimer * chronometer;
@property (strong, nonatomic) NSTimer * beepTimer;
@property (strong, nonatomic) NSMutableArray *chronometerArray;
@property (strong, nonatomic) NSString *hoursString;
@property (strong, nonatomic) NSString *minutesString;
@property (strong, nonatomic) NSString *secondsString;
@property (strong, nonatomic) NSString *currentStateMonitor;
@property (strong, nonatomic) NSSound *beepSound;


@end

@implementation GBCMonitorVIewController

bool finalizationCheckMonitor=NO;
bool paussedCheckMonitor=NO;
bool reanudedCheckMonitor=NO;
bool panelViewState=NO;
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
    
    // Ask for initial state
    [self askForInitialStateAndSetInitialFrecuency];
    
    // Set the frecuency for the beep
    [self setBeepFrecuency];
    
}

-(void)viewDidAppear{
    self.plotItem = [[RealTimePlot alloc] init];
    
}

- (void) viewDidDisappear{

    // Reset variables
    [self simulationHasFinishedMonitor];

}

-(void)setPlotItem:(PlotItem *)item
{
    if ( _plotItem != item ) {
        [_plotItem killGraph];
        
        _plotItem = item;
        
        [_plotItem renderInView:self.plotView withTheme:nil animated:YES];
    }
}


// Initialize the timer to update Monitor View and Hold the Chronometer

- (void) initializeMonitorTimer{
    
    // Describing a timer which allows us to update the Menu View every 1s
    self.timerToUpdateMonitorView=[NSTimer scheduledTimerWithTimeInterval:0.5
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
    [self askIfSimulationIsPaused];
    
    // Ask if simulation is finished
    [self askIfSimulationHasFinished];
    
    // Ask to Simulator for current state to set beep frecuecy
    [self askForStateToSetBeepFrecuency];
}

// Update View Controller

- (void) updateMonitorViewController{
    
    // Update vital signs in monitor view
    [self updateVitalSignsInMonitor];
    
}



// Update Vital Signs

- (void) updateVitalSignsInMonitor{
    
    //Update the ECG signal based on the current heart rate.
    
    
    //TODO: 
    
    // Ask Simulator to send the vital signs and alloc them in monitor dictionary
    self.vitalSingsMonitor= [[GBCSimulator sharedSimulator] getCurrentVitalSigns];
    
    
    // Assing vital signs values variables from local dictionary to local variables
    [self.conscienceValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Consciencia"]];
    [self.heartRateValue setStringValue: [self.vitalSingsMonitor objectForKey:@"Ritmo Cardiaco"]];
    [self.arterialPresureValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Presión Arterial"]];
    [self.respiratoryFrecuencyValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Frecuencia Respiratoria"]];
    [self.oxigenSaturationValue setStringValue:[self.vitalSingsMonitor objectForKey:@"Saturación de Oxígeno"]];

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

// Stop Beep timer

- (void) finishBeepTimer{
    
    // Stop Timer
    [self.beepTimer invalidate];
    self.beepTimer = nil;
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

- (void) askIfSimulationIsPaused{
    
    paussedCheckMonitor=[[GBCSimulator sharedSimulator] sendPausedOrNotMessage];

    // Check answer from Simulator
    if (paussedCheckMonitor==YES) {
       
        // Stop Chronometer Timer
        [self.chronometer invalidate];
        self.chronometer = nil;
        
        // Stop Beep Timer
        [self.beepTimer invalidate];
        self.beepTimer = nil;

        
    }else{
        if (self.chronometer.valid==NO) {
            
            // Reinitializite Timer and Chronometer
            [self initializeChronometer];
            
        }
        if (self.beepTimer.valid==NO) {
            
            // Reinitializite Beep Timer 
            [self setBeepFrecuency];
            
        }

        
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

// End the Simulation Activity for this monitor

- (void) simulationHasFinishedMonitor{
    
    // Send Finalization Message to Main Class Simulator
    
    
    // Finish Chronometer and Timer
    [self finishChoronometer];
    
    // Finish Timer to update
    [self finishTimerToUpdate];
    
    // Finish Beep Timer
    [self finishBeepTimer];
    
    // Close this View
    [self.view.window setIsVisible:NO];
    
}

// Method to tell Main Class: Simulator that the Chronometer has Started

- (void) sendMessageOfStartedChronometer{
    
    [[GBCSimulator sharedSimulator] receiveStartedChronometerMessage];

}

// Method called when panel button is pressed

- (IBAction)goToPanel:(id)sender {
    
    // Ask to Main Class Simulator if the panel view is already opened
    panelViewState =[[GBCSimulator sharedSimulator] askIfPanelViewIsOpenedAndSetActive:YES];
    
    // Perform segue or not if should
    if (panelViewState==NO) {
        [self performSegueWithIdentifier:@"fromMonitorToPanel" sender:sender];
    }
    
}

// Method to ask to main class simulator for the state initial

- (void) askForInitialStateAndSetInitialFrecuency{

    self.currentStateMonitor=[[GBCSimulator sharedSimulator] sendCurrentState];
    
}

// Method to ask to main class simulator for the state to set beep frecuency

- (void) askForStateToSetBeepFrecuency{
    
    // Ask if state has changed
    if (self.currentStateMonitor !=[[GBCSimulator sharedSimulator] sendCurrentState]) {
        
        // Update current state
        self.currentStateMonitor = [[GBCSimulator sharedSimulator] sendCurrentState];
        
        // Set timer frecuency according to the state heart rate
        [self setBeepFrecuency];
        
    }
    
}

// Set beep frecuency acording to the state

- (void) setBeepFrecuency{
    
    [self finishBeepTimer];
    
    if ([self.currentStateMonitor isEqualToString:@"Postparto"]==YES) {
        
        self.beepTimer=[NSTimer scheduledTimerWithTimeInterval:(0.7) target:self selector:@selector(playBeep) userInfo:nil repeats:YES];
    };
    if ([self.currentStateMonitor isEqualToString:@"Choque Leve"]==YES) {
        
        self.beepTimer=[NSTimer scheduledTimerWithTimeInterval:(0.6) target:self selector:@selector(playBeep) userInfo:nil repeats:YES];
    };
    if ([self.currentStateMonitor isEqualToString:@"Transitorio Leve"]==YES) {
        
        self.beepTimer=[NSTimer scheduledTimerWithTimeInterval:(0.7) target:self selector:@selector(playBeep) userInfo:nil repeats:YES];
    };
    if ([self.currentStateMonitor isEqualToString:@"Choque Moderado"]==YES) {
        
        self.beepTimer=[NSTimer scheduledTimerWithTimeInterval:(0.5) target:self selector:@selector(playBeep) userInfo:nil repeats:YES];
    };
    if ([self.currentStateMonitor isEqualToString:@"Choque Grave"]==YES) {
        
        self.beepTimer=[NSTimer scheduledTimerWithTimeInterval:(0.4) target:self selector:@selector(playBeep) userInfo:nil repeats:YES];
        
    };
    if ([self.currentStateMonitor  isEqualToString:@"Estable"]==YES) {
        
        self.beepTimer=[NSTimer scheduledTimerWithTimeInterval:(0.7) target:self selector:@selector(playBeep) userInfo:nil repeats:YES];
    };

}

// Play the beep for the Simulation

- (void) playBeep{
    
    // Set a beep sound to the simulation
    //self.beepSound=[NSSound soundNamed:@"ECGbeep.mp3"];
    self.beepSound=[NSSound soundNamed:@"Tink.aiff"];
    [self.beepSound play];

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

-(NSTimer *)beepTimer{
    if (!_beepTimer) {
        _beepTimer = [[NSTimer alloc] init];
    }
    return _beepTimer;
}

-(NSSound *)beepSound{
    if (!_beepSound) {
        _beepSound = [[NSSound alloc] init];
    }
    return _beepSound;
}

-(NSMutableArray*)ecgVector{
    if (!_ecgVector) {
        _ecgVector = [NSMutableArray new];
    }
    return _ecgVector;
}

@end
