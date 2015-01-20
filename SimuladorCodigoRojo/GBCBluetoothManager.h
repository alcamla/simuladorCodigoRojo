//
//  GBCBluetoothManager.h
//  HeartRateMonitor
//
//  Created by camacholaverde on 1/15/15.
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

@protocol GBCRedCodeBluetoothDelegate;

@interface GBCBluetoothManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    
    IBOutlet NSButton* connectButton;
    BOOL autoConnect;
    
    // Progress Indicator
    IBOutlet NSButton * indicatorButton;
    IBOutlet NSProgressIndicator *progressIndicator;
}

@property (nonatomic, weak) IBOutlet NSWindow *scanSheet;
@property (nonatomic, weak) IBOutlet NSWindow *window;
@property (nonatomic,weak) IBOutlet NSArrayController *arrayController;
@property (nonatomic, strong) NSMutableArray *heartRateMonitors;
@property (copy) NSString *manufacturer;
@property (copy) NSString *connected;
@property (nonatomic, strong)id <GBCRedCodeBluetoothDelegate> delegate;

- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;
- (void) sendCurrentSimulationState:(NSString *)simulationState;
- (void) sendCurrentStateOfVariable:(NSString*)variable state:(BOOL)state;

@end


@protocol GBCRedCodeBluetoothDelegate <NSObject>
-(void)redCodeBluetoothManager:(GBCBluetoothManager*)bluetoothManager didUpdateVariable:(NSString*)variable toState:(BOOL)state;
-(void)redCodeSensorsConnectionEstablishedByBluetoothManager:(GBCBluetoothManager *)bluetoothManager;
-(void)redCodeSensorsConnectionLostByBluetoothManager:(GBCBluetoothManager *)bluetoothManager;
-(void)redCodeSensorsCheckedByBluetoothManager:(GBCBluetoothManager *)bluetoothManager result:(BOOL)result;
@end