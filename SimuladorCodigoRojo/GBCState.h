//
//  GBCState.h
//  SimuladorCodigoRojo
//
//  Created by FING140323 on 12/29/14.
//  Copyright (c) 2014 FING140323. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBCState : NSObject

- (NSDictionary *) getVitalSignsForState: (NSString *)currentState;

@end
