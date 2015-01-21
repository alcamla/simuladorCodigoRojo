//
//  GBCRedCodeUtilities.m
//  SimuladorCodigoRojo
//
//  Created by camacholaverde on 1/21/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import "GBCRedCodeUtilities.h"

@interface GBCRedCodeUtilities()

@end

@implementation GBCRedCodeUtilities


+(NSDictionary*)sensorsImagesDictionary{
    NSDictionary *sensorsDictionary =  @{@"Oxígeno":@[@"red_code_oxigen_sensor_active",
                                                      @"red_code_oxigen_sensor_inactive"],
                                         @"Vías Venosas":@[@"red_code_catheter_sensor_active",
                                                           @"red_code_catheter_sensor_inactive"],
                                         @"Manta":@[@"red_code_blanket_sensor_active",
                                                    @"red_code_blanket_sensor_inactive"],
                                         @"Sonda Urinaria":@[@"red_code_urinary_catheter_sensor_active",
                                                             @"red_code_urinary_catheter_sensor_inactive"],
                                         @"Medición de Signos":@[@"red_code_vital_signs_sensor_active",
                                                                 @"red_code_vital_signs_sensor_inactive"],
                                         @"Masaje":@[@"red_code_massage_sensor_active",
                                                     @"red_code_massage_sensor_inactive"]};
    return sensorsDictionary;
}


+(NSImage *)sensorStateImageForVariable:(NSString*)variable inState:(NSString *)state
{
    NSImage *image;
    if ([state isEqualToString:@"Yes"]) {
        image = [NSImage imageNamed:[[GBCRedCodeUtilities sensorsImagesDictionary] objectForKey:variable][0]];
    } else{
        image = [NSImage imageNamed:[[GBCRedCodeUtilities sensorsImagesDictionary] objectForKey:variable][1]];
    }
    return  image;
}

@end
