//
//  ecgsyn.h
//  
//
//  Created by camacholaverde on 12/12/14.
//
//

#ifndef _ecgsyn_h
#define _ecgsyn_h


#endif

double * dorun();
double * calculateECG(int heartBeats, int samplingFrequency, int heartRate);
double * calculateEcgAndPeaksLocation(int heartBeats, int samplingFrequency, int heartRate, int *totalSamples);//, double **peaksVector);