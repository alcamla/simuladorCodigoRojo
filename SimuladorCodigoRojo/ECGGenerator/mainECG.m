//
//  main.m
//  ECGGenerator
//
//  Created by camacholaverde on 12/15/14.
//  Copyright (c) 2014 gibicgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ecgsyn.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        double *ecgVector =calculateECG(10, 128, 40);
        int ecgVectorSize = sizeof(ecgVector)/sizeof(double);
        NSString * stringFromArray = NULL;
        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity: ecgVectorSize];
        if(array)
        {
            NSInteger count = 0;
            
            while( count++ < ecgVectorSize )
            {
                [array addObject: [NSString stringWithFormat: @"%f", ecgVector[count]]];
            }
            
            stringFromArray = [array componentsJoinedByString:@","]; 
        }
        NSLog(@"Hello, World!, %f" , ecgVector[10]);
    }
    return 0;
}
