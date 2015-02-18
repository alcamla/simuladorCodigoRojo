//
//  RealTimePlot.h
//  CorePlotGallery
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "PlotItem.h"
#import "GBCSimulator.h"

@interface RealTimePlot : PlotItem<CPTPlotDataSource, GBCSimulatorECGAnimationDelegate>

-(void)newData:(NSTimer *)theTimer;

@end
