//
//  GBCDoctorPanelViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/5/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCDoctorPanelViewController.h"
#import "GBCSimulator.h"
#import "GBCRedCodeUtilities.h"

@interface GBCDoctorPanelViewController ()

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

//
@property (weak) IBOutlet NSImageView *oxigenSensor;
@property (weak) IBOutlet NSImageView *catheterSensor;
@property (weak) IBOutlet NSImageView *blanketSensor;
@property (weak) IBOutlet NSImageView *urinarySensor;
@property (weak) IBOutlet NSImageView *vitalSignsSensor;
@property (weak) IBOutlet NSImageView *massageSensor;


@property (weak) IBOutlet NSButton *startAnimationButton;
//@property(nonatomic) BOOL simulationIsPaused;

@end

@implementation GBCDoctorPanelViewController

// Local declarations

bool simulationIsPaused=NO;

// View did load

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Initialize panel timer
    [self initializePanelTimer];
    
    // Get the state of the simulation
    simulationIsPaused=[[GBCSimulator sharedSimulator] sendPausedOrNotMessage];
    
    // Refresh the view with correct initial values, specifically the button appearence
    [self refreshPlayPauseButton];
    
    // Refresh the view with correct initial values for sensors
    [self updatePanelView];
    
    // Refres the view with the correct initial values for Checkboxes
    [self reloadCheckBoxesValues];
}

// Method called when view did disappear

- (void)viewDidDisappear{
    
    // Stop the Local Panel Timer
    [self finishPanelTimer];
    
    // Tell to main class simulator that view is now hidden
    [[GBCSimulator sharedSimulator] isPanelViewOpened:[self.view.window isVisible]];
    
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
    self.timerToUpdatePanelView=[NSTimer scheduledTimerWithTimeInterval:0.3
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
    
    // Tell to Main Class:Simulator if this view is loaded
    [self panelLoadedMessage];
    
    // Send Status of Simulation to main class simulator
    [self sendSimulationState];
    
    //NSLog(@"Panel timer");
    
}

// Send Status of Simulation to main class simulator

- (void) sendSimulationState{
    
    [[GBCSimulator sharedSimulator] receivePausedOrNotMessage:simulationIsPaused];

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

// Read editables variables status and Update CheckBox Tittle Appearence

- (void) readEditedVariables{
    
    // Ask for state and fill the Array of values
    
    if (self.bleeding.state==0) {
        self.editedVariablesValues[0]=@"No";
        
        [[self.bleeding cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Sangrado Observado"
                                                                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                             NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
        self.editedVariablesValues[0]=@"Yes";
      
        [[self.bleeding cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Sangrado Observado"
                                                                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                             NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
        
    }
    
    if (self.diagnostic.state==0) {
        self.editedVariablesValues[1]=@"No";
        
        [[self.diagnostic cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Establecer Causa Diagnóstica"
                                                                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                             NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
        self.editedVariablesValues[1]=@"Yes";
        
        [[self.diagnostic cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Establecer Causa Diagnóstica"
                                                                                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                               NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
    }
    
    if (self.medicineStudentsCheck.state==0) {
        self.editedVariablesValues[2]=@"No";
        
        [[self.medicineStudentsCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Medicamentos Aplicados"
                                                                                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                               NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
    
    }else{
        self.editedVariablesValues[2]=@"Yes";
        
        [[self.medicineStudentsCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Medicamentos Aplicados"
                                                                                              attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                          NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
        
    }
    
    if (self.crystalloidCheck.state==0) {
        self.editedVariablesValues[3]=@"No";
        
        [[self.crystalloidCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Cristaloides Infundidos"
                                                                                              attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                          NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
        self.editedVariablesValues[3]=@"Yes";
        
        [[self.crystalloidCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Cristaloides Infundidos"
                                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                     NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
        
        
       
    }
    
    if (self.eventsAnnotation.state==0) {
        self.editedVariablesValues[4]=@"No";
        
        [[self.eventsAnnotation cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Anotación de Eventos"
                                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                     NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
        self.editedVariablesValues[4]=@"Yes";
        
        [[self.eventsAnnotation cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Anotación de Eventos"
                                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                     NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
    }
    
    if (self.venousPathways.state==0) {
        self.editedVariablesValues[5]=@"No";
        
        [[self.venousPathways cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Vías Venosas Garantizadas"
                                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                     NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
        self.editedVariablesValues[5]=@"Yes";
        
        [[self.venousPathways cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Vías Venosas Garantizadas"
                                                                                       attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                   NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
    }
    
    if (self.laboratoryOrdersCheck.state==0) {
        self.editedVariablesValues[6]=@"No";
        
        [[self.laboratoryOrdersCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Realizar Órdenes de Laboratorio"
                                                                                       attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                   NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
       self.editedVariablesValues[6]=@"Yes";
        
       [[self.laboratoryOrdersCheck cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Realizar Órdenes de Laboratorio"
                                                                                              attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                          NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
    }
    
    if (self.liquidWarming.state==0) {
        self.editedVariablesValues[7]=@"No";
        
        [[self.liquidWarming cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Calentar Líquidos"
                                                                                              attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                          NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
        self.editedVariablesValues[7]=@"Yes";
        
        [[self.liquidWarming cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Calentar Líquidos"
                                                                                      attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                  NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
    }
    
    if (self.tubeMarking.state==0) {
        self.editedVariablesValues[8]=@"No";
        
        [[self.tubeMarking cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Marcar Tubos"
                                                                                      attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                  NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName, nil]]];
        
    }else{
        self.editedVariablesValues[8]=@"Yes";
        
        [[self.tubeMarking cell] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Marcar Tubos"
                                                                                    attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:28],
                                                                                                NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName, nil]]];
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

// Action when pause-reanude button is pressed

- (IBAction)animationStateDidChange:(id)sender {
    
    // Change the state of simulation
    simulationIsPaused=!simulationIsPaused;
    
    // Refresh the Icon of that button
    [self refreshPlayPauseButton];
    
    
}

// Refresh the appearence of the Play_Pause Button

- (void) refreshPlayPauseButton{
    
    // Check if simulation is paussed or not to set the Icon
    if (simulationIsPaused==YES) {
        [self.startAnimationButton setImage:[NSImage imageNamed:@"play-97626_640"]];
    }else{
        [self.startAnimationButton setImage:[NSImage imageNamed:@"pause-97625_1280"]];
    }

}
// Get and Update bluetooth variables from Main Class: Simulator

- (void) UpdateAndGetBluetoothVariablesFromSimulator{
    
    // Getting dictionary with bluetooth variables
    self.bluetoothVariablesPanel=[[GBCSimulator sharedSimulator] getBluetoothVariables];
    
    [self.oxigenSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Oxígeno"
                                                                         inState:[self.bluetoothVariablesPanel objectForKey:@"Oxígeno"]]];
    [self.catheterSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Vías Venosas"
                                                                           inState:[self.bluetoothVariablesPanel objectForKey:@"Vías Venosas"]]];
    [self.blanketSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Manta"
                                                                          inState:[self.bluetoothVariablesPanel objectForKey:@"Manta"]]];
    [self.urinarySensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Sonda Urinaria"
                                                                          inState:[self.bluetoothVariablesPanel objectForKey:@"Sonda Urinaria"]]];
    [self.vitalSignsSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Medición de Signos"
                                                                             inState:[self.bluetoothVariablesPanel objectForKey:@"Medición de Signos"]]];
    [self.massageSensor setImage:[GBCRedCodeUtilities sensorStateImageForVariable:@"Masaje"
                                                                          inState:[self.bluetoothVariablesPanel objectForKey:@"Masaje"]]];
    
    
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

// Tell to main class simulator if panel has been already loaded and ask if Simulator wants me to be active

- (void) panelLoadedMessage{
    
    [[GBCSimulator sharedSimulator] isPanelViewOpened:[self.view.window isVisible]];

    // Ask if this view controller should become active
    if ([[GBCSimulator sharedSimulator] makeActiveToPanel]==YES) {
        
        // Make the window a key window to look like appearing
        [self.view.window makeKeyWindow];
        
        // Make the window to be infront when this is tried to be opened again
        [self.view.window orderFrontRegardless];
    }
    
    // Tells Simulator that view is active now
    [[GBCSimulator sharedSimulator] askIfPanelViewIsOpenedAndSetActive:NO];
}

// Refres the view with the correct initial values for Checkboxes

- (void) reloadCheckBoxesValues{
    
    // Ask to main class simulator for the values of editable variables to update their values as should
    self.editedVariables=[[GBCSimulator sharedSimulator] sendEditableVariables];
    
    // Update CheckBoxes Values
    
    if ([[self.editedVariables objectForKey:@"Sangrado Observado"] isEqualToString:@"Yes"]==YES) {
        self.bleeding.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Diagnóstico"] isEqualToString:@"Yes"]==YES) {
        self.diagnostic.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Medicamentos Aplicados"] isEqualToString:@"Yes"]==YES) {
        self.medicineStudentsCheck.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Cristaloides"] isEqualToString:@"Yes"]==YES) {
        self.crystalloidCheck.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Anotación de Eventos"] isEqualToString:@"Yes"]==YES) {
        self.eventsAnnotation.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Vías Venosas"] isEqualToString:@"Yes"]==YES) {
        self.venousPathways.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Ordenes de Laboratorio"] isEqualToString:@"Yes"]==YES) {
        self.laboratoryOrdersCheck.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Calentar Líquidos"] isEqualToString:@"Yes"]==YES) {
        self.liquidWarming.state=1;
    }
    if ([[self.editedVariables objectForKey:@"Marcar Tubos"] isEqualToString:@"Yes"]==YES) {
        self.tubeMarking.state=1;
    }
    
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
