//
//  GBCResultsViewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBCResultsViewController : NSViewController

- (IBAction)goToNewSimulation:(id)sender;
- (void)readVariablesStatusToDisplay;
- (void)displayResults;
- (void) calculateScore;

@end
