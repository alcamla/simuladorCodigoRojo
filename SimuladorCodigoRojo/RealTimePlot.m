//
//  RealTimePlot.m
//  CorePlotGallery
//

#import "RealTimePlot.h"
#import "ecgsyn.h"
#import "GBCSimulator.h"

static const double kFrameRate = 2;  // frames per second

static const NSUInteger kMaxDataPoints = 384 +64+64;
static const NSUInteger kECGSamplingFrequency = 64;
static NSString *const kPlotIdentifier = @"Data Source Plot";


@interface RealTimePlot()

@property (nonatomic, readwrite, strong) NSMutableArray *plotData;
@property (nonatomic, readwrite, assign) NSUInteger currentIndex;
@property (nonatomic, readwrite, strong) NSTimer *dataTimer;
@property (nonatomic) NSInteger currentIndexOfECGVector;
@property (nonatomic, strong) NSMutableArray *ecgVector;
@property (nonatomic) NSUInteger deletedSamples;
@property (nonatomic) NSInteger currentHeartRate;
@property (nonatomic, strong) NSDictionary *ecgVectors;
@property (nonatomic, strong) NSDictionary *simulationStatesDictionary;
@property (nonatomic, strong) NSDictionary *statesHeartRatesDictionary;
@property (nonatomic, strong) NSNumber *simulationState;
@property (nonatomic, strong) NSSound *ecgBeep;
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
        
        BOOL updateECGVectors = YES;
        
        //Create the ECG vectors as part of the User Defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"ecgVectors"]|| updateECGVectors) {
            //Create a dictinary for each simulation state
            NSMutableDictionary *ecgVectorsMutDic= [NSMutableDictionary new];
            self.statesHeartRatesDictionary = @{@0:@84,@1:@96, @2:@84, @3:@110, @4:@124, @5:@84};
            NSNumber *heartRate;
            NSMutableArray *localEcgVector;
            NSMutableArray *localPeaksLocationVector;
            for (NSNumber *key in self.statesHeartRatesDictionary) {
                heartRate = (NSNumber*)self.statesHeartRatesDictionary[key];
                localEcgVector = [NSMutableArray new];
                localPeaksLocationVector = [NSMutableArray new];
                int ecgVectorSize = 0;
                double *peaksLocationVector=malloc(14);
                double *ecgVectorC = calculateEcgAndPeaksLocation(40, kECGSamplingFrequency, (int)[heartRate integerValue], &ecgVectorSize);//, &peaksLocationVector);
                for (int i = 0; i<ecgVectorSize; i++ ) {
                    double sample = ecgVectorC[i];
                    double peakSample = peaksLocationVector[i];
                    if (sample != sample) {
                        NSLog(@"We have a NaN");
                    }
                    //Downscale the signal
                    sample = sample/100;
                    [localEcgVector addObject: [NSNumber numberWithDouble:sample]];
                    [localPeaksLocationVector addObject:[NSNumber numberWithDouble:peakSample]];
                }
                [ecgVectorsMutDic setObject:localEcgVector forKey:key];
            }

            NSData *ecgVectorsAsData = [NSKeyedArchiver archivedDataWithRootObject:ecgVectorsMutDic];
            [defaults setObject:ecgVectorsAsData forKey:@"ecgVectors"];
        }
        //Get the ECG vectors from UserDefaults
        NSData *ecgVectorsAsData = [defaults objectForKey: @"ecgVectors"];
        NSMutableDictionary *ecgVectors = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:ecgVectorsAsData];
        self.ecgVectors = ecgVectors;
    }
    //self.title   = @"Real Time Plot";
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
    [self applyTheme:theme toGraph:graph withDefault:nil];

    graph.plotAreaFrame.paddingTop    = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingRight  = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingBottom = self.titleSize * CPTFloat(2.625);
    graph.plotAreaFrame.paddingLeft   = self.titleSize * CPTFloat(2.5);
    graph.plotAreaFrame.masksToBorder = NO;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    //majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineWidth = 0;
    //majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.0)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    //minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineWidth = 0;
    //minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.0)];

    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    x.minorTicksPerInterval       = 0;
    //x.labelOffset                 = self.titleSize * CPTFloat(0.25);
    //x.title                       = @"X Axis";
    //x.titleOffset                 = self.titleSize * CPTFloat(1.5);
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;

    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.minorTicksPerInterval       = 0;
    //y.labelOffset                 = self.titleSize * CPTFloat(0.25);
    //y.title                       = @"Y Axis";
    //y.titleOffset                 = self.titleSize * CPTFloat(1.25);
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
    dataSourceLinePlot.interpolation =CPTScatterPlotInterpolationCurved;


    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - kECGSamplingFrequency)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5) length:CPTDecimalFromDouble(2.0)];

    [self.dataTimer invalidate];

    if ( animated ) {
        [self configureAnimationTimer];

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
#pragma mark Animation Timer

-(void)configureAnimationTimer{
    self.dataTimer = [NSTimer timerWithTimeInterval:1.0 / kFrameRate
                                             target:self
                                           selector:@selector(newData:)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.dataTimer forMode:NSRunLoopCommonModes];
}


#pragma mark -
#pragma mark Timer callback

-(void)newData:(NSTimer *)theTimer
{
    CPTGraph *theGraph = (self.graphs)[0];
    CPTPlot *thePlot   = [theGraph plotWithIdentifier:kPlotIdentifier];

    if ( thePlot ) {
        if ( self.plotData.count >= kMaxDataPoints ) {
            [self.plotData removeObjectsInRange:NSMakeRange(0, kECGSamplingFrequency/kFrameRate)];
            [thePlot deleteDataInIndexRange:NSMakeRange(0, kECGSamplingFrequency/kFrameRate)];
            self.deletedSamples += kECGSamplingFrequency/kFrameRate;
        }

        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
                double simRangeLocation = self.currentIndex*( kECGSamplingFrequency/kFrameRate) >= kMaxDataPoints ? ((self.currentIndex* kECGSamplingFrequency/kFrameRate  - kMaxDataPoints + kECGSamplingFrequency)/kECGSamplingFrequency) : 0;
        double simRangeLength = (kMaxDataPoints - kECGSamplingFrequency)/kECGSamplingFrequency;
        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(simRangeLocation)
                                                               length:CPTDecimalFromDouble(simRangeLength)];



        
        
        [self.plotData addObjectsFromArray: [self nextECGValue]];
        [thePlot insertDataAtIndex:self.plotData.count - kECGSamplingFrequency/kFrameRate numberOfRecords: kECGSamplingFrequency/kFrameRate];
        self.currentIndex++;
        
        [CPTAnimation animate:plotSpace
                     property:@"xRange"
                fromPlotRange:plotSpace.xRange
                  toPlotRange:newRange
                     duration:CPTFloat(1.0 /kFrameRate)];
    }
}

-(NSArray*)nextECGValue{
    //NSNumber *nextValue = self.ecgVector[self.currentIndexOfECGVector];
    NSArray *nextSegment = [self.ecgVector subarrayWithRange:NSMakeRange(self.currentIndexOfECGVector,  kECGSamplingFrequency/kFrameRate)];
    self.currentIndexOfECGVector  +=  kECGSamplingFrequency/kFrameRate;
    return nextSegment;
}

-(NSMutableArray*)ecgVector{
    //Get the current heartRate from the Simulation Model
    NSString *simulationStateString =[[GBCSimulator sharedSimulator] sendCurrentState];
    NSNumber *currentSimulationState = self.simulationStatesDictionary[simulationStateString];
    BOOL mustRecalculateECGVector = NO;
    if (self.simulationState != currentSimulationState) {
        self.simulationState = currentSimulationState;
        NSTimeInterval heartSoundPeriod = 60.0/[self.statesHeartRatesDictionary[self.simulationState] doubleValue];
        [self performSelector:@selector(ecgBeepWithTimeInterval:) withObject:[NSNumber numberWithDouble:heartSoundPeriod] afterDelay:heartSoundPeriod];
        mustRecalculateECGVector = YES;
    }
    if (!_ecgVector || mustRecalculateECGVector){ //|| (self.currentIndexOfECGVector +128 >= [_ecgVector count])) {
    //if (!_ecgVector || (self.currentIndexOfECGVector + kECGSamplingFrequency/kFrameRate >= [_ecgVector count])) {
         self.currentIndexOfECGVector = 0;
        _ecgVector = self.ecgVectors[self.simulationState];
    }else if (self.currentIndexOfECGVector +128 >= [_ecgVector count]){
    self.currentIndexOfECGVector =0;
    }
    return _ecgVector;
}

-(void)ecgBeepWithTimeInterval:(NSNumber*)interval{
    [self.ecgBeep play];
    [self performSelector:@selector(ecgBeepWithTimeInterval:) withObject:interval afterDelay:[interval doubleValue]];
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
            num = @((index+self.deletedSamples)/(64.0));
            //NSBeep();
            break;

        case CPTScatterPlotFieldY:
            num = self.plotData[index];
            break;

        default:
            break;
    }

    return num;
}

-(NSDictionary*)simulationStatesDictionary{
    if (!_simulationStatesDictionary) {
        _simulationStatesDictionary = @{@"Postparto":@0,
                                        @"Choque Leve":@1,
                                        @"Transitorio Leve":@2,
                                        @"Choque Moderado":@3,
                                        @"Choque Grave":@4,
                                        @"Estable":@5};
    }
    return _simulationStatesDictionary;
}

#pragma mark GBCSimulatorECGAnimationDelegate protocol conformance

-(void)animationDidChangeState:(BOOL)newState{
    BOOL simulationIsPaused = newState;
    if (!simulationIsPaused) {
        //Turn on the animation
        [self configureAnimationTimer];
        
    } else{
        //Turn off the animation
        [self.dataTimer invalidate];
        self.dataTimer = nil;
    }
    
}

-(NSSound*)ecgBeep{
    if (!_ecgBeep) {
        _ecgBeep=[NSSound soundNamed:@"Tink.aiff"];
    }
    return _ecgBeep;
}


@end
