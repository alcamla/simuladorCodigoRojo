//
//  GBCBluetoothManager.m
//  HeartRateMonitor
//
//  Created by camacholaverde on 1/15/15.
//  Copyright (c) 2015 GIBIC Inc. All rights reserved.
//
//

#import "GBCBluetoothManager.h"
#import <QuartzCore/QuartzCore.h>

@interface GBCBluetoothManager()
@property(nonatomic, strong)CBCharacteristic *writeCharacteristic;
@property(nonatomic, strong) NSMutableString *readDataBuffer;
@property(nonatomic, strong)NSTimer *reconnectingTimer;

@end

@implementation GBCBluetoothManager

#define BLUETOOTH_DEVICE_1_UUID_STRING @"E9657654-2E39-4E16-B843-94FC5354A1C0"
#define BLUETOOTH_DEVICE_2_UUID_STRING @"932CAF49-A991-4188-A5C3-C7767DDF6E85"
#define RED_CODE_SERVICE_UUID_STRING @"EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F"
#define GENERIC_ACCESS_SERVICE_UUID_STRING @"00001800-0000-1000-8000-00805F9B34FB"
#define RED_CODE_READ_CHARACTERISTIC_UUID_STRING @"A1E8F5B1-696B-4E4C-87C6-69DFE0B0093B"
#define RED_CODE_WRITE_CHARACTERISTIC_UUID_STRING @"1494440E-9A58-4CC0-81E4-DDEA7F74F623"

-(instancetype)init{
    if(self = [super init]){
        self.readDataBuffer = [NSMutableString stringWithCapacity:2];
        self.heartRateMonitors = [NSMutableArray array];
        autoConnect = TRUE;
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        if( autoConnect )
        {
            [self startScan];
            self.reconnectingTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(bluetoothFailedConnectionToSelectedDevice) userInfo:nil repeats:NO];
        }
    }
    return  self;
}

- (void) dealloc
{
    /*Disconnect the peripheral when dealloc*/
    if (peripheral) {
        [manager cancelPeripheralConnection:peripheral];
    }
    [self stopScan];
}

#pragma mark - Bluetooth Timed connection Failure

/*
 Called when the connection to selected device fails
 */
-(void)bluetoothFailedConnectionToSelectedDevice{
    if (!peripheral) {
        [self stopScan];
        [self.delegate redCodeSensorsConnectionLostByBluetoothManager:self];
    }
}


#pragma mark - Scan sheet methods

/*
 Open scan sheet to discover heart rate peripherals if it is LE capable hardware
 */
- (IBAction)openScanSheet:(id)sender
{
    if( [self isLECapableHardware] )
    {
        autoConnect = FALSE;
        [self.arrayController removeObjects:self.heartRateMonitors];
        [NSApp beginSheet:self.scanSheet modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
        [self startScan];
    }
}

/*
 Close scan sheet once device is selected
 */
- (IBAction)closeScanSheet:(id)sender
{
    [NSApp endSheet:self.scanSheet returnCode:NSAlertFirstButtonReturn];
    [self.scanSheet orderOut:self];
}

/*
 Close scan sheet without choosing any device
 */
- (IBAction)cancelScanSheet:(id)sender
{
    [NSApp endSheet:self.scanSheet returnCode:NSAlertFirstButtonReturn];
    [self.scanSheet orderOut:self];
}

/*
 This method is called when Scan sheet is closed. Initiate connection to selected heart rate peripheral
 */
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self stopScan];
    if( returnCode == NSAlertFirstButtonReturn )
    {
        NSIndexSet *indexes = [self.arrayController selectionIndexes];
        if ([indexes count] != 0)
        {
            NSUInteger anIndex = [indexes firstIndex];
            peripheral = [self.heartRateMonitors objectAtIndex:anIndex];
            [indicatorButton setHidden:FALSE];
            [progressIndicator setHidden:FALSE];
            [progressIndicator startAnimation:self];
            [connectButton setTitle:@"Cancel"];
            [manager connectPeripheral:peripheral options:nil];
        }
    }
}

#pragma mark - Connect Button

/*
 This method is called when connect button pressed and it takes appropriate actions depending on device connection state
 */
- (IBAction)connectButtonPressed:(id)sender
{
    if(peripheral && ([peripheral state] == CBPeripheralStateConnected))
    {
        /* Disconnect if it's already connected */
        [manager cancelPeripheralConnection:peripheral];
    }
    else if (peripheral)
    {
        /* Device is not connected, cancel pendig connection */
        [indicatorButton setHidden:TRUE];
        [progressIndicator setHidden:TRUE];
        [progressIndicator stopAnimation:self];
        [connectButton setTitle:@"Connect"];
        [manager cancelPeripheralConnection:peripheral];
        [self openScanSheet:nil];
    }
    else
    {   /* No outstanding connection, open scan sheet */
        [self openScanSheet:nil];
    }
}

#pragma mark  - Red Code Data Handling

-(void)readRedCodeData:(NSData *)data
{
    NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
    /*Append to the data string */
    [self.readDataBuffer appendString:newStr];
    //NSLog(@"Received Data: %@", newStr);
    //NSLog(@"Buffer initial State: %@", self.readDataBuffer);
    /*find if a termination character is found in the composed string*/
    
    while (TRUE) {
        NSRange aRange = [self.readDataBuffer rangeOfString:@","];
        if (aRange.location != NSNotFound) {
            NSString *dataToSend = [self.readDataBuffer substringToIndex:aRange.location];
            [self sendData:dataToSend];
            //NSLog(@"Sent data: %@", dataToSend);
            [self.readDataBuffer deleteCharactersInRange:NSMakeRange(0, aRange.location+1)];
            //NSLog(@"Buffer Final State: %@", self.readDataBuffer);
        } else{
            break;
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
        simulationStateDataString = @"h0,";
    }
    else if ([simulationState isEqualToString:@"Choque Leve"]){
        simulationStateDataString = @"h1,";
    } else if ([simulationState isEqualToString:@"Choque Moderado"]){
        simulationStateDataString = @"h2,";
    } else if ([simulationState isEqualToString:@"Choque Grave"]){
        simulationStateDataString = @"h3,";
    } else if ([simulationState isEqualToString:@"Estable"]){
        simulationStateDataString = @"h4,";
    }
    [self sendStringToConnectedPeripheric:simulationStateDataString];
}

-(void)sendCurrentStateOfVariable:(NSString *)variable state:(BOOL)state{
    NSString *variableStateString =@"";
    if ([variable isEqualToString:@"Vías Venosas"]) {
        variableStateString = @"a";
    } else if ([variable isEqualToString:@"Masaje"]){
        variableStateString = @"b";
    } else if ([variable isEqualToString:@"Manta"]){
        variableStateString = @"c";
    } else if ([variable isEqualToString:@"Oxígeno"]){
        variableStateString = @"d";
    } else if ([variable isEqualToString:@"Sonda Urinaria"]){
        variableStateString = @"e";
    } else if (@"Medición de Signos"){
        variableStateString = @"f";
    }
    variableStateString = [variableStateString stringByAppendingString:[[NSNumber numberWithBool:state] stringValue]];
    variableStateString = [variableStateString stringByAppendingString:@","];
    [self sendStringToConnectedPeripheric:variableStateString];    
}

#pragma mark - Start/Stop Scan methods

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
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
    
    [self cancelScanSheet:nil];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:state];
    [alert addButtonWithTitle:@"OK"];
    [alert setIcon:[[NSImage alloc] initWithContentsOfFile:@"AppIcon"]];
    [alert beginSheetModalForWindow:[self window] completionHandler:nil];
    return FALSE;
}

/*
 Request CBCentralManager to scan for heart rate peripherals using service UUID 0x180D
 */
- (void) startScan
{
    NSArray * services = @[[CBUUID UUIDWithString:RED_CODE_SERVICE_UUID_STRING]];
    [manager scanForPeripheralsWithServices:services
                                    options:nil];
}

/*
 Request CBCentralManager to stop scanning for heart rate peripherals
 */
- (void) stopScan
{
    [manager stopScan];
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
//    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"heartRateMonitors"];
//    if( ![self.heartRateMonitors containsObject:aPeripheral] )
//        [peripherals addObject:aPeripheral];
    
    /* Retreive already known devices */
    if(autoConnect)
    {
        ///[manager retrievePeripheralsWithIdentifiers:@[(id)aPeripheral.identifier]];
        //TODO: cambiar cuando se conecte al prototipo final (BLUETOOTH_DEVICE_2_UUID_STRING) prototipos de pruebas:(BLUETOOTH_DEVICE_1_UUID_STRING)
        if ([[aPeripheral.identifier UUIDString] isEqualToString:BLUETOOTH_DEVICE_2_UUID_STRING]) {
            peripheral = aPeripheral;
            [manager connectPeripheral:peripheral options:nil];
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
        peripheral = [peripherals objectAtIndex:0];
        [connectButton setTitle:@"Cancel"];
        [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
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
    [connectButton setTitle:@"Disconnect"];
    [indicatorButton setHidden:TRUE];
    [progressIndicator setHidden:TRUE];
    [progressIndicator stopAnimation:self];
    [self.delegate redCodeSensorsConnectionEstablishedByBluetoothManager:self];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    self.connected = @"Not connected";
    [connectButton setTitle:@"Connect"];
    self.manufacturer = @"";
    if( peripheral )
    {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    [connectButton setTitle:@"Connect"];
    if( peripheral )
    {
        [peripheral setDelegate:nil];
        peripheral = nil;
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
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
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
    [self sendStringToConnectedPeripheric:@"start,"];
}

-(void) sendStringToConnectedPeripheric:(NSString *)stringToSend{
    if (peripheral) {
        NSData *startingFlagAsData = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral writeValue:startingFlagAsData forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    
}

@end



