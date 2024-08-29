import("stdfaust.lib");
import("StrappiLibraryAIP.lib");
import("mspan.lib");
import("schroederAllpass.lib");

timeRMS = 0.1;
timePeak = .1;
pkTresh = -25 : ba.db2linear;
timeAvgPeakCounter=4;


//================================================================================================================
mappingQfilter6(secCounter) = ma.E^frequenzaPicchi(timePeak,pkTresh,secCounter,2)*2: _+400 : _ ,1000 : min : peakHolder(3) : integrator(0.3);
mappingQfilter5(secCounter) = ma.E^frequenzaPicchi(timePeak,pkTresh,secCounter,2)*2: _+200 : _ ,1000 : min : peakHolder(3) : integrator(0.3);
//================================================================================================================

lrsomma = \(l1,r1,l2,r2).(l1+l2,r1+r2);

inNoiseBank = par(i,6,inNoise) ;
inNoise = (no.noise*0.5);

fDev(freqDev,in) = freqDev+(freqDev/2)*(movingAverageRMS(.05,in):peakHolder(6));
fDev3(freqDev,in) = freqDev+(freqDev/15)*(peakenvelope(.2,in):peakHolder(6));


radianFun(secCounter,sec,in) = in : frequenzaPicchi(timePeak,pkTresh,secCounter,1)^2.3 ;
radianFun2(in) = in <: (movingAverageRMS(.1)*50 : integrator(1.2));
makeMidSide4(i,degI,in) = in : mspan(.6,((ma.signum(degI)*((abs(degI)+radianFun(.5,2,in)+radianFun2(in)^2)*2)*ma.PI/180)));




routingEnv(i1,i2,i3,i4,i5,i6,e1,e2,e3,e4,e5,e6) = i1*e1,i2*e2,i3*e3,i4*e4,i5*e5,i6*e6;

fDev(freqDev,in) = freqDev+(freqDev/2)*(movingAverageRMS(.05,in):peakHolder(6));
fDev3(freqDev,in) = freqDev+(freqDev/15)*(peakenvelope(.2,in):peakHolder(6));
noiseFbkBank2(fdev,freqDev,fbTime,fbgI,qFilBank,in) = (in : bpBankPeakEnv : bpDelEnv(fbTime,fbgI)), (inNoiseBank : bpBankFmul(fdev(freqDev,in),qFilBank)) : routingEnv;


chord2 = \(fx,fx2,degI,mside,tSec,gainRev,in).
    (in <: (fx,in : fx2 : par(i,6,mside(i,degI)):> si.bus(2) : _, combApf(tSec,gainRev): sdmx));


//----------------
// Calibration
// process = input : inputMid <: rmsInputVis(timeRMS) , peakInputVis(timePeak), picchiMediaInputVis(timePeak,pkTresh,timeAvgPeakCounter,2);
//----------------


process = 0;
/*
process = input : inputMid <:  (si.bus(2):par(i,2,*(.3))),
                (chord2(mappingQfilter5(1.5),noiseFbkBank2(fDev3,.8,0.01,0.5),270,makeMidSide4,1,.3),
                    chord2(mappingQfilter5(1.5),noiseFbkBank2(fDev,.8,.01,0.5),-90,makeMidSide4,1,.3) : lrsomma),
                (chord2(mappingQfilter6(1.7),noiseFbkBank2(fDev3,1.4,0.1,0),90,makeMidSide4,4,.3),
                    chord2(mappingQfilter6(1.5),noiseFbkBank2(fDev,1.4,0.05,0),-269,makeMidSide4,4,.3) : lrsomma)
                : par(i,2,*(checkbox("[0]input")):*(volumePlus)), par(i,2,*(checkbox("1")):*(volumePlus)), par(i,2,*(checkbox("2")):*(volumePlus));
volumePlus = nentry("vol",1,1,9,0.1):si.smoo;
*/