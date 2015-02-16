//
//  RealTimePlot.m
//  CorePlotGallery
//

#import "RealTimePlot.h"
#import "ecgsyn.h"

static const double kFrameRate = 2;  // frames per second

static const NSUInteger kMaxDataPoints = 1536 +256+256;
static NSString *const kPlotIdentifier = @"Data Source Plot";

@interface RealTimePlot()

@property (nonatomic, readwrite, strong) NSMutableArray *plotData;
@property (nonatomic, readwrite, assign) NSUInteger currentIndex;
@property (nonatomic, readwrite, strong) NSTimer *dataTimer;
@property (nonatomic) NSInteger currentIndexOfECGVector;
@property (nonatomic, strong) NSMutableArray *ecgVector;
@property(nonatomic)NSUInteger deletedSamples;

@end

@implementation RealTimePlot

@synthesize plotData;
@synthesize currentIndex;
@synthesize dataTimer;


-(id)init
{
    if ( (self = [super init]) ) {
        plotData  = [[NSMutableArray alloc] initWithCapacity:kMaxDataPoints];
        dataTimer = nil;

        self.title   = @"Real Time Plot";
        self.section = kLinePlots;
    }

    return self;
}

-(void)killGraph
{
    [self.dataTimer invalidate];
    self.dataTimer = nil;

    [super killGraph];
}

-(void)generateData
{
    [self.plotData removeAllObjects];
    self.currentIndex = 0;
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingTop    = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingRight  = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingBottom = self.titleSize * CPTFloat(2.625);
    graph.plotAreaFrame.paddingLeft   = self.titleSize * CPTFloat(2.5);
    graph.plotAreaFrame.masksToBorder = NO;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];

    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    x.minorTicksPerInterval       = 9;
    x.labelOffset                 = self.titleSize * CPTFloat(0.25);
    x.title                       = @"X Axis";
    x.titleOffset                 = self.titleSize * CPTFloat(1.5);
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;

    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.minorTicksPerInterval       = 3;
    y.labelOffset                 = self.titleSize * CPTFloat(0.25);
    y.title                       = @"Y Axis";
    y.titleOffset                 = self.titleSize * CPTFloat(1.25);
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];

    // Rotate the labels by 45 degrees, just to show it can be done.
    x.labelRotation = CPTFloat(M_PI_4);

    // Create the plot
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier     = kPlotIdentifier;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 256)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5) length:CPTDecimalFromDouble(2.0)];

    [self.dataTimer invalidate];

    if ( animated ) {
        self.dataTimer = [NSTimer timerWithTimeInterval:1.0 / kFrameRate
                                                 target:self
                                               selector:@selector(newData:)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.dataTimer forMode:NSRunLoopCommonModes];
    }
    else {
        self.dataTimer = nil;
    }
}

-(void)dealloc
{
    [dataTimer invalidate];
}

#pragma mark -
#pragma mark Timer callback

-(void)newData:(NSTimer *)theTimer
{
    CPTGraph *theGraph = (self.graphs)[0];
    CPTPlot *thePlot   = [theGraph plotWithIdentifier:kPlotIdentifier];

    if ( thePlot ) {
        if ( self.plotData.count >= kMaxDataPoints ) {
            [self.plotData removeObjectsInRange:NSMakeRange(0, 128)];
            [thePlot deleteDataInIndexRange:NSMakeRange(0, 128)];
            self.deletedSamples +=128;
        }

        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
                double simRangeLocation = self.currentIndex*(256/2) >= kMaxDataPoints ? ((self.currentIndex*128  - kMaxDataPoints + 256)/256) : 0;
        double simRangeLength = (kMaxDataPoints - 256)/256;
        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(simRangeLocation)
                                                               length:CPTDecimalFromDouble(simRangeLength)];



        
        
        [self.plotData addObjectsFromArray: [self nextECGValue]];
        [thePlot insertDataAtIndex:self.plotData.count - 128 numberOfRecords:128];
        self.currentIndex++;
        
        [CPTAnimation animate:plotSpace
                     property:@"xRange"
                fromPlotRange:plotSpace.xRange
                  toPlotRange:newRange
                     duration:CPTFloat(1.0 / 128.8)];
    }
}

-(NSArray*)nextECGValue{
    //NSNumber *nextValue = self.ecgVector[self.currentIndexOfECGVector];
    NSArray *nextSegment = [self.ecgVector subarrayWithRange:NSMakeRange(self.currentIndexOfECGVector, 128)];
    self.currentIndexOfECGVector  += 128;
    return nextSegment;
}

-(NSMutableArray*)ecgVector{
    if (!_ecgVector || (self.currentIndexOfECGVector +128 >= [_ecgVector count])) {
         self.currentIndexOfECGVector = 0;
        _ecgVector = [NSMutableArray new];
         int ecgVectorSize = 0;
        double *ecgVectorC = calculateEcgAndPeaksLocation(40, 256, 60,&ecgVectorSize);
        for (int i = 0; i<ecgVectorSize; i++ ) {
            [_ecgVector addObject: [NSNumber numberWithDouble:ecgVectorC[i]]];
        }
    }
    return _ecgVector;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(NSNumber*)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @((index+self.deletedSamples)/(256.0));
            break;

        case CPTScatterPlotFieldY:
            num = self.plotData[index];
            break;

        default:
            break;
    }

    return num;
}

@end
