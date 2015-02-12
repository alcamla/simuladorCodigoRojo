//
//  RealTimePlot.h
//  CorePlotGallery
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "PlotItem.h"

@interface RealTimePlot : PlotItem<CPTPlotDataSource>

-(void)newData:(NSTimer *)theTimer;

@end
