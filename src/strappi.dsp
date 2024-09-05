import("stdfaust.lib");
import("StrappiLibraryAIP.lib");
import("mspan.lib");
import("schroederAllpass.lib");


timeRMS = 0.1;
timePeak = .1;
//-----------------------------------------------------------------------------
//  VARIABLE FOR TESTING THE CALIBRATION OF SOME FUNDAMENTAL PARAMETERS
tr=hslider("treshold", -25, -40, -10, 1):si.smoo;
q_HolderTime=hslider("peak holder time Q", 2, 2, 6, 0.1):si.smoo;
deg_HolderTime=hslider("peak holder time degree", .5, .5, 6, 0.1):si.smoo;
freq_HolderTime=hslider("peak holder time devfreq", 6, 2, 10, 0.1):si.smoo;
//-----------------------------------------------------------------------------
pkTresh = tr : ba.db2linear;
timeAvgPeakCounter=4;

//----------------
// Calibration
// process = input : inputMid <: rmsInputVis(timeRMS) , peakInputVis(timePeak), picchiMediaInputVis(timePeak,pkTresh,timeAvgPeakCounter,2);
//----------------


//================================================================================================================
mappingQfilter6(secCounter) = ma.E^frequenzaPicchi(timePeak,pkTresh,secCounter,2)*2: _+400 : _ ,1000 : min : peakHolder(3) : integrator(0.3);
mappingQfilter5(secCounter) = ma.E^frequenzaPicchi(timePeak,pkTresh,secCounter,2)*2: _+200 : _ ,1000 : min : peakHolder(3) : integrator(0.3);
//================================================================================================================

fDev(freqDev,in) = freqDev;
fDev2(freqDev,in) = freqDev+(freqDev/2)*(movingAverageRMS(.05,in):peakHolder(6));
fDev3(freqDev,in) = freqDev+(freqDev/15)*(peakenvelope(.2,in):peakHolder(6));

//----------------
radianFun(secCounter,sec,in) = in : frequenzaPicchi(timePeak,pkTresh,secCounter,1)^2.3 ;
radianFun2(in) = in <: (movingAverageRMS(.1)*50 : integrator(1.2));
makeMidSide4(i,degI,in) = in : mspan(.6,((ma.signum(degI)*((abs(degI)+radianFun(.5,2,in)+radianFun2(in)^2)*2)*ma.PI/180)));
//----------------
inNoiseBank = par(i,6,inNoise) ;
inNoise = (no.noise*0.5);
noiseFbkBank2(fdev,freqDev,fbTime,fbgI,qFilBank,in) = (si.bus(6) : bpDelEnv(fbTime,fbgI)), (inNoiseBank : bpBankFmul(fdev(freqDev,in),qFilBank)) : routingEnv;
chord2 = \(fx,fx2,degI,mside,tSec,gainRev, in).((in <: fx,_), si.bus(6) : fx2 : par(i,6,mside(i,degI)):> si.bus(2)  : _, combApf(tSec,gainRev): sdmx);
//----------------


//----------------
routingEnv(i1,i2,i3,i4,i5,i6,e1,e2,e3,e4,e5,e6) = i1*e1,i2*e2,i3*e3,i4*e4,i5*e5,i6*e6;
lrsomma = \(l1,r1,l2,r2).(l1+l2,r1+r2);
busser = si.bus(7);
multichord = busser <: par(i,4,busser) : 
                        chord2(mappingQfilter5(1.5),noiseFbkBank2(fDev3,.8,0.01,0.5),270,makeMidSide4,1,.3),
                        chord2(mappingQfilter5(1.5),noiseFbkBank2(fDev,.8,.01,0.5),-90,makeMidSide4,1,.3),
                        chord2(mappingQfilter6(1.7),noiseFbkBank2(fDev3,1.4,0.1,0),90,makeMidSide4,4,.3),
                        chord2(mappingQfilter6(1.5),noiseFbkBank2(fDev,1.4,0.05,0),-269,makeMidSide4,4,.3) : par(i,2,lrsomma);
//----------------


//process = 0;

interruttori=si.bus(6):par(i,2,*(checkbox("[0]input")):*(volumePlus)), par(i,2,*(checkbox("1")):*(volumePlus)), par(i,2,*(checkbox("2")):*(volumePlus));
volumePlus = nentry("vol",1,1,9,0.1):si.smoo;
process=input, si.block(4) <: _,_ , (inputMid <: _, bpBankPeakEnv : multichord) : interruttori;