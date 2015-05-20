//
//  GBCConfirmViewController.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 1/6/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCConfirmViewController.h"
#import "GBCSimulator.h"
#import "GBCMonitorVIewController.h"
#import <ScreenSaver/ScreenSaver.h>

@interface GBCConfirmViewController ()

@property (weak) IBOutlet NSTextField *caseValue;
@property (weak) IBOutlet NSTextField *ageMomValue;
@property (weak) IBOutlet NSTextField *birthTimeValue;
@property (weak) IBOutlet NSTextField *alumbStateValue;
@property (weak) IBOutlet NSTextField *shockStateValue;
@property (weak) IBOutlet NSTextField *ageBabyValue;
@property (weak) IBOutlet NSTextField *backgroundBirthValue;
@property (weak) IBOutlet NSTextField *previousSaryValue;
@property (weak) IBOutlet NSTextField *birthTypeValue;

@property (weak) IBOutlet NSTextField *birthTimeName;
@property (weak) IBOutlet NSTextField *birthTypeName;

@property (weak) IBOutlet NSTextField *alumbName;
@property (weak) IBOutlet NSTextField *yearsName;
@property (weak) IBOutlet NSTextField *minutesName;

@property (strong,nonatomic) NSMutableArray *stateArray;
@property (strong,nonatomic) NSMutableArray *alumbArray;
@property (strong,nonatomic) NSMutableArray *backgroundArray;
@property (strong,nonatomic) NSMutableArray *saryArray;
@property (strong,nonatomic) NSMutableArray *caseArray;
@property (strong,nonatomic) NSString *caseInternalString;
@property (strong,nonatomic) NSString *backgroundInternalString;
@property (strong,nonatomic) NSString *shockStateInternalString;


@end

@implementation GBCConfirmViewController

int caseNumber;
int ageBabyNumber;
int ageMomNumber;
int birthTimeNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.
    [self setScenaryToDisplay];
    
    //[self hideLabelsVisibility];

}

- (IBAction)goToMonitor:(id)sender {
    
    // Hide Current Window
    [self.view.window setIsVisible:NO];
    
    // Call Segue to go to next view controller
    [self performSegueWithIdentifier:@"fromConfirmToMonitor" sender:sender];
    
    // Send state message
    [[GBCSimulator sharedSimulator] sendStateToDoll];
}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"fromConfirmToMonitor"]) {
        NSWindowController *wController = (NSWindowController*)segue.destinationController;
        GBCMonitorVIewController *monitor = (GBCMonitorVIewController *)wController.contentViewController;
        [[GBCSimulator sharedSimulator] setMonitorViewController:monitor];
    }
}

// Hide visibility of labels

-(void) hideLabelsVisibility{
    
    // Names
    [self.birthTimeValue setHidden:YES];
    [self.birthTypeValue setHidden:YES];
    [self.alumbStateValue setHidden:YES];
    
    
    // Values
    [self.birthTimeName setHidden:YES];
    [self.birthTypeName setHidden:YES];
    [self.yearsName setHidden:YES];
    [self.minutesName setHidden:YES];
    [self.alumbName setHidden:YES];
    
    
}

// Set the scenary to display

- (void) setScenaryToDisplay{
    
    // Define a Random Case
    self.caseInternalString=self.caseArray[SSRandomIntBetween(0, 1)];
    //self.caseInternalString=self.caseArray[0];
    
    // Clasify Conditions According to Case
    if ([self.caseInternalString isEqualToString:@"Postparto Institucional"]==YES) {
        
        [self setInstitutionalConditions];
        
    }else if ([self.caseInternalString isEqualToString:@"Postparto Externo"]==YES){
        
        [self setExternConditions];
    
    }else if ([self.caseInternalString isEqualToString:@"Choque con Feto en Útero"]==YES){
        
        [self setNoBirthYetConditions];
    }
    
    // Send the state selected randomly to main class simulator
    [self sendShockStateSelected];
}

// Case 1 Conditions

-(void) setInstitutionalConditions{
    
    // Set visibility
    
    // Names
    [self.birthTimeValue setHidden:NO];
    [self.birthTypeValue setHidden:NO];
    [self.alumbStateValue setHidden:NO];
    
    
    // Values
    [self.birthTimeName setHidden:NO];
    [self.birthTypeName setHidden:NO];
    [self.yearsName setHidden:NO];
    [self.minutesName setHidden:NO];
    [self.alumbName setHidden:NO];

    // Calcule random values
    ageBabyNumber=SSRandomIntBetween(24, 38);
    ageMomNumber=SSRandomIntBetween(20, 45);
    birthTimeNumber=SSRandomIntBetween(5, 30);
    
    // Display Labels
    [self.caseValue setStringValue:self.caseInternalString];
    [self.ageBabyValue setStringValue:[NSString stringWithFormat:@"%d",ageBabyNumber]];
    [self.ageMomValue setStringValue:[NSString stringWithFormat:@"%d",ageMomNumber]];
    [self.birthTimeValue setStringValue:[NSString stringWithFormat:@"%d",birthTimeNumber]];
    self.shockStateInternalString=self.stateArray[SSRandomIntBetween(0, 1)];
    [self.shockStateValue setStringValue:self.shockStateInternalString];
    [self.alumbStateValue setStringValue:self.alumbArray[SSRandomIntBetween(0, 2)]];
    self.backgroundInternalString=self.backgroundArray[SSRandomIntBetween(0, 1)];
    [self.backgroundBirthValue setStringValue:self.backgroundInternalString];
    if ([self.backgroundInternalString isEqualToString:@"Multigestante"]==YES) {
        [self.previousSaryValue setStringValue:self.saryArray[SSRandomIntBetween(0, 1)]];
    }else{
        [self.previousSaryValue setStringValue:@"No"];
    }

}

// Case 2 Conditions

-(void) setExternConditions{
    
    // Set visibility
    
    // Names
    [self.birthTimeValue setHidden:NO];
    [self.birthTypeValue setHidden:NO];
    [self.alumbStateValue setHidden:NO];
    
    
    // Values
    [self.birthTimeName setHidden:NO];
    [self.birthTypeName setHidden:NO];
    [self.yearsName setHidden:NO];
    [self.minutesName setHidden:NO];
    [self.alumbName setHidden:NO];

    // Calcule random values
    ageBabyNumber=SSRandomIntBetween(24, 38);
    ageMomNumber=SSRandomIntBetween(20, 45);
    birthTimeNumber=SSRandomIntBetween(30, 60);
    
    // Display Labels
    [self.caseValue setStringValue:self.caseInternalString];
    [self.ageBabyValue setStringValue:[NSString stringWithFormat:@"%d",ageBabyNumber]];
    [self.ageMomValue setStringValue:[NSString stringWithFormat:@"%d",ageMomNumber]];
    [self.birthTimeValue setStringValue:[NSString stringWithFormat:@"%d",birthTimeNumber]];
    self.shockStateInternalString=self.stateArray[SSRandomIntBetween(1, 2)];
    [self.shockStateValue setStringValue:self.shockStateInternalString];
    [self.alumbStateValue setStringValue:self.alumbArray[SSRandomIntBetween(1, 2)]];
    self.backgroundInternalString=self.backgroundArray[SSRandomIntBetween(0, 1)];
    [self.backgroundBirthValue setStringValue:self.backgroundInternalString];
    if ([self.backgroundInternalString isEqualToString:@"Multigestante"]==YES) {
        [self.previousSaryValue setStringValue:self.saryArray[SSRandomIntBetween(0, 1)]];
    }else{
        [self.previousSaryValue setStringValue:@"No"];
    }

}

// Case 3 Conditions

-(void) setNoBirthYetConditions{
    
    // Set visibility
    
    // Names
    [self.birthTimeValue setHidden:YES];
    [self.birthTypeValue setHidden:YES];
    [self.alumbStateValue setHidden:YES];
    
    
    // Values
    [self.birthTimeName setHidden:YES];
    [self.birthTypeName setHidden:YES];
    [self.minutesName setHidden:YES];
    [self.alumbName setHidden:YES];

    // Calcule random values
    ageBabyNumber=SSRandomIntBetween(24, 38);
    ageMomNumber=SSRandomIntBetween(20, 45);
    
    
    // Display Labels
    [self.caseValue setStringValue:self.caseInternalString];
    [self.ageBabyValue setStringValue:[NSString stringWithFormat:@"%d",ageBabyNumber]];
    [self.ageMomValue setStringValue:[NSString stringWithFormat:@"%d",ageMomNumber]];
    self.shockStateInternalString=self.stateArray[SSRandomIntBetween(1, 2)];
    [self.shockStateValue setStringValue:self.shockStateInternalString];
    self.backgroundInternalString=self.backgroundArray[SSRandomIntBetween(0, 1)];
    [self.backgroundBirthValue setStringValue:self.backgroundInternalString];
    if ([self.backgroundInternalString isEqualToString:@"Multigestante"]==YES) {
        [self.previousSaryValue setStringValue:self.saryArray[SSRandomIntBetween(0, 1)]];
    }else{
        [self.previousSaryValue setStringValue:@"No"];
    }


}

// Send the selected state to Main Class Simulator

- (void) sendShockStateSelected{
    
    [[GBCSimulator sharedSimulator] stateSelectedIs:self.shockStateInternalString];
}

// Lazy Initializations

- (NSMutableArray *)stateArray{
    
    if (!_stateArray) {
        
        _stateArray = [[NSMutableArray alloc] initWithObjects:@"Choque Leve",@"Choque Moderado",@"Choque Grave", nil];
    }
    return _stateArray;
}

- (NSMutableArray *)alumbArray{
    
    if (!_alumbArray) {
        
        _alumbArray = [[NSMutableArray alloc] initWithObjects:@"Con Alumbramiento Activo",@"Sin Alumbramiento Activo",@"Placenta Retenida", nil];
    }
    return _alumbArray;
}

- (NSMutableArray *)backgroundArray{
    
    if (!_backgroundArray) {
        
        _backgroundArray = [[NSMutableArray alloc] initWithObjects:@"Primigestante",@"Multigestante", nil];
    }
    return _backgroundArray;
}

- (NSMutableArray *)saryArray{
    
    if (!_saryArray) {
        
        _saryArray = [[NSMutableArray alloc] initWithObjects:@"Si",@"No", nil];
    }
    return _saryArray;
}

- (NSMutableArray *)caseArray{
    
    if (!_caseArray) {
        
        _caseArray = [[NSMutableArray alloc] initWithObjects:@"Postparto Institucional",@"Postparto Externo",@"Choque con Feto en Útero", nil];
    }
    return _caseArray;
}


@end
