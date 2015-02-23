//
//  RealTimePlot.m
//  CorePlotGallery
//

#import "RealTimePlot.h"
#import "ecgsyn.h"
#import "GBCSimulator.h"

static const double kFrameRate = 2;  // frames per second

//static const NSUInteger kMaxDataPoints = 384 +64+64;  //Visualize 6 seconds of ECG signal at sampling frequency
static const NSUInteger kMaxDataPoints = 192 +32+32;
//static const NSUInteger kECGSamplingFrequency = 64;
static const NSUInteger kECGSamplingFrequency = 32;
static NSString *const kPlotIdentifier = @"Data Source Plot";


@interface RealTimePlot(){
    dispatch_source_t _timer;
}

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
@property (nonatomic, strong) NSDictionary *heartRatesSoundsFilesDictionary;
@property (nonatomic, strong) NSNumber *simulationState;
@property (nonatomic, strong) NSSound *ecgBeep;
@property (nonatomic, strong)NSTimer *beepTimer;

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
            for (NSNumber *key in self.statesHeartRatesDictionary) {
                heartRate = (NSNumber*)self.statesHeartRatesDictionary[key];
                localEcgVector = [NSMutableArray new];
                int ecgVectorSize = 0;
                double *ecgVectorC = calculateEcgAndPeaksLocation(40, kECGSamplingFrequency, (int)[heartRate integerValue], &ecgVectorSize);//, &peaksLocationVector);
                for (int i = 0; i<ecgVectorSize; i++ ) {
                    double sample = ecgVectorC[i];
                    if (sample != sample) {
                        NSLog(@"We have a NaN");
                    }
                    //Downscale the signal
                    sample = sample/100;
                    [localEcgVector addObject: [NSNumber numberWithDouble:sample]];
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
    [self.ecgBeep stop];
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
    x.labelFormatter = nil;
    x.hidden = YES;
    for (CPTAxisLabel *axisLabel in x.axisLabels) {
        axisLabel.contentLayer.hidden = YES;
    }

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
    y.hidden = YES;
    for (CPTAxisLabel *axisLabel in y.axisLabels) {
        axisLabel.contentLayer.hidden = YES;
    }

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
        //Change the sound that is being played
        [self playECGBeepForCurrentSimulationState];
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

-(void)playEcgBeep{
    [self.ecgBeep play];
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
            num = @((index+self.deletedSamples)/((double)kECGSamplingFrequency));
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

-(NSDictionary*) heartRatesSoundsFilesDictionary{
    if (!_heartRatesSoundsFilesDictionary) {
        _heartRatesSoundsFilesDictionary = @{@0:@"ECG_beeps_84Hz.m4a",
                                             @1:@"ECG_beeps_96Hz.m4a",
                                             @2:@"ECG_beeps_84Hz.m4a",
                                             @3:@"ECG_beeps_110Hz.m4a",
                                             @4:@"ECG_beeps_124Hz.m4a",
                                             @5:@"ECG_beeps_84Hz.m4a"
                                             };
        
        
      //  @{@0:@84,@1:@96, @2:@84, @3:@110, @4:@124, @5:@84
        
    }
    return _heartRatesSoundsFilesDictionary;
}

#pragma mark -
#pragma mark GBCSimulatorECGAnimationDelegate protocol conformance

-(void)animationDidChangeState:(BOOL)newState{
    BOOL simulationIsPaused = newState;
    if (!simulationIsPaused) {
        //Turn on the animation
        [self configureAnimationTimer];
        [self.ecgBeep resume];
        
    } else{
        //Turn off the animation
        [self.dataTimer invalidate];
        self.dataTimer = nil;
        [self.ecgBeep pause];
    }
    
}
-(void)killAnimation{
    [self killGraph];
}

-(NSSound*)ecgBeep{
    if (!_ecgBeep) {
        _ecgBeep=[NSSound soundNamed:@"ECGbeep_edited_2.mp3"];
        [_ecgBeep setLoops:YES];
    }
    return _ecgBeep;
}

#pragma mark -
#pragma mark ECG Beep timer


-(void)playECGBeepForCurrentSimulationState{
    if (self.ecgBeep.name != self.heartRatesSoundsFilesDictionary[self.simulationState]) {
        [self.ecgBeep stop];
        self.ecgBeep = [NSSound soundNamed:self.heartRatesSoundsFilesDictionary[self.simulationState]];
        [self.ecgBeep setLoops:YES];
    }
    [self.ecgBeep play];
}


@end
