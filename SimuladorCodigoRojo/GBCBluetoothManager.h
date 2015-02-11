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


@class GBCBluetoothSelectorSheetController;
@protocol GBCRedCodeBluetoothDelegate;
@protocol GBCRedCodeBluetoothPresenterDelegate;

@interface GBCBluetoothManager : NSViewController <CBCentralManagerDelegate, CBPeripheralDelegate> {
    
    // Progress Indicator
    IBOutlet NSButton * indicatorButton;
    IBOutlet NSProgressIndicator *progressIndicator;
}

//@property (nonatomic, weak) IBOutlet NSWindow *scanSheet;
@property(nonatomic, strong)CBCentralManager *manager;
@property(nonatomic)BOOL autoConnect;
@property (copy) NSString *manufacturer;
@property (copy) NSString *connected;
@property(nonatomic, strong)CBPeripheral *peripheral;
@property (nonatomic, strong)id <GBCRedCodeBluetoothDelegate> delegate;
@property(nonatomic, strong)id <GBCRedCodeBluetoothPresenterDelegate> presenter;
@property (nonatomic, strong) GBCBluetoothSelectorSheetController *bluetoothSelectorViewController;

- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;
- (void) sendCurrentSimulationState:(NSString *)simulationState;
- (void) sendCurrentStateOfVariable:(NSString*)variable state:(BOOL)state;
- (void)sendFinishMessage;

@end


@protocol GBCRedCodeBluetoothDelegate <NSObject>
-(void)redCodeBluetoothManager:(GBCBluetoothManager*)bluetoothManager didUpdateVariable:(NSString*)variable toState:(BOOL)state;
-(void)redCodeSensorsConnectionEstablishedByBluetoothManager:(GBCBluetoothManager *)bluetoothManager;
-(void)redCodeSensorsConnectionLostByBluetoothManager:(GBCBluetoothManager *)bluetoothManager;
-(void)redCodeSensorsCheckedByBluetoothManager:(GBCBluetoothManager *)bluetoothManager result:(BOOL)result;
@end


@protocol GBCRedCodeBluetoothPresenterDelegate <NSObject>

-(void)navigateToSynchronizeViewControllerFromRedCodeBluetoothManager:(GBCBluetoothManager*)bluetoothManager;

@end