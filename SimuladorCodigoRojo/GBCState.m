//
//  GBCState.m
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/29/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import "GBCState.h"

@interface GBCState ()

@property (strong, nonatomic) NSMutableDictionary *vitalSignDictionary;
@property (strong, nonatomic) NSMutableArray *vitalSignKeys;
@property (strong, nonatomic) NSMutableArray *vitalSignValues;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *conscience;
@property (strong, nonatomic) NSString *heartRate;
@property (strong, nonatomic) NSString *arterialPresure;
@property (strong, nonatomic) NSString *respiratoryRate;
@property (strong, nonatomic) NSString *oxygenSaturation;
@property (strong, nonatomic) NSString *perfusion;

@end

    // Init Default Method

@implementation GBCState

    // Method which receive a state and return a dictionary with the vital signs related to that state

- (NSDictionary *)getVitalSignsForState:(NSString *)currentState{
    
    // Analyze the entring method string and assign a State Identifier for Switch Case
   
    self.state=currentState;
    int stateIdentifier;
    
    if ([self.state isEqualToString: @"Postparto"]) {
        stateIdentifier=0;
    }
    else if ([self.state isEqualToString: @"Choque Leve"]) {
        stateIdentifier=1;
    }
    else if ([self.state isEqualToString: @"Transitorio Leve"]) {
        stateIdentifier=2;
    }
    else if ([self.state isEqualToString: @"Choque Moderado"]) {
        stateIdentifier=3;
    }
    else if ([self.state isEqualToString:@"Choque Grave" ]) {
        stateIdentifier=4;
    }
    else if ([self.state isEqualToString: @"Estable"]) {
        stateIdentifier=5;
    }
    
    // Values for Signs in Every State
    
    switch (stateIdentifier) {
            
        case 0:
            self.conscience=@"NI";
            self.heartRate=@"84";
            self.arterialPresure=@"110/70";
            self.respiratoryRate=@"18";
            self.oxygenSaturation=@"96";
            self.perfusion=@"Normal";
            break;
        case 1:
            self.conscience=@"Excitada";
            self.heartRate=@"96";
            self.arterialPresure=@"86/50";
            self.respiratoryRate=@"20";
            self.oxygenSaturation=@"95";
            self.perfusion=@"Pálida-Fría";
            break;
        case 2:
            self.conscience=@"NI";
            self.heartRate=@"84";
            self.arterialPresure=@"110/70";
            self.respiratoryRate=@"18";
            self.oxygenSaturation=@"96";
            self.perfusion=@"Normal";
            break;
        case 3:
            self.conscience=@"Obnubilada";
            self.heartRate=@"110";
            self.arterialPresure=@"74/50";
            self.respiratoryRate=@"22";
            self.oxygenSaturation=@"90";
            self.perfusion=@"Pálida-Fría-Sudorosa";
            break;
        case 4:
            self.conscience=@"Estupor";
            self.heartRate=@"124";
            self.arterialPresure=@"60/40";
            self.respiratoryRate=@"30";
            self.oxygenSaturation=@"85";
            self.perfusion=@"Pálida-Fría-Sudorosa-LC >3s";
            break;
        case 5:
            self.conscience=@"NI";
            self.heartRate=@"84";
            self.arterialPresure=@"110/70";
            self.respiratoryRate=@"18";
            self.oxygenSaturation=@"96";
            self.perfusion=@"Normal";
            break;
            
        default:
            break;
    }
    
    // Defining Dictionary
    
    [self.vitalSignDictionary setObject:self.conscience forKey:@"Consciencia"];
    [self.vitalSignDictionary setObject:self.heartRate forKey:@"Ritmo Cardiaco"];
    [self.vitalSignDictionary setObject:self.arterialPresure forKey:@"Presión Arterial"];
    [self.vitalSignDictionary setObject:self.respiratoryRate forKey:@"Frecuencia Respiratoria"];
    [self.vitalSignDictionary setObject:self.oxygenSaturation forKey:@"Saturación de Oxígeno"];
    [self.vitalSignDictionary setObject:self.perfusion forKey:@"Perfusión"];
    
    // Return Dictionary
    
    return self.vitalSignDictionary;
    
}

// Lazy Initializations

- (NSMutableArray *)vitalSignKeys{
    if (!_vitalSignKeys) {
        _vitalSignKeys = [[NSMutableArray alloc] init];
    }
    
    return _vitalSignKeys;
}

- (NSMutableArray *)vitalSignValues{
    if (!_vitalSignValues) {
        _vitalSignValues = [[NSMutableArray alloc] init];
    }
    
    return _vitalSignValues;
}

- (NSMutableDictionary *)vitalSignDictionary{
    if (!_vitalSignDictionary) {
        _vitalSignDictionary = [[NSMutableDictionary alloc] init];
    }
    return _vitalSignDictionary;
}

@end

