//
//  GBCSyncViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCSyncViewController.h"
#import "GBCSimulator.h"
#import "GBCRedCodeUtilities.h"

@interface GBCSyncViewController ()

// Others

@property (strong) IBOutlet NSButton *connectionCheck;
@property (strong) IBOutlet NSButton *calibrationCheck;
@property (strong) IBOutlet NSButton *readingSensorsCheck;
@property (strong) IBOutlet NSButton *endSyncProperty;
@property(strong, nonatomic) NSTimer *timerToUpdateSyncView;
@property(strong, nonatomic) NSDictionary *vitalSignsSync;


//Doll Indicators

@property (weak) IBOutlet NSImageView *oxigenSensor;
@property (weak) IBOutlet NSImageView *blanketSensor;
@property (weak) IBOutlet NSImageView *vitalSignsSensor;
@property (weak) IBOutlet NSImageView *massageSensor;
@property (weak) IBOutlet NSImageView *urinarySensor;
@property (weak) IBOutlet NSImageView *catheterSensor;
@property(nonatomic, strong) NSDictionary *sensorsImagesDictionary;

@end

@implementation GBCSyncViewController

// Local Variables Defining

bool bluetoothConnectionCheckSync=NO;
bool calibrationCheckSync=NO;
bool sensorsCheckSync=NO;
bool vitalSignsCheck=NO;
BOOL activeSyncMessage=NO;


// View Did Load Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Call initialize Timer
    [self initializeSyncTimer];
    
    // Ask for bluetooth connection method
    [self askForBluetoothConnection];
    
    // Get the correct values to initialize the view
    self.vitalSignsSync=[[GBCSimulator sharedSimulator] getBluetoothVariables];
    
    // Start with correct values for sensors
    [self updateSyncView];
    
}

// View Did Dissappear Method

- (void)viewDidDisappear{
    
    [self stopTimer];
    
    // Tell Main Class Simulator that View is not already open
    [[GBCSimulator sharedSimulator] isSyncViewOpened:[self.view.window isVisible]];
    
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
    
    // Ask to Main Class Simulator to Read Bluetooth Variables
    self.vitalSignsSync=[[GBCSimulator sharedSimulator] getBluetoothVariables];
    
    // Call Update View Method
    [self updateSyncView];
    
    // Tell to Simulator that this View is visible or not
    [self viewLoadedMessage];
    
    // Testing when timer is running
    //NSLog(@" Timer Sync");
    
    
}
// Method to update the view during this execution view process

- (void) updateSyncView{
    
    // Check Simulator Class Answer
    if (bluetoothConnectionCheckSync==YES) {
        
        // Update Connection Check Appeareance
        [[self.connectionCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Conexión Establecida"
                                                                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                             NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
        [self.connectionCheck setState:1];
        
        // Update calibration Check Appeareance
        [self.calibrationCheck setTransparent:NO];
        
    }
    
    // Check Simulator Class Answer
    if (calibrationCheckSync==YES) {
        
        // Update calibration Check Appeareance
        [[self.calibrationCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Equipo Calibrado"
                                                                                        attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                    NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
        [self.calibrationCheck setState:1];
        
        // Update reading sensors Check Appeareance
        [self.readingSensorsCheck setTransparent:NO];
    }
    
    // Check Simulator Class Answer
    if (sensorsCheckSync==YES) {
        
        // Update reading sensors Check Appeareance
        [[self.readingSensorsCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Equipo Configurado"
                                                                                        attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                    NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
        [self.readingSensorsCheck setState:1];
        
    }
    
    // Check if There are bluetooth variables to Display
    if ([self.vitalSignsSync objectForKey:@"Masaje"] || [self.vitalSignsSync objectForKey:@"Oxígeno"] || [self.vitalSignsSync objectForKey:@"Sonda Urinaria"] || [self.vitalSignsSync objectForKey:@"Manta"] || [self.vitalSignsSync objectForKey:@"Medición de Signos"]!=nil) {
        
        // Flag to display
        vitalSignsCheck=YES;
    }
    
    // If there are are bluetooth variables, then display them
    if (vitalSignsCheck==YES) {
        
        // Update endSyncProperty Button Appeareance
        self.endSyncProperty.enabled=YES;
        
        //Update the doll sensor's indicators
        [self.oxigenSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Oxígeno" inState:[self.vitalSignsSync objectForKey:@"Oxígeno"]]];
        [self.catheterSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Vías Venosas" inState:[self.vitalSignsSync objectForKey:@"Vías Venosas"]]];
        [self.blanketSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Manta" inState:[self.vitalSignsSync objectForKey:@"Manta"]]];
        [self.urinarySensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Sonda Urinaria" inState:[self.vitalSignsSync objectForKey:@"Sonda Urinaria"]]];
        [self.vitalSignsSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Medición de Signos" inState:[self.vitalSignsSync objectForKey:@"Medición de Signos"]]];
        [self.massageSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Masaje" inState:[self.vitalSignsSync objectForKey:@"Masaje"]]];
    }
}


-(NSImage *)imageForVariable:(NSString*)variable
{
    NSImage *image;
    NSString *state = [self.vitalSignsSync objectForKey:variable];
    if ([state isEqualToString:@"Yes"]) {
        image = [NSImage imageNamed:[self.sensorsImagesDictionary objectForKey:variable][0]];
    } else{
        image = [NSImage imageNamed:[self.sensorsImagesDictionary objectForKey:variable][1]];
    }
    return  image;
}

// Let Main class Simulator Know that the window is already opened and receive messages to set this view controller active

- (void)viewLoadedMessage{
    
    // Let Main class Simulator Know that the window is already opened
    [[GBCSimulator sharedSimulator] isSyncViewOpened:[self.view.window isVisible]];
    
    // Ask to Main Class Simulator if i should become active
    activeSyncMessage = [[GBCSimulator sharedSimulator] makeActiveToSync];
    
    // Check for answer
    if (activeSyncMessage==YES) {
        
        // Make the window a key window to look like appearing
        [self.view.window makeKeyWindow];
        
        // Make the window to be infront when this is tried to be opened again
        [self.view.window orderFrontRegardless];
    }
    
    // Tells Main Class Simulator that View has became active
    [[GBCSimulator sharedSimulator] askIfSyncViewIsOpenedAndSetActive:NO];
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

-(NSDictionary *)sensorsImagesDictionary{
    if (!_sensorsImagesDictionary) {
        _sensorsImagesDictionary = @{@"Oxígeno":@[@"red_code_oxigen_sensor_active",
                                                  @"red_code_oxigen_sensor_inactive"],
                                     @"Vías Venosas":@[@"red_code_catheter_sensor_active",
                                                       @"red_code_catheter_sensor_inactive"],
                                     @"Manta":@[@"red_code_blanket_sensor_active",
                                                @"red_code_blanket_sensor_inactive"],
                                     @"Sonda Urinaria":@[@"red_code_urinary_catheter_sensor_active",
                                                         @"red_code_urinary_catheter_sensor_inactive"],
                                     @"Medición de Signos":@[@"red_code_vital_signs_sensor_active",
                                                             @"red_code_vital_signs_sensor_inactive"],
                                     @"Masaje":@[@"red_code_massage_sensor_active",
                                                 @"red_code_massage_sensor_inactive"]};
    }
    return _sensorsImagesDictionary;
}

@end
