//
//  AppDelegate.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/18/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
  
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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
