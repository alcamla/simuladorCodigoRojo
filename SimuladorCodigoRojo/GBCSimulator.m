//
//  GBCSimulator.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/29/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import "GBCSimulator.h"
#import "GBCState.h"
#import "GBCStateMachine.h"
#import "GBCBluetoothManager.h"


@interface GBCSimulator ()

@property (strong,nonatomic) GBCState *stateObject;
@property (strong,nonatomic) GBCStateMachine *stateMachineObject;
@property (strong,nonatomic) NSDictionary *vitalSignsSimulator;
@property (strong,nonatomic) NSString *currentState;
@property (strong,nonatomic) NSMutableDictionary *bluetoothVariablesSimulator;
@property (strong, nonatomic) NSMutableArray *chronometerSimulator;
@property (strong, nonatomic) NSMutableDictionary *editedVariablesSimulator;
@property (strong, nonatomic) NSMutableDictionary *initialEditedVariablesSimulator;
@property (strong, nonatomic) NSMutableArray *editableInitialVariablesKeysSimulator;
@property (strong, nonatomic) NSMutableArray *editableInitialVariablesValuesSimulator;
@property (strong, nonatomic) NSMutableArray *bluetoothInitialKeysSimulator;
@property (strong, nonatomic) NSMutableArray *bluetoothInitialValuesSimulator;
@property (strong, nonatomic) NSString *editableVenousValue;
@property (strong, nonatomic) NSString *bluetoothVenousValue;
@property (strong, nonatomic) NSString *updatedKey;
@property (strong, nonatomic) NSString *updatedValue;



@end


@implementation GBCSimulator

// Local DataBase

bool bluetoothConnectionCheckSimulator = YES;
bool calibrationCheckSimulator = YES;
bool sensorsCheckSimulator= YES;
bool paussedChecked = NO;
bool finalizationCheck=NO;
bool startedInitializationMessage=NO;
bool updatedBoolean=NO;
bool syncViewState=NO;
bool orderToSetSyncActive=NO;
bool orderToSetPanelActive=NO;
bool panelViewStateSimulator=NO;

// Define as a Singleton and call Init when a GBCSimulator object is created by other classes

+ (instancetype)sharedSimulator
{
    static GBCSimulator *sharedSimulator = nil;
    // Do I need to create a sharedStore?
    if (!sharedSimulator) {
        sharedSimulator = [[self alloc] initPrivate];
    }
    return sharedSimulator;
}

// If a programmer calls [[GBCSimulator alloc] init], let him know the error of his ways

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[GBCSimultaror sharedSimulator]"
                                 userInfo:nil];
    return nil;
}

// Real Initializer for Simulator Objects

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
    }
    return self;
}

// Ask to State Class what are the Variables for Current State

- (NSDictionary *) getCurrentVitalSigns{
    
    // Update State, get The Vital Signs form State Object and send it to whoever
    // ask for those Values
    self.vitalSignsSimulator=[self.stateObject getVitalSignsForState:self.currentState];
    
    // Return vital signs
    return self.vitalSignsSimulator;
}

// Receive Selected State From Menu Controller

- (void) stateSelectedIs: (NSString *)stateReceived{
    
    //NSLog(@"Estado Seleccionado Enviado a Simulator");
    self.currentState=stateReceived;
    [self.bluetoothManager sendCurrentSimulationState:self.currentState];
}

// Method to send to Machine Class the initial State

- (NSString *) sendInitialStateSelected{

    return self.currentState;
}

// Method to send to State Vital Signs Class the current State

- (NSString *) sendCurrentState {
    
    return self.currentState;
}

// Method to receive updated State every Second From StateMachine

- (void) receiveCurrentState: (NSString *)currentStateFromMachine{
    
    self.currentState=currentStateFromMachine;
    
    // Send the new State to Muñeca
    [self.bluetoothManager sendCurrentSimulationState:self.currentState];
}

// Other Class ask to me if bluetooth is connected

- (BOOL) askIfBluetoothIsConnected{
    
    //NSLog(@"Ask if bluetooth is connected..");
    
    return bluetoothConnectionCheckSimulator;
    
}

// Ask to bluetooth class to make a bluetooth connection
    
- (void)createBluetoothObject{

    //NSLog(@"Bluetooth object created");
    if (!_bluetoothManager) {
        self.bluetoothManager =  [[GBCBluetoothManager alloc] init];
        self.bluetoothManager.delegate = self;
    }
    [self.bluetoothManager startScan];
}

-(void)forgetBluetoothDevice{
    //Check if there is a current connection. If there is, end it
    if ([self.bluetoothManager peripheral]) {
        [[self.bluetoothManager manager] cancelPeripheralConnection:[self.bluetoothManager peripheral]];
        self.bluetoothManager = nil;
    }
    //Delete the Device from User Defaults
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"GBCBluetoothDeviceIdentifier"];
}


// Method to ask to bluetooth class if calibration is ready

- (BOOL)isCalibrationReady{
    
    //NSLog(@"Ask if calibration is ready");

    return calibrationCheckSimulator;
}

// Method to ask to bluetooth class if sensors are ready

- (BOOL)areSensorsReady{
    
    //NSLog(@"Ask if sensors are ready");
    sensorsCheckSimulator=YES;
    
    return sensorsCheckSimulator;
}

// Method to return to View controllers bluetooth variables

- (NSDictionary *) getBluetoothVariables{
    
    //NSLog(@"Getting Bluetooth Variables from Simulator..");
    return self.bluetoothVariablesSimulator;
}

// Get Chronometer Value from Monitor View Controller Class

- (void) getChronometerValue:(NSMutableArray *)chronometer{
    
    //NSLog(@"Chronometer Value Recibed from Monitor Class");
    
    // Assing Local Chronometer to Incoming Chorometer
    self.chronometerSimulator=chronometer;

}

// Method to send state to Statemachine the current value of the chronometer

- (NSMutableArray *) sendChronometerValue{
    
    return self.chronometerSimulator;
}

// Method to receive the started of the Simulation message

- (void) receiveStartedInitializationMessage{
    startedInitializationMessage=YES;
    if (startedInitializationMessage==YES) {
        [self simulationHasFinished];
    }
}

// Method to Reset the Variables Allocated In This Module, whose are asked by some Classes

- (void) simulationHasFinished{
    
    finalizationCheck=NO;
    paussedChecked=NO;
    panelViewStateSimulator=NO;
    syncViewState=NO;
    self.editedVariablesSimulator=self.initialEditedVariablesSimulator;
    
}

// Method to receive the finalization of the Simulation message

- (void) receiveFinalizationMessage{

    //NSLog(@"Finalization Message Received");
    //[self.bluetoothManager sendFinishMessage];
    finalizationCheck=YES;

}

// Send finalization message to View Controllers

- (BOOL) sentFinalizationMessageFromSimulator{

    return finalizationCheck;
}

// Get edited variables from Panel view controller

- (void) getEditedVariablesValues:(NSMutableDictionary *) editedVariablesDictionaryFromPanel{
    
    // Receive dictionary from Panel View
    self.editedVariablesSimulator=editedVariablesDictionaryFromPanel;
    
    // Modify Read/Write Variables
    [self modifyReadWriteVariables];
    
}

// Send Editable Variables to other classes

- (NSMutableDictionary *) sendEditableVariables{
    
    return self.editedVariablesSimulator;
}

// Modify read-write Variables whose were just sent from Panel View Controller

- (void) modifyReadWriteVariables{
    
    // Get the value which was just modified in Panel View Controller
    self.editableVenousValue=[self.editedVariablesSimulator objectForKey:@"Vías Venosas"];
    self.bluetoothVenousValue=[self.bluetoothVariablesSimulator objectForKey:@"Vías Venosas"];
    
    // Check if the value has changed
    if (self.editableVenousValue!=self.bluetoothVenousValue) {
        
        // Set the new value of that key to the bluetooth dictionary
        [self.bluetoothVariablesSimulator setValue:self.editableVenousValue forKey:@"Vías Venosas"];
        
        BOOL newState = NO;
        if ([self.editableVenousValue isEqualToString:@"Yes"]) {
            newState = YES;
        }
        
        // Send the new State to Muñeca
        [self.bluetoothManager sendCurrentStateOfVariable:@"Vías Venosas" state:newState];
        
    }
    
}

// Get message from Panel to know that Simulation has been paussed and return it to whoever needs it

- (void) receivePausedOrNotMessage: (BOOL) pausedOrNotMessage{

    paussedChecked=pausedOrNotMessage;
    
}

// Tell View Controllers to Pause the Chronometer

- (BOOL) sendPausedOrNotMessage{

    return paussedChecked;
}

// Method to Receive the message about started Choronometer from Monitor View Controller

- (void) receiveStartedChronometerMessage{
    
    // Initialize StartMachineObject method called: Timer, to Start Asking for Variables Values from that class and Calculating the Current State
    [self.stateMachineObject initializeMachineTimer];
    
}

# pragma mark - GBCBluetoothManagerDelegate protocol conformance

// Method to verify if there was a connection

-(void)redCodeSensorsConnectionEstablishedByBluetoothManager:(GBCBluetoothManager *)bluetoothManager{
    
    bluetoothConnectionCheckSimulator=YES;
    
}

// Method to verify if there was a connection lost

-(void)redCodeSensorsConnectionLostByBluetoothManager:(GBCBluetoothManager *)bluetoothManager{

    bluetoothConnectionCheckSimulator=NO;

}

// Method to receive new updated variables

-(void)redCodeBluetoothManager:(GBCBluetoothManager*)bluetoothManager didUpdateVariable:(NSString*)variable toState:(BOOL)state{
    
    // Recibing values to local variables
    self.updatedKey=variable;
    updatedBoolean=state;
    
    // Check entring values from bluetooth class
    if (updatedBoolean==YES) {
        self.updatedValue=@"Yes";
    }else{
        self.updatedValue=@"No";
    }
    //The value is updated in the dictionary 
    [self.bluetoothVariablesSimulator setValue:self.updatedValue forKey:self.updatedKey];
}

// Method to check if calibration is ready or not

-(void)redCodeSensorsCheckedByBluetoothManager:(GBCBluetoothManager *)bluetoothManager result:(BOOL)result{
    if (result) {
         calibrationCheckSimulator = YES;
    } else {
         calibrationCheckSimulator = NO;
    }
}

# pragma mark - Only One Window Opened and Active Messages

// Method where Menu View Controller asks me if there's already an opened Sync View and I listen the Sync Active Status from View Controllers

-(BOOL) askIfSyncViewIsOpenedAndSetActive: (BOOL) SyncActiveMessage{
    
    // Receive click message from Menu
    orderToSetSyncActive = SyncActiveMessage;
    
    return syncViewState;
}

// Method where Sync View Controller tells Simulator if there's already an open window

- (void) isSyncViewOpened:(BOOL)isSyncOpenedMessage {
    
    syncViewState=isSyncOpenedMessage;
}

// Tell to Sync View Controller to set its self as Active

- (BOOL) makeActiveToSync{

    return orderToSetSyncActive;
}

// Method where Monitor View Controller asks me if there's already an opened Panel View and I listen the Panel Active Status from View Controllers

- (BOOL) askIfPanelViewIsOpenedAndSetActive: (BOOL) panelActiveMessage {

    // Receive click message from Monitor
    orderToSetPanelActive= panelActiveMessage;
    
    return panelViewStateSimulator;
}

// Method where Panel View Controller tells Simulator if there's already an open window

- (void) isPanelViewOpened:(BOOL)isPanelOpenedMessage {
    
    panelViewStateSimulator=isPanelOpenedMessage;
}

// Tell to Panel View Controller to set its self as Active

- (BOOL) makeActiveToPanel{
    
    return orderToSetPanelActive;
}

# pragma mark - Lazy Initializers

- (NSMutableArray *)chronometerSimulator{
    if (!_chronometerSimulator) {
        _chronometerSimulator = [[NSMutableArray alloc] init];
    }
    return _chronometerSimulator;
}

//Create a Provitional Dictionary for edited variables

- (NSMutableDictionary *)editedVariablesSimulator{
    
    if (!_editedVariablesSimulator) {
        
        _editedVariablesSimulator = [[NSMutableDictionary alloc] initWithObjects:self.editableInitialVariablesValuesSimulator forKeys: self.editableInitialVariablesKeysSimulator];
    }
    return _editedVariablesSimulator;
}

// Create the initial dictionary for edited variables
    
- (NSMutableDictionary *)initialEditedVariablesSimulator{
        
    if (!_editedVariablesSimulator) {
            
        _editedVariablesSimulator = [[NSMutableDictionary alloc] initWithObjects:self.editableInitialVariablesValuesSimulator forKeys: self.editableInitialVariablesKeysSimulator];
    }
    return _initialEditedVariablesSimulator;
}

//Create a Provitional Dictionary for bluetooth variables

- (NSMutableDictionary *) bluetoothVariablesSimulator{
    
    if (!_bluetoothVariablesSimulator) {
        
        _bluetoothVariablesSimulator= [[NSMutableDictionary alloc] initWithObjects:self.bluetoothInitialValuesSimulator forKeys:self.bluetoothInitialKeysSimulator];
    }
    
    return _bluetoothVariablesSimulator;
}
    
- (NSDictionary *)vitalSignsSimulator{
    if (!_vitalSignsSimulator) {
        _vitalSignsSimulator = [[NSDictionary alloc] init];
    }
    return _vitalSignsSimulator;
}

- (GBCState *)stateObject{
    if (!_stateObject) {
        _stateObject = [[GBCState alloc] init];
    }
    return _stateObject;
}

- (GBCStateMachine *)stateMachineObject{
    if (!_stateMachineObject) {
        _stateMachineObject = [[GBCStateMachine alloc] init];
    }
    return _stateMachineObject;
}

- (NSMutableArray *)editableInitialVariablesKeysSimulator{
    if (!_editableInitialVariablesKeysSimulator) {
        _editableInitialVariablesKeysSimulator = [[NSMutableArray alloc] initWithObjects:@"Sangrado Observado",@"Diagnóstico",@"Medicamentos Aplicados",@"Cristaloides",@"Anotación de Eventos",@"Vías Venosas",@"Ordenes de Laboratorio",@"Calentar Líquidos",@"Marcar Tubos",nil];
    }
    return _editableInitialVariablesKeysSimulator;
}

- (NSMutableArray *)editableInitialVariablesValuesSimulator{
    if (!_editableInitialVariablesValuesSimulator) {
        _editableInitialVariablesValuesSimulator = [[NSMutableArray alloc] initWithObjects:@"No", @"No", @"No", @"No", @"No", @"No", @"No", @"No", @"No", nil];
    }
    return _editableInitialVariablesValuesSimulator;
}

- (NSMutableArray *)bluetoothInitialKeysSimulator{
    if (!_bluetoothInitialKeysSimulator) {
        _bluetoothInitialKeysSimulator = [[NSMutableArray alloc] initWithObjects:@"Masaje",@"Oxígeno",@"Sonda Urinaria",@"Manta",@"Medición de Signos",@"Vías Venosas",nil];
    }
    return _bluetoothInitialKeysSimulator;
}

- (NSMutableArray *)bluetoothInitialValuesSimulator{
    if (!_bluetoothInitialValuesSimulator) {
        _bluetoothInitialValuesSimulator = [[NSMutableArray alloc] initWithObjects:@"No", @"No", @"No", @"No", @"No",@"No", nil];
    }
    return _bluetoothInitialValuesSimulator;
}

@end

