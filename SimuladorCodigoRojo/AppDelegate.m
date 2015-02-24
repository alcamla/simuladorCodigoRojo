//
//  AppDelegate.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/18/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import "AppDelegate.h"
#import "GBCMenuViewController.h"
#import "GBCMenuWindowController.h"
#import "GBCSimulator.h"



@interface AppDelegate ()

@property NSWindowController *menuController;
@property NSStoryboard *storyboard;
@property (weak) IBOutlet NSMenuItem *arterialPressureButton;
@property (weak) IBOutlet NSMenuItem *heartRateButton;
@property (weak) IBOutlet NSMenuItem *oxygenButton;
@property (weak) IBOutlet NSMenuItem *respiratoryRateButton;
@property (weak) IBOutlet NSMenuItem *conscienceButton;

@property(weak)IBOutlet NSMenu *monitor;

@end

@implementation AppDelegate



bool conscienceIsVisibleAppDelegate=NO;
bool heartRateIsVisibleAppDelegate=NO;
bool respiratoryRateIsVisibleAppDelegate=NO;
bool oxygenIsVisibleAppDelegate=NO;
bool arterialPressureIsVisibleAppDelegate=NO;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

// Close the app when the last window is closed

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSNotification *)aNotification {
    
    // When all windows are closed, i restart values
    [[GBCSimulator sharedSimulator] simulationHasFinished];
    
    return NO;
}

// When all windows are closed and the user try to open the app again, the app starts at menu window controller

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
    
    if (!flag){
        
        // Create a story board object
        self.storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Initialize the menu window controller object
        self.menuController = [self.storyboard instantiateInitialController];
        
        // Show the window
        [self.menuController showWindow:self];
        
    }
    //Reset the state of the menuItems of the Monitor Menu, making all variables invisible
    [self simulationDidFinish];
    
    return YES;
}

// Button to forget the bluetooth device identifier



- (IBAction)forgetCurrentBluetoothDevice:(id)sender {
    [[GBCSimulator sharedSimulator] forgetBluetoothDevice];
}

#pragma mark -
#pragma Monitory Variables Visibility Manipulation

-(IBAction)variableChangedState:(id)sender{
    NSMenuItem *item = (NSMenuItem *)sender;
    NSInteger tag = [(NSMenuItem*)sender tag];
    [item setState:!item.state];
    [[GBCSimulator sharedSimulator] monitoredVariableWithTag:tag changedVisibilityToState:[item state]];
}


-(void)simulationDidFinish{
    //Reset the state of the menuItems under the monitor Menu, indicating that all variables are invisible
    NSArray *variablesMenuItems = self.monitor.itemArray;
    NSMenuItem *variableItem;
    for (int i=0; i<[variablesMenuItems count]; i++) {
        variableItem = variablesMenuItems[i];
        [variableItem setState:0];
        [[GBCSimulator sharedSimulator] monitoredVariableWithTag:variableItem.tag changedVisibilityToState:variableItem.state];
        
    }
}



@end


// Add Observer to Notification Center
/*
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(metodoDelegado:) name:@"MetodoDelegado" object:nil];
 */

// Metodo que se ejecuta cuando se escucha la notificacion

/*
 - (void) metodoDelegado : (NSNotification *) notification {
 
 // El método recibe un objeto de tipo NSNotification cuya propiedad object
 // alberga el objeto pasado como parametro. En este caso hacemos un casting
 // del objeto a NSString.
 
 NSString *cadena = (NSString *)[notification object];
 NSLog(@"%@",cadena);
 
 NSLog(@"Parece funcionar");
 }
 */

// Dealoc Observer
/*
 -(void)dealloc{
 [[NSNotificationCenter defaultCenter] removeObserver:self];
 }
 */

// Send Notification
/*
 NSNotification *notification = [NSNotification notificationWithName:@"MetodoDelegado" object:self];
 [[NSNotificationCenter defaultCenter] postNotification:notification];
 */

/*
 -(GBCSimulator*)simulator{
 if (!_simulator) {
 _simulator = [[GBCSimulator alloc] init];
 }
 return _simulator;
 }
 */

// Creating a timer which allows us to update the Monitor View

/*
 NSTimer *timerMonitorViewController=[[NSTimer alloc] init];
 timerMonitorViewController=[NSTimer scheduledTimerWithTimeInterval:5.0
 target:self
 selector:@selector(viewDidLoad)
 userInfo:nil
 repeats:YES];
 
 NSLog(@"Imprimir esto de nuevo %@ %@ %@ %@ %@", kGBC_conscienceValue,kGBC_presureValue,kGBC_arterialPresureValue,kGBC_respiratoryFrecuencyValue,kGBC_oxigenSaturationValue);
 */

/*
 int userInput;
 scanf("%i", &userInput);
 if (userInput==5) {
 NSLog(@"You typed %i.", userInput);
 [self.view.window setIsVisible:YES];
 }
 */
