//
//  GBCConfirmViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCConfirmViewController.h"
#import "GBCSimulator.h"

@interface GBCConfirmViewController ()

@end

@implementation GBCConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.

}

- (IBAction)goToMenu:(id)sender {
    
    // Hide Current Window
    [self.view.window setIsVisible:NO];
    
    // Call Segue to go to next view controller
    [self performSegueWithIdentifier:@"fromConfirmToMonitor" sender:sender];
    
    // Send state message
    [[GBCSimulator sharedSimulator] sendStateToDoll];
}

@end
