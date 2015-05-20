//
//  GBCRedCodeUtilities.h
//  SimuladorCodigoRojo
//
//  Created by camacholaverde on 1/21/15.
//  Copyright (c) 2015 FING140323. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>


@interface GBCRedCodeUtilities : NSObject


+(NSImage *)sensorStateImageForVariable:(NSString*)variable inState:(NSString *)state;

@end
