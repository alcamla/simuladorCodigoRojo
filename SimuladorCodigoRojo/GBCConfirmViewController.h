//
//  GBCConfirmViewController.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBCConfirmViewController : NSViewController

-(IBAction)goToMonitor:(id)sender;
-(void) setScenaryToDisplay;
-(void) setInstitutionalConditions;
-(void) setExternConditions;
-(void) setNoBirthYetConditions;
-(void) sendShockStateSelected;

@end
