//
//  GBCDoctorPanelWindowController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 2/11/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCDoctorPanelWindowController.h"

@interface GBCDoctorPanelWindowController ()

@end

@implementation GBCDoctorPanelWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // Set transparence to the window
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setAlphaValue:0.95];
}

@end
