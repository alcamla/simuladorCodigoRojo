//
//  GBCResultsViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCResultsViewController.h"
#import "GBCSimulator.h"

@interface GBCResultsViewController ()

// Variables to display

@property (strong) IBOutlet NSTextField *oxygenLabel;
@property (strong) IBOutlet NSTextField *temperatureLabel;
@property (strong) IBOutlet NSTextField *probeLabel;
@property (strong) IBOutlet NSTextField *massageLabel;
@property (strong) IBOutlet NSTextField *vitalSignsLabel;
@property (strong) IBOutlet NSTextField *bleedingLabel;
@property (strong) IBOutlet NSTextField *diagnosticLabel;
@property (strong) IBOutlet NSTextField *medicineLabel;
@property (strong) IBOutlet NSTextField *crystalloidLabel;
@property (strong) IBOutlet NSTextField *eventsLabel;
@property (strong) IBOutlet NSTextField *venusLabel;
@property (strong) IBOutlet NSTextField *ordersLabel;
@property (strong) IBOutlet NSTextField *liquidsLabel;
@property (strong) IBOutlet NSTextField *tubesLabel;
@property (strong) IBOutlet NSTextField *scoreLabel;
@property (strong) IBOutlet NSProgressIndicator *scoreBar;

// Others

@property (strong,nonatomic) NSDictionary *bluetoothVariablesResults;
@property (strong,nonatomic) NSMutableDictionary *editableVariablesResults;
@property (strong,nonatomic) NSString *scoreString;
@property (strong,nonatomic) NSString *lastStateResults;
@property (strong,nonatomic) NSMutableArray *lastTimeRegistered;

@end

@implementation GBCResultsViewController

int scoreCounter=0;
int finalScore=0;
int stateScore=0;
int timeScore=0;
NSNumber *minutesResulst=0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Ask for Status of Variables to Display Results
    [self readVariablesStatusToDisplay];
}

// Action to go to a new Simulation

- (IBAction)goToNewSimulation:(id)sender {
    
    //Restart Score
    scoreCounter=0;
    
    // Hide Current Window
    [self.view.window setIsVisible:NO];
    
    // Call Segue to go to next view controller
    [self performSegueWithIdentifier:@"fromResultsToMenu" sender:sender];
    
}

// Ask to simulator for Status of Variables to Display

- (void)readVariablesStatusToDisplay{
    
    // Ask to Simulator the last time registered for checking the duration
    self.lastTimeRegistered=[[GBCSimulator sharedSimulator] sendChronometerValue];
    
    // Ask to Simulator for last state registered
    self.lastStateResults=[[GBCSimulator sharedSimulator] sendCurrentState];
    
    //Ask to Simulator for bluetooth Variables
    self.bluetoothVariablesResults=[[GBCSimulator sharedSimulator] getBluetoothVariables];
    
    //Ask to Simulator for editable Variables
    self.editableVariablesResults=[[GBCSimulator sharedSimulator] sendEditableVariables];
    
    // Display Results
    [self displayResults];
    
}

// Method to display the Results read from Simulator and Calcule it in this Class

- (void)displayResults{
    
    // Display Bluetooth Variables Values
    if ([[self.bluetoothVariablesResults objectForKey:@"Oxígeno"] isEqualToString:@"Yes"]==YES) {
        self.oxygenLabel.stringValue=@"Si";
    }else{
        self.oxygenLabel.stringValue=@"No";
    }
    if ([[self.bluetoothVariablesResults objectForKey:@"Manta"] isEqualToString:@"Yes"]==YES) {
        self.temperatureLabel.stringValue=@"Si";
    }else{
        self.temperatureLabel.stringValue=@"No";
    }
    if ([[self.bluetoothVariablesResults objectForKey:@"Sonda Urinaria"] isEqualToString:@"Yes"]==YES) {
        self.probeLabel.stringValue=@"Si";
    }else{
        self.probeLabel.stringValue=@"No";
    }
    if ([[self.bluetoothVariablesResults objectForKey:@"Masaje"] isEqualToString:@"Yes"]==YES) {
        self.massageLabel.stringValue=@"Si";
    }else{
        self.massageLabel.stringValue=@"No";
    }
    if ([[self.bluetoothVariablesResults objectForKey:@"Medición de Signos"] isEqualToString:@"Yes"]==YES) {
        self.vitalSignsLabel.stringValue=@"Si";
    }else{
        self.vitalSignsLabel.stringValue=@"No";
    }
    
    
    // Display Editable Variables Values
    if ([[self.editableVariablesResults objectForKey:@"Sangrado Observado"] isEqualToString:@"Yes"]==YES) {
        self.bleedingLabel.stringValue=@"Si";
    }else{
        self.bleedingLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Diagnóstico"] isEqualToString:@"Yes"]==YES) {
        self.diagnosticLabel.stringValue=@"Si";
    }else{
        self.diagnosticLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Medicamentos Aplicados"] isEqualToString:@"Yes"]==YES) {
        self.medicineLabel.stringValue=@"Si";
    }else{
        self.medicineLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Cristaloides"] isEqualToString:@"Yes"]==YES) {
        self.crystalloidLabel.stringValue=@"Si";
    }else{
        self.crystalloidLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Anotación de Eventos"] isEqualToString:@"Yes"]==YES) {
        self.eventsLabel.stringValue=@"Si";
    }else{
        self.eventsLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Vías Venosas"] isEqualToString:@"Yes"]==YES) {
        self.venusLabel.stringValue=@"Si";
    }else{
        self.venusLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Ordenes de Laboratorio"] isEqualToString:@"Yes"]==YES) {
        self.ordersLabel.stringValue=@"Si";
    }else{
        self.ordersLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Calentar Líquidos"] isEqualToString:@"Yes"]==YES) {
        self.liquidsLabel.stringValue=@"Si";
    }else{
        self.liquidsLabel.stringValue=@"No";
    }
    if ([[self.editableVariablesResults objectForKey:@"Marcar Tubos"] isEqualToString:@"Yes"]==YES) {
        self.tubesLabel.stringValue=@"Si";
    }else{
        self.tubesLabel.stringValue=@"No";
    }
    

    // Calculate Score to Display
    [self calculateScore];
    
}

// Method to Calculate Score

- (void) calculateScore{
    
    // Check "Yes" to Add Unity to Score
    
    if ([self.oxygenLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.oxygenLabel setTextColor:[NSColor greenColor]];
    }
    
    if ([self.temperatureLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.temperatureLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.probeLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.probeLabel setTextColor:[NSColor greenColor]];
    }
    if ([self.massageLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.massageLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.vitalSignsLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.vitalSignsLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.bleedingLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.bleedingLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.diagnosticLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.diagnosticLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.medicineLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.medicineLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.crystalloidLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.crystalloidLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.eventsLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.eventsLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.venusLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.venusLabel setTextColor:[NSColor greenColor]];
    }

    if ([self.ordersLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.ordersLabel setTextColor:[NSColor greenColor]];
    }
    
    if ([self.liquidsLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.liquidsLabel setTextColor:[NSColor greenColor]];
    }
    
    if ([self.tubesLabel.stringValue isEqualToString:@"Si"]) {
        scoreCounter++;
        [self.tubesLabel setTextColor:[NSColor greenColor]];
    }
    
    // Calculate Timer Score
    minutesResulst=self.lastTimeRegistered[1];
    if ([minutesResulst doubleValue]>=0.0) {
        timeScore=100;
    }else if ([minutesResulst doubleValue]>=2.0){
        timeScore=80;
    }else if ([minutesResulst doubleValue]>=4.0){
        timeScore=60;
    }else if ([minutesResulst doubleValue]>=6.0){
        timeScore=40;
    }else if ([minutesResulst doubleValue]>=8.0){
        timeScore=20;
    }else if ([minutesResulst doubleValue]>=10.0){
        timeScore=0;
    }
    
    // Calculate StateScore
    if ([self.lastStateResults isEqualToString:@"Estable"]==YES) {
        stateScore=100;
    }else{
        stateScore=0;
    }
    
    // Calculate Steps Score
    scoreCounter=scoreCounter*100/14;
    
    // Calculate Final Score
    finalScore=(0.334*stateScore)+(0.334*scoreCounter)+(0.334*timeScore);

    // Convert Int to String to Display
    self.scoreString= [NSString stringWithFormat:@"%d",finalScore];

    // Display Score Label
    self.scoreLabel.stringValue=self.scoreString;
    
    // Display Score Bar
    self.scoreBar.doubleValue=(double)finalScore;
    
}

// Lazy Initializations

- (NSDictionary *)bluetoothVariablesResults{
    if (!_bluetoothVariablesResults) {
        _bluetoothVariablesResults = [[NSDictionary alloc] init];
    }
    return _bluetoothVariablesResults;
}

- (NSMutableDictionary *)editableVariablesResults{
    if (!_editableVariablesResults) {
        _editableVariablesResults = [[NSMutableDictionary alloc] init];
    }
    return _editableVariablesResults;
}

@end
