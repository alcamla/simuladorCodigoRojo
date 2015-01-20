//
//  GBCSyncViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCSyncViewController.h"
#import "GBCSimulator.h"

@interface GBCSyncViewController ()

// Bluetooth Variables Texts

@property (strong) IBOutlet NSTextField *mascValueTableText;
@property (strong) IBOutlet NSTextField *inyectionValueTableText;
@property (strong) IBOutlet NSTextField *blanketValueTableText;
@property (strong) IBOutlet NSTextField *probeValueTableText;
@property (strong) IBOutlet NSTextField *massageValueText;

// Bluetooth Variables Values

@property (strong) IBOutlet NSTextField *signsMeasurmentValueTableText;
@property (strong) IBOutlet NSTextField *mascTableText;
@property (strong) IBOutlet NSTextField *inyectionTableText;
@property (strong) IBOutlet NSTextField *blanketTableText;
@property (strong) IBOutlet NSTextField *probeTableText;
@property (strong) IBOutlet NSTextField *signsMeasurementTableText;
@property (strong) IBOutlet NSTextField *massageTableText;

// Others

@property (strong) IBOutlet NSButton *connectionCheck;
@property (strong) IBOutlet NSButton *calibrationCheck;
@property (strong) IBOutlet NSButton *readingSensorsCheck;
@property (strong) IBOutlet NSButton *endSyncProperty;
@property(strong, nonatomic) NSTimer *timerToUpdateSyncView;
@property(strong, nonatomic) NSDictionary *vitalSignsSync;

@end

@implementation GBCSyncViewController

// Local Variables Defining

bool bluetoothConnectionCheckSync=NO;
bool calibrationCheckSync=NO;
bool sensorsCheckSync=NO;
bool vitalSignsCheck=NO;
int viewLoadState=0;


// View Did Load Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Call initialize Timer
    [self initializeSyncTimer];
    
    // Ask for bluetooth connection method
    [self askForBluetoothConnection];
    
    
}

// View Did Dissappear Method

- (void)viewDidDisappear{

    [self stopTimer];
}

// Action to End Sync Window

- (IBAction)endSync:(id)sender {
    
    // Stop Timer
    [self stopTimer];
    
    // Hide Current Window
    [self.view.window setIsVisible:NO];
    
}

// Method to stop the timer

- (void) stopTimer{

    [self.timerToUpdateSyncView invalidate];
    self.timerToUpdateSyncView = nil;

}

// Method to ask if should stop the timer

- (void) askIfShouldStopTimer{
    
    if (bluetoothConnectionCheckSync==YES) {
        
        if (calibrationCheckSync==YES) {
            
            if (sensorsCheckSync==YES) {
                
                [self stopTimer];
            }
        }
    }


}

// Ask the Main Class: Simulator to Stablish a bluetooth connection with hardware

- (void) askForBluetoothConnection{
    
    // Only execute it if there is not a conexion
    if (bluetoothConnectionCheckSync==NO) {
        
        // Send a request to Simulator to connect the hardware through bluetooth
        [[GBCSimulator sharedSimulator] createBluetoothObject];
    }
    
    
    
}

// Initialize Sync timer to update View

- (void) initializeSyncTimer{
    
    // Describing a timer which allows us to update the Sync View every 1s
    self.timerToUpdateSyncView=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(interruptWithTimerToUpdateView)
                                                              userInfo:nil
                                                               repeats:YES];
    
    
}

// Where the timer interrupt and where we ask to Main Class Simulator for 3 important checks

- (void) interruptWithTimerToUpdateView{
    
    // Ask if connection was succesfull
    bluetoothConnectionCheckSync=[[GBCSimulator sharedSimulator] askIfBluetoothIsConnected];
    
    // Ask to Main Class Simulator if Calibration is ready
    calibrationCheckSync=[[GBCSimulator sharedSimulator] isCalibrationReady];

    // Ask to Main Class Simulator if Sensors are ready
    sensorsCheckSync=[[GBCSimulator sharedSimulator] areSensorsReady];
    
    // Ask if should stop the timer
    //[self askIfShouldStopTimer];
    
    // Ask to Main Class Simulator to Read Bluetooth Variables
    self.vitalSignsSync=[[GBCSimulator sharedSimulator] getBluetoothVariables];
    
    // Call Update View Method
    [self updateSyncView];
    
    // Testing when timer is running
    NSLog(@" Timer Sync");

}

// Method to update the view during this execution view process

- (void) updateSyncView{
    
    // Check Simulator Class Answer
        if (bluetoothConnectionCheckSync==YES) {
            
        // Update Connection Check Appeareance
        [self.connectionCheck setTitle:@"Conexión Establecida"];
        [self.connectionCheck setState:1];
            
        // Update calibration Check Appeareance
        [self.calibrationCheck setTransparent:NO];
            
    }
            
    // Check Simulator Class Answer
    if (calibrationCheckSync==YES) {
                
        // Update calibration Check Appeareance
        [self.calibrationCheck setTitle:@"Equipo Calibrado"];
        [self.calibrationCheck setState:1];
                
        // Update reading sensors Check Appeareance
        [self.readingSensorsCheck setTransparent:NO];
    }
    
    // Check Simulator Class Answer
    if (sensorsCheckSync==YES) {
            
        // Update reading sensors Check Appeareance
        [self.readingSensorsCheck setTitle:@"Equipo Configurado"];
        [self.readingSensorsCheck setState:1];
                
        
    }
    
    // Check if There are bluetooth variables to Display
    if ([self.vitalSignsSync objectForKey:@"Masaje"] || [self.vitalSignsSync objectForKey:@"Oxígeno"] || [self.vitalSignsSync objectForKey:@"Sonda Urinaria"] || [self.vitalSignsSync objectForKey:@"Manta"] || [self.vitalSignsSync objectForKey:@"Medición de Signos"]!=nil) {
     
        // Flag to display
        vitalSignsCheck=YES;
    }
    
    // If there are are bluetooth variables, then display them
    if (vitalSignsCheck==YES) {
        
        // Update table Values Appeareance
        [self.mascValueTableText setStringValue:[self.vitalSignsSync objectForKey:@"Oxígeno"]];
        [self.inyectionValueTableText setStringValue:[self.vitalSignsSync objectForKey:@"Vías Venosas"]];
        [self.blanketValueTableText setStringValue:[self.vitalSignsSync objectForKey:@"Manta"]];
        [self.probeValueTableText setStringValue:[self.vitalSignsSync objectForKey:@"Sonda Urinaria"]];
        [self.signsMeasurmentValueTableText setStringValue:[self.vitalSignsSync objectForKey:@"Medición de Signos"]];
        [self.massageValueText setStringValue:[self.vitalSignsSync objectForKey:@"Masaje"]];
        
        // Update table Names Appeareance
        [self.mascTableText setStringValue:@"Oxígeno"];
        [self.inyectionTableText setStringValue:@"Vías Venosas Garantizadas"];
        [self.blanketTableText setStringValue:@"Temperatura/Manta"];
        [self.probeTableText setStringValue:@"Sonda Vesical"];
        [self.signsMeasurementTableText setStringValue:@"Medición de Signos"];
        [self.massageTableText setStringValue:@"Masaje"];
        
        
        // Update endSyncProperty Button Appeareance
        self.endSyncProperty.enabled=YES;
        
    }
    
}

// Lazy initializations

- (NSTimer *)timerToUpdateSyncView{
    if (!_timerToUpdateSyncView) {
        _timerToUpdateSyncView = [[NSTimer alloc] init];
    }
    return _timerToUpdateSyncView;
}

- (NSDictionary *)vitalSignsSync{
    if (!_vitalSignsSync) {
        _vitalSignsSync = [[NSDictionary alloc] init];
    }
    return _vitalSignsSync;
}

@end
