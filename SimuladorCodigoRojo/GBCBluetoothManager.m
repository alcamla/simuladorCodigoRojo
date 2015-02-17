//
//  GBCBluetoothManager.m
//  HeartRateMonitor
//
//  Created by camacholaverde on 1/15/15.
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import "GBCBluetoothManager.h"
#import <QuartzCore/QuartzCore.h>
#import "GBCBluetoothSelectorSheetController.h"

@interface GBCBluetoothManager()
@property(nonatomic, strong)CBCharacteristic *writeCharacteristic;
@property(nonatomic, strong) NSMutableString *readDataBuffer;
@property(nonatomic, strong)NSTimer *reconnectingTimer;
@property (nonatomic,weak) IBOutlet NSArrayController *arrayController;
@property(nonatomic, strong) NSMutableArray *redCodeBluetoothDevices;
@end

@implementation GBCBluetoothManager

#define RED_CODE_SERVICE_UUID_STRING @"EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F"
#define GENERIC_ACCESS_SERVICE_UUID_STRING @"00001800-0000-1000-8000-00805F9B34FB"
#define RED_CODE_READ_CHARACTERISTIC_UUID_STRING @"A1E8F5B1-696B-4E4C-87C6-69DFE0B0093B"
#define RED_CODE_WRITE_CHARACTERISTIC_UUID_STRING @"1494440E-9A58-4CC0-81E4-DDEA7F74F623"


- (void) dealloc
{
    /*Disconnect the peripheral when dealloc*/
    if (_peripheral) {
        [self.manager cancelPeripheralConnection:_peripheral];
    }
    [self stopScan];
}


-(void)viewDidAppear{
    [self startScan];
}

#pragma mark - Lazy Initializers

-(NSMutableString *)readDataBuffer{
    if (!_readDataBuffer) {
        _readDataBuffer = [NSMutableString stringWithCapacity:2];
    }
    return _readDataBuffer;
}

-(BOOL)autoConnect{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults  stringForKey:@"GBCBluetoothDeviceIdentifier"]) {
        _autoConnect = TRUE;
    } else{
        _autoConnect = FALSE;
        [self performSegueWithIdentifier:@"goToBluetoothSelector" sender:self];
    }
    return _autoConnect;
}

-(CBCentralManager*)manager{
    if (!_manager) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _manager;
}

-(NSMutableArray*)redCodeBluetoothDevices{
    if (!_redCodeBluetoothDevices) {
        _redCodeBluetoothDevices = [NSMutableArray array];
    }
    return _redCodeBluetoothDevices;
}


#pragma mark - User Interactions

- (IBAction)closeSheet:(id)sender {
    [self stopScan];
    [self dismissViewController:self];
}

- (IBAction)selectDevice:(id)sender {
    [(NSButton*)sender setTitle:@"Connecting"];
    [self stopScan];
    NSIndexSet *indexes = [self.arrayController selectionIndexes];
    if ([indexes count] != 0)
    {
        NSIndexSet *indexes = [self.arrayController selectionIndexes];
        if ([indexes count] != 0)
        {
            NSUInteger anIndex = [indexes firstIndex];
            _peripheral = [self.redCodeBluetoothDevices objectAtIndex:anIndex];
            [indicatorButton setHidden:FALSE];
            [progressIndicator setHidden:FALSE];
            [progressIndicator startAnimation:self];
            [self.manager connectPeripheral:_peripheral options:nil];
        }
    }
}

#pragma mark - Bluetooth Timed connection Failure

/*
 Called when the connection to selected device fails
 */
-(void)bluetoothFailedConnectionToSelectedDevice{
    if (!_peripheral) {
        [self stopScan];
        [self.delegate redCodeSensorsConnectionLostByBluetoothManager:self];
    }
}

#pragma mark - Connect Button

/*
 This method is called when connect button pressed and it takes appropriate actions depending on device connection state
 */
- (IBAction)connectButtonPressed:(id)sender
{
    if(_peripheral && ([_peripheral state] == CBPeripheralStateConnected))
    {
        /* Disconnect if it's already connected */
        [self.manager cancelPeripheralConnection:_peripheral];
    }
    else if (_peripheral)
    {
        /* Device is not connected, cancel pendig connection */
        [indicatorButton setHidden:TRUE];
        [progressIndicator setHidden:TRUE];
        [progressIndicator stopAnimation:self];
        [self.manager cancelPeripheralConnection:_peripheral];
    }
    else
    {   /* No outstanding connection, open scan sheet */
    }
}


#pragma mark  - Red Code Data Handling

-(void)readRedCodeData:(NSData *)data
{
    NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
    /*Append to the data string */
    if (newStr) {
        [self.readDataBuffer appendString:newStr];
        NSLog(@"Received Data: %@", newStr);
        NSLog(@"Buffer initial State: %@", self.readDataBuffer);
        /*find if a termination character is found in the composed string*/
        
        while (TRUE) {
            NSRange aRange = [self.readDataBuffer rangeOfString:@","];
            if (aRange.location != NSNotFound) {
                NSString *dataToSend = [self.readDataBuffer substringToIndex:aRange.location];
                //Find a * in dataToSend, start the dataToSend from the character following the *
                 NSRange subRange = [self.readDataBuffer rangeOfString:@"*"];
                if (subRange.location != NSNotFound) {
                    if ([dataToSend length] != 3) {
                        NSLog(@"THERE IS DATA MISSING IN THE STRING!!! : %@", dataToSend);
                        dataToSend = [dataToSend substringFromIndex: subRange.location +1];
                    } else{
                        [self sendData:dataToSend];
                        NSLog(@"Sent data: %@", dataToSend);
                    }
                }
                [self.readDataBuffer deleteCharactersInRange:NSMakeRange(0, aRange.location+1)];
                NSLog(@"Buffer Final State: %@", self.readDataBuffer);
            } else{
                break;
            }
        }
    }
}

-(void)sendData:(NSString*)dataString{
    unichar aChar;
    NSMutableArray *charactersArray = [NSMutableArray new];
    NSString *characterAsString;
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9]" options:NSRegularExpressionCaseInsensitive error:&error];
    for (int i =0; i < [dataString length]; i++) {
        aChar = [dataString characterAtIndex:i];
        characterAsString =[NSString stringWithCharacters:&aChar length:1];
        NSInteger appearences = [regex numberOfMatchesInString:characterAsString options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [characterAsString length])];
        if (appearences == 0) {
            [charactersArray addObject:[NSString stringWithCharacters:&aChar length:1]];
        }
    }
    NSString *variableName =@"";
    BOOL isSensorData = YES;
    if ([charactersArray[0] isEqualToString:@"a"]) {
        variableName = @"Vías Venosas";
    } else if ([charactersArray[0] isEqualToString:@"b"]){
        variableName = @"Masaje";
    }else if ([charactersArray[0] isEqualToString:@"c"]){
        variableName = @"Manta";
    }else if ([charactersArray[0] isEqualToString:@"d"]){
        variableName = @"Oxígeno";
    }else if ([charactersArray[0] isEqualToString:@"e"]){
        variableName = @"Sonda Urinaria";
    }else if ([charactersArray[0] isEqualToString:@"f"]){
        variableName = @"Medición de Signos";
    } else if ([charactersArray[0] isEqualToString:@"g"]){
        isSensorData = NO;
        [self.delegate redCodeSensorsCheckedByBluetoothManager:self result:[charactersArray[1] boolValue]];
    }
    
    if (isSensorData) {
        BOOL newState = [charactersArray[1] boolValue];
        NSLog(@"%@: %@", variableName, [NSNumber numberWithBool:newState]);
        [self.delegate redCodeBluetoothManager:self didUpdateVariable:variableName toState:newState];
    }
}

- (void) sendCurrentSimulationState:(NSString *)simulationState{
    NSString *simulationStateDataString;
    if ([simulationState isEqualToString:@"Postparto"] ||
        [simulationState isEqualToString:@"Transitorio Leve"]) {
        simulationStateDataString = @"*h0,";
    }
    else if ([simulationState isEqualToString:@"Choque Leve"]){
        simulationStateDataString = @"*h1,";
    } else if ([simulationState isEqualToString:@"Choque Moderado"]){
        simulationStateDataString = @"*h2,";
    } else if ([simulationState isEqualToString:@"Choque Grave"]){
        simulationStateDataString = @"*h3,";
    } else if ([simulationState isEqualToString:@"Estable"]){
        simulationStateDataString = @"*h4,";
    }
    [self sendStringToConnectedPeripheric:simulationStateDataString];
}

-(void)sendCurrentStateOfVariable:(NSString *)variable state:(BOOL)state{
    NSString *variableStateString =@"";
    if ([variable isEqualToString:@"Vías Venosas"]) {
        variableStateString = @"*a";
    } else if ([variable isEqualToString:@"Masaje"]){
        variableStateString = @"*b";
    } else if ([variable isEqualToString:@"Manta"]){
        variableStateString = @"*c";
    } else if ([variable isEqualToString:@"Oxígeno"]){
        variableStateString = @"*d";
    } else if ([variable isEqualToString:@"Sonda Urinaria"]){
        variableStateString = @"*e";
    } else if (@"Medición de Signos"){
        variableStateString = @"*f";
    }
    variableStateString = [variableStateString stringByAppendingString:[[NSNumber numberWithBool:state] stringValue]];
    variableStateString = [variableStateString stringByAppendingString:@","];
    [self sendStringToConnectedPeripheric:variableStateString];    
}

-(void)sendFinishMessage{
    NSString *finishString =@"";
    finishString=@"*z";
    finishString = [finishString stringByAppendingString:@","];
    [self sendStringToConnectedPeripheric:finishString];
}


#pragma mark - Start/Stop Scan methods

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([self.manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:state];
    [alert addButtonWithTitle:@"OK"];
    [alert setIcon:[[NSImage alloc] initWithContentsOfFile:@"AppIcon"]];
    //[alert beginSheetModalForWindow:[self window] completionHandler:nil];
    return FALSE;
}

/*
 Request CBCentralManager to scan for heart rate peripherals using service UUID 0x180D
 */
- (void) startScan
{
    NSArray * services = @[[CBUUID UUIDWithString:RED_CODE_SERVICE_UUID_STRING]];
    [self.manager scanForPeripheralsWithServices:services
                                    options:nil];
    if (self.autoConnect) {
        self.reconnectingTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(bluetoothFailedConnectionToSelectedDevice) userInfo:nil repeats:NO];
        
    }
    NSLog(@"Started scanning for devices");
}

/*
 Request CBCentralManager to stop scanning for heart rate peripherals
 */
- (void) stopScan
{
    [self.manager stopScan];
}

#pragma mark - CBCentralManager delegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
}

/*
 Invoked when the central discovers heart rate peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{    
    //NSMutableArray *peripherals = [self mutableArrayValueForKey:@"redCodeBluetoothDevices"];
    NSMutableArray *peripherals =  [self mutableArrayValueForKey:@"redCodeBluetoothDevices"];
    
    if (![self.redCodeBluetoothDevices containsObject:aPeripheral]) {
        [peripherals addObject:aPeripheral];
    }
    
    
    /* Retreive already known devices */
    if(self.autoConnect)
    {
        ///[manager retrievePeripheralsWithIdentifiers:@[(id)aPeripheral.identifier]];
        //TODO: cambiar cuando se conecte al prototipo final (BLUETOOTH_DEVICE_2_UUID_STRING) prototipos de pruebas:(BLUETOOTH_DEVICE_1_UUID_STRING)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *deviceIdentifier = [defaults stringForKey:@"GBCBluetoothDeviceIdentifier"];
        if ([[aPeripheral.identifier UUIDString] isEqualToString:deviceIdentifier]) {
            _peripheral = aPeripheral;
            [self.manager connectPeripheral:_peripheral options:nil];
            [self stopScan];
        }
    }
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
    
    [self stopScan];
    
    /* If there are any known devices, automatically connect to it.*/
    if([peripherals count] >=1)
    {
        [indicatorButton setHidden:FALSE];
        [progressIndicator setHidden:FALSE];
        [progressIndicator startAnimation:self];
        _peripheral = [peripherals objectAtIndex:0];
        [self.manager connectPeripheral:_peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    
    self.connected = @"Connected";
    [indicatorButton setHidden:TRUE];
    [progressIndicator setHidden:TRUE];
    [progressIndicator stopAnimation:self];
    [self.delegate redCodeSensorsConnectionEstablishedByBluetoothManager:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Check if this is the first time the app connects to the device
    if (![[defaults stringForKey:@"GBCBluetoothDeviceIdentifier"] isEqualToString:[aPeripheral.identifier UUIDString]]) {
        //Update the device identifier
        [defaults setObject:[aPeripheral.identifier UUIDString] forKey:@"GBCBluetoothDeviceIdentifier"];
        [self closeSheet:nil];
        //Go to synchronization view
        [self.presenter navigateToSynchronizeViewControllerFromRedCodeBluetoothManager:self];
        
    }
    
    
    
    
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    self.connected = @"Not connected";
    self.manufacturer = @"";
    if( _peripheral )
    {
        [_peripheral setDelegate:nil];
        _peripheral = nil;
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    if( _peripheral )
    {
        [_peripheral setDelegate:nil];
        _peripheral = nil;
    }
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"Service found with UUID: %@", [aService.UUID UUIDString]);
        
        /*Transmission and Reception Service for BlueGiGa */
        if([aService.UUID isEqual:[CBUUID UUIDWithString:RED_CODE_SERVICE_UUID_STRING]]){
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        /* Device Information Service */
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    /*Characteristics of Red Code device Service */
    if ([service.UUID isEqual:[CBUUID UUIDWithString:RED_CODE_SERVICE_UUID_STRING]]) {
        NSEnumerator *e = [service.characteristics objectEnumerator];
        CBCharacteristic *aChar;
        while (aChar = [e nextObject]) {
            
            /*Characteristic to write to  */
            if ([[[aChar UUID] UUIDString] isEqualToString:RED_CODE_WRITE_CHARACTERISTIC_UUID_STRING]){
                self.writeCharacteristic = aChar;
                NSLog(@"Found a write Characteristic to write to");
                [self sendCalibrationFlagToConnectedPeripheric];
            }
            /* Set notification on data measurement */
            if ([[[aChar UUID] UUIDString] isEqualToString:RED_CODE_READ_CHARACTERISTIC_UUID_STRING]) {
                [_peripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found a Measurement Characteristic to read from");
            }
        }
    }
    
    /*Device info Service */
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* Read manufacturer name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    /*Updated value for red code measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:RED_CODE_READ_CHARACTERISTIC_UUID_STRING]]) {
        if (characteristic.value || !error) {
            [self readRedCodeData:characteristic.value];
        }
    }
    
    /* Value for manufacturer name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
    {
        self.manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Manufacturer Name = %@", self.manufacturer);
    }
}

-(void)sendCalibrationFlagToConnectedPeripheric{
    [self sendStringToConnectedPeripheric:@"*start,"];
}

-(void) sendStringToConnectedPeripheric:(NSString *)stringToSend{
    if (_peripheral) {
        NSData *startingFlagAsData = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
        [_peripheral writeValue:startingFlagAsData forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    
}

@end



