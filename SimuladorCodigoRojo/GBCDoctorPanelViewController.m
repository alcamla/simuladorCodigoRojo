//
//  GBCDoctorPanelViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/5/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCDoctorPanelViewController.h"
#import "GBCSimulator.h"

@interface GBCDoctorPanelViewController ()

// Bluetooth and Non Editables Variables

@property (strong) IBOutlet NSButton *oxygenStudentsCheck;
@property (strong) IBOutlet NSButton *massage;
@property (strong) IBOutlet NSButton *blanketStudentCheck;
@property (strong) IBOutlet NSButton *probeStudentCheck;
@property (strong) IBOutlet NSButton *vitalSignsStudentsCheck;

// Editables Variables

@property (strong) IBOutlet NSButton *bleeding;
@property (strong) IBOutlet NSButton *diagnostic;
@property (strong) IBOutlet NSButton *medicineStudentsCheck;
@property (strong) IBOutlet NSButton *crystalloidCheck;
@property (strong) IBOutlet NSButton *eventsAnnotation;
@property (strong) IBOutlet NSButton *venousPathways;
@property (strong) IBOutlet NSButton *laboratoryOrdersCheck;
@property (strong) IBOutlet NSButton *liquidWarming;
@property (strong) IBOutlet NSButton *tubeMarking;

// Others

@property (strong,nonatomic) NSDictionary *bluetoothVariablesPanel;
@property (strong,nonatomic) NSMutableDictionary *editedVariables;
@property (strong,nonatomic) NSMutableArray *editedVariablesValues;
@property (strong,nonatomic) NSMutableArray *editedVariablesKeys;
@property(strong,nonatomic) NSTimer *timerToUpdatePanelView;



@end

@implementation GBCDoctorPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Initialize panel timer
    [self initializePanelTimer];
    
}

// Action to finish Simulator

- (IBAction)finishSimulation:(id)sender {
    
    // Stop the Local Panel Timer
    [self finishPanelTimer];
    
    // Let Main Class: Simulator know that the simulation has finished
    [self sentFinalizationMessage];
    
    // Hide Current Window
    [self.view.window setIsVisible:NO];
    
    // Call Segue to go to next view controller
    [self performSegueWithIdentifier:@"fromPanelToResults" sender:(id)sender];
}

// Method to tell Main Class: Simulator the simulation has finished

- (void) sentFinalizationMessage{
    
    [[GBCSimulator sharedSimulator] receiveFinalizationMessage];

}

// Initialize timer to update the Menu View

- (void) initializePanelTimer{
    
    // Alloc the timer
    self.timerToUpdatePanelView = [[NSTimer alloc] init];
    
    // Describing a timer which allows us to update the Menu View every 1s
    self.timerToUpdatePanelView=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(interruptEventHandlingPanel)
                                                              userInfo:nil
                                                               repeats:YES];
    
}

// Method to be called when timer fires

- (void) interruptEventHandlingPanel{
    
    // Update Panel View every Timer interrupt
    [self updatePanelView];
    
    // Send to Main Class:Simulator Changed or Edited Items for Updating States Machine
    [self sendEditedVariables];
    
    //NSLog(@"Panel timer");
    
}

// Method to update Panel view Controller

- (void) updatePanelView{
    
    // Get bluetooth (non-editable) variables to display
    [self UpdateAndGetBluetoothVariablesFromSimulator];
    
}

// Method to tell Main:Simulator Class about Updates in this Panel view controller

- (void) sendEditedVariables{
    
    // Go to read edited variables
    [self readEditedVariables];
    
    // Send dictionary with Edited Variables values to Main Class: Simulator
    [[GBCSimulator sharedSimulator] getEditedVariablesValues:self.editedVariables];


}

// Read editables variables status

- (void) readEditedVariables{
    
    // Ask for state and fill the Array of values
    
    if (self.bleeding.state==0) {
       self.editedVariablesValues[0]=@"No";
        
    }else{
        self.editedVariablesValues[0]=@"Yes";
    }
    
    if (self.diagnostic.state==0) {
        self.editedVariablesValues[1]=@"No";
        
    }else{
        self.editedVariablesValues[1]=@"Yes";
    }
    
    if (self.medicineStudentsCheck.state==0) {
        self.editedVariablesValues[2]=@"No";
    
    }else{
        self.editedVariablesValues[2]=@"Yes";
        
    }
    
    if (self.crystalloidCheck.state==0) {
        self.editedVariablesValues[3]=@"No";
        
    }else{
        self.editedVariablesValues[3]=@"Yes";
       
    }
    
    if (self.eventsAnnotation.state==0) {
        self.editedVariablesValues[4]=@"No";
        
    }else{
        self.editedVariablesValues[4]=@"Yes";
    }
    
    if (self.venousPathways.state==0) {
        self.editedVariablesValues[5]=@"No";
        
    }else{
        self.editedVariablesValues[5]=@"Yes";
    }
    
    if (self.laboratoryOrdersCheck.state==0) {
        self.editedVariablesValues[6]=@"No";
        
    }else{
       self.editedVariablesValues[6]=@"Yes";
    }
    
    if (self.liquidWarming.state==0) {
        self.editedVariablesValues[7]=@"No";
        
    }else{
        self.editedVariablesValues[7]=@"Yes";
    }
    
    if (self.tubeMarking.state==0) {
        self.editedVariablesValues[8]=@"No";
        
    }else{
        self.editedVariablesValues[8]=@"Yes";
    }

    // Build and Update dictionary
    [self.editedVariables setObject:self.editedVariablesValues[0] forKey:@"Sangrado Observado"];
    [self.editedVariables setObject:self.editedVariablesValues[1] forKey:@"Diagnóstico"];
    [self.editedVariables setObject:self.editedVariablesValues[2] forKey:@"Medicamentos Aplicados"];
    [self.editedVariables setObject:self.editedVariablesValues[3] forKey:@"Cristaloides"];
    [self.editedVariables setObject:self.editedVariablesValues[4] forKey:@"Anotación de Eventos"];
    [self.editedVariables setObject:self.editedVariablesValues[5] forKey:@"Vías Venosas"];
    [self.editedVariables setObject:self.editedVariablesValues[6] forKey:@"Ordenes de Laboratorio"];
    [self.editedVariables setObject:self.editedVariablesValues[7] forKey:@"Calentar Líquidos"];
    [self.editedVariables setObject:self.editedVariablesValues[8] forKey:@"Marcar Tubos"];
    
    
}

// Send to Main Class:Simulator Reanude Simulation Message

- (IBAction)reanudeSimulation:(id)sender {
    
    [[GBCSimulator sharedSimulator] getReanudedMessage];
    
}

// Send to Main Class:Simulator Pause Simulation Message

- (IBAction)pauseSimulation:(id)sender {
    
    [[GBCSimulator sharedSimulator] getPausedMessage];
    
}

// Get and Update bluetooth variables from Main Class: Simulator

- (void) UpdateAndGetBluetoothVariablesFromSimulator{
    
    // Getting dictionary with bluetooth variables
    self.bluetoothVariablesPanel=[[GBCSimulator sharedSimulator] getBluetoothVariables];
    
    // Checking for dictionary Status
    
    if([[self.bluetoothVariablesPanel objectForKey:@"Masaje"] isEqual: @"Yes"]){
        
        // Set it like checked
        self.massage.state=1;
        
    } else if([[self.bluetoothVariablesPanel objectForKey:@"Masaje"] isEqual: @"No"]){
        
        // Set it unchecked
        self.massage.state=0;
    }
    
    if([[self.bluetoothVariablesPanel objectForKey:@"Oxígeno"] isEqual: @"Yes"]){
        
        // Set it like checked
        self.oxygenStudentsCheck.state=1;
        
    } else if([[self.bluetoothVariablesPanel objectForKey:@"Oxígeno"] isEqual: @"No"]){
        
        // Set it unchecked
        self.oxygenStudentsCheck.state=0;
        
    }
    
    if([[self.bluetoothVariablesPanel objectForKey:@"Sonda Urinaria"] isEqual: @"Yes"]){
        
        // Set it like checked
        self.probeStudentCheck.state=1;
        
    } else if([[self.bluetoothVariablesPanel objectForKey:@"Sonda Urinaria"] isEqual: @"No"]){
        
        // Set it unchecked
        self.probeStudentCheck.state=0;
        
    }
    
    if([[self.bluetoothVariablesPanel objectForKey:@"Manta"] isEqual: @"Yes"]){
        
        // Set it like checked
        self.blanketStudentCheck.state=1;
        
    } else if([[self.bluetoothVariablesPanel objectForKey:@"Manta"] isEqual: @"No"]){
        
        // Set it unchecked
        self.blanketStudentCheck.state=0;

    }
    
    if([[self.bluetoothVariablesPanel objectForKey:@"Medición de Signos"] isEqual: @"Yes"]){
        
        // Set it like checked
        self.vitalSignsStudentsCheck.state=1;
        
    } else if([[self.bluetoothVariablesPanel objectForKey:@"Medición de Signos"] isEqual: @"No"]){
        
        // Set it unchecked
        self.vitalSignsStudentsCheck.state=0;
    }
    
    if([[self.bluetoothVariablesPanel objectForKey:@"Vías Venosas"] isEqual: @"Yes"]){
        
        // Set it like checked
        self.venousPathways.state=1;
        
    } else if([[self.bluetoothVariablesPanel objectForKey:@"Vías Venosas"] isEqual: @"No"]){
        
        // Set it unchecked
        self.venousPathways.state=0;
    }

    
}

// Stop timer when Simulation has finished

- (void) finishPanelTimer{
    
    // Stop Timer
    [self.timerToUpdatePanelView invalidate];
    self.timerToUpdatePanelView = nil;

}

// If Vías Venosas Garantizadas was modified, Send a message to Simulator Class

- (IBAction)changeVenous:(id)sender {
    
    [self readEditedVariables];
    [[GBCSimulator sharedSimulator] getEditedVariablesValues:self.editedVariables];
}

// Lazy Initializations

- (NSDictionary *)bluetoothVariablesPanel{
    if (!_bluetoothVariablesPanel) {
        _bluetoothVariablesPanel = [[NSDictionary alloc] init];
    }
    return _bluetoothVariablesPanel;
}

- (NSMutableDictionary *)editedVariables{
    if (!_editedVariables) {
        _editedVariables = [[NSMutableDictionary alloc] init];
    }
    return _editedVariables;
}

- (NSMutableArray *)editedVariablesKeys{
    if (!_editedVariablesKeys) {
        _editedVariablesKeys = [[NSMutableArray alloc] init];
    }
    return _editedVariablesKeys;
}

- (NSMutableArray *)editedVariablesValues{
    if (!_editedVariablesValues) {
        _editedVariablesValues = [[NSMutableArray alloc] init];
    }

    return _editedVariablesValues;
}

@end
