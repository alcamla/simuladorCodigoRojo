//  GBCMenuViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/19/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import "GBCMenuViewController.h"
#import "GBCSimulator.h"


@interface GBCMenuViewController ()

@property (strong) IBOutlet NSButton *goToConfirmProperty;
@property (strong) IBOutlet NSButton *goToSyncProperty;
@property (strong,nonatomic) NSTimer *timerToUpdateMenuView;

@end

@implementation GBCMenuViewController

bool bluetoothConnectionCheckMenu=NO;
bool sensorsReadyCheckMenu=NO;
bool calibrationReadyCheckMenu=NO;
bool syncViewIsOpened=NO;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Initialize the timer to update view
    [self initializeMenuTimer];
    
    // Load in view initial and correct values
    [self updateMenuView];
    
}

- (void)viewDidDisappear{
    
    // Stop Timer
    [self stopTimer];

}

// Method to Go to Confirm View, Close the Current Menu View and Send State to Main Class: Simulator

- (IBAction)goToConfirm:(id)sender {
    
        // Send Starting Message to Simulator
        [self sendStartedMessage];
        
        // Stop Timer
        [self stopTimer];

        // Hide Current Window
        [self.view.window setIsVisible:NO];
    
        // Send Notification to Sync View Controller Class to finish its process
    
         NSNotification *notification = [NSNotification notificationWithName:@"endSyncWindow" object:self];
         [[NSNotificationCenter defaultCenter] postNotification:notification];

        // Call Segue to go to next view controller
        [self performSegueWithIdentifier:@"fromMenuToConfirm" sender:(id)sender];
   
}

// Method to stop the timer

- (void) stopTimer{
    
    [self.timerToUpdateMenuView invalidate];
    self.timerToUpdateMenuView = nil;

}

// Method to Send Started Message to Main Class: Simulator

- (void) sendStartedMessage{
    
    [[GBCSimulator sharedSimulator] receiveStartedInitializationMessage];
   

}

// Button action to go to the Sync View Controller

- (IBAction)goToSync:(id)sender {
    
    //Ask if there is an stored device for autoconnect
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults removeObjectForKey:@"GBCBluetoothDeviceIdentifier"];
    NSString  *deviceID = [defaults stringForKey:@"GBCBluetoothDeviceIdentifier"];
    if (!deviceID){
        //No stored device, open the selector
        [self performSegueWithIdentifier:@"goToBluetoothSelector" sender:self];
    } else{
        // Ask to simulator is Sync View Is Already Opened (Active)
        syncViewIsOpened=[[GBCSimulator sharedSimulator] askIfSyncViewIsOpenedAndSetActive:YES];
        
        // Perform segue if should
        if (syncViewIsOpened==NO) {
            
            // Call Segue to go to next view controller
            [self performSegueWithIdentifier:@"fromMenuToSync" sender:(id)sender];
        }
    }
}

-(void)navigateToSynchronizeViewControllerFromRedCodeBluetoothManager:(GBCBluetoothManager *)bluetoothManager{
    [self performSegueWithIdentifier:@"fromMenuToSync" sender:self];
}

- (IBAction)testModalViewPresentation:(id)sender {
    //Check if there is a bluetooth device set in the userPreferences. If there isn't, prompt the user to set a bluetooth device.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults removeObjectForKey:@"GBCBluetoothDeviceIdentifier"];
    NSString  *deviceID = [defaults stringForKey:@"GBCBluetoothDeviceIdentifier"];
    if (!deviceID) {
        [self performSegueWithIdentifier:@"goToBluetoothSelector" sender:self];
    }

}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString: @"goToBluetoothSelector"]) {
        [(GBCBluetoothManager*)segue.destinationController setPresenter:self];
        [(GBCBluetoothManager*)segue.destinationController setDelegate:[GBCSimulator sharedSimulator]];
        [[GBCSimulator sharedSimulator]setBluetoothManager:(GBCBluetoothManager*)segue.destinationController];
    } else if ([segue.identifier isEqualToString:@"fromMenuToSync"] ){
    
    }
}

// Initialize timer to update the Menu View

- (void) initializeMenuTimer{
        
    // Describing a timer which allows us to update the Menu View every 1s
    self.timerToUpdateMenuView=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                                selector:@selector(updateMenuView)
                                                                userInfo:nil
                                                                repeats:YES];

}

// Update Menu View with interrupts from a timer

- (void) updateMenuView{
    
    // Ask to Main Class:Simulator for bluetooth state connection
    
    bluetoothConnectionCheckMenu=[[GBCSimulator sharedSimulator] askIfBluetoothIsConnected];
    
    // Ask to Main Class:Simulator if Calibration is ready
    calibrationReadyCheckMenu=[[GBCSimulator sharedSimulator] isCalibrationReady];
    
    // Ask to Main Class:Simulator if sensors are ready
    sensorsReadyCheckMenu=[[GBCSimulator sharedSimulator] areSensorsReady];
    
    // Check Simulator Answers to enable or not enable the user to continue the application
    if (bluetoothConnectionCheckMenu==YES) {
        
        if (calibrationReadyCheckMenu==YES) {
            
            if (sensorsReadyCheckMenu==YES) {
                
                self.goToConfirmProperty.enabled=YES;
                self.goToSyncProperty.enabled=NO;
            }
        }
    }
    else
    {
        self.goToConfirmProperty.enabled=NO;
        self.goToSyncProperty.enabled=YES;
    
    }
    
    //NSLog(@" Timer Menu");

}


// Lazy Initializations

- (NSTimer *)timerToUpdateMenuView{
    if (!_timerToUpdateMenuView) {
        _timerToUpdateMenuView = [[NSTimer alloc] init];
    }
    return _timerToUpdateMenuView;
}
@end



