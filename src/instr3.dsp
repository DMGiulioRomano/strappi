import("stdfaust.lib");
import("StrappiLibraryAIP.lib");
import("mspan.lib");
import("schroederAllpass.lib");


timeRMS = 0.1;
timePeak = .1;
//-----------------------------------------------------------------------------
//  VARIABLE FOR TESTING THE CALIBRATION OF SOME FUNDAMENTAL PARAMETERS
tr=hslider("[0]treshold", -25, -40, -10, 1):si.smoo;
q_HolderTime=hslider("peak holder time Q", 2, 2, 6, 0.1):si.smoo;
deg_HolderTime=hslider("peak holder time degree", .5, .5, 6, 0.1):si.smoo;
freq_HolderTime=hslider("peak holder time devfreq", 6, 2, 10, 0.1):si.smoo;
degI2 = 0-hslider("degre rms", 12, -180, 180 , 1): si.smoo;
//-----------------------------------------------------------------------------
pkTresh = tr : ba.db2linear;
timeAvgPeakCounter=4;

//----------------
// Calibration
// process = input : inputMid <: rmsInputVis(timeRMS) , peakInputVis(timePeak), picchiMediaInputVis(timePeak,pkTresh,timeAvgPeakCounter,2);
//----------------


//================================================================================================================
mappingQfilter8(secCounter) = ma.E^frequenzaPicchi(timePeak,pkTresh,secCounter,2)*2:  _+700 : _ ,1000 : min : peakHolder(3) : integrator(0.3);
mappingQfilter7(secCounter) = movingAverageRMS(.5)*20: *(350):  _+500 : _ ,1000 : min : peakHolder(3) : integrator(0.3);
mappingQfilter6(secCounter) = ma.E^frequenzaPicchi(timePeak,pkTresh,secCounter,2)*2: _+400 : _ ,1000 : min : peakHolder(5) : integrator(0.3);
mappingQfilter5(secCounter) = ma.E^frequenzaPicchi(timePeak,pkTresh,secCounter,2)*2: _+200 : _ ,1000 : min : peakHolder(5) : integrator(0.3);
//================================================================================================================

fDev(freqDev,in) = freqDev;
fDev2(freqDev,in) = freqDev+(freqDev/2)*(movingAverageRMS(.05,in):peakHolder(6));
fDev3(freqDev,in) = freqDev+(freqDev/15)*(peakenvelope(.4,in):peakHolder(6));

//----------------
radianFun(secCounter,sec,in) = in : frequenzaPicchi(timePeak,pkTresh,secCounter,1)^2  : *(degI1) : min(degI1);
radianFun2(in) = in <: (movingAverageRMS(.1)*50 : integrator(1.2)) : /(2): *(degI2) :  min(degI2);
makeMidSide4(i,degI,in) = in : mspan(pp,((ma.signum(degI)*((abs(degI)+radianFun(2,2,in)+radianFun2(in))*2)*ma.PI/180)));

makeMidSide(i,degI,in) = in : mspan(pp,(degI*i+((movingAverageRMS(0.5)*20)*degI2)):si.smoo);
//----------------
inNoiseBank = par(i,6,inNoise) ;
inNoise = (no.noise*0.5);
noiseFbkBank2(fdev,freqDev,fbTime,fbgI,qFilBank,in) = (si.bus(6) : bpDelEnv(fbTime,fbgI)), (inNoiseBank : bpBankFmul2(fdev(freqDev,in),qFilBank, lfoFreq)) : routingEnv;
chord2 = \(fx,fx2,degI,mside,tSec,funtSec,gainRev, in).((in <: fx,_), si.bus(6) : fx2 : par(i,6,mside(i,degI)):> si.bus(2)  : _, combApf(funtSec(tSec,in),gainRev): sdmx);
chordDeb = \(fx,fx2,degI,mside,tSec,funtSec,gainRev, in).((in <: fx,_), si.bus(6) : fx2) ;
//----------------

funtSec(tSec) = tSec + _*0;
funtSec1(secCounter,tSec) = frequenzaPicchi(timePeak,pkTresh,secCounter,1) : max(1) : min(tSec);
funtSec2(tSec) = movingAverageRMS(.1)*50 : max(1) : min(tSec) : integrator(3): peakHolder(3) : integrator(1.5);
//funtSec2(tSec) = 0;
//process = input : inputMid <: funtSec2;
//----------------
routingEnv(i1,i2,i3,i4,i5,i6,e1,e2,e3,e4,e5,e6) = i1*e1,i2*e2,i3*e3,i4*e4,i5*e5,i6*e6;
lrsomma = \(l1,r1,l2,r2).(l1+l2,r1+r2);
busser = si.bus(7);


ampAcuto = frequenzaPicchi(timePeak,pkTresh,3,1) : min(1);
ampGrave =  movingAverageRMS(.5)*10 : integrator(1.5) : min(1);
inviluppiFbk(amp) =  par(i,2,_*amp);

ideOut= si.bus(6):> si.bus(2);
interruttori=si.bus(6):par(i,2,*(checkbox("[0]input")):*(volumePlus)), par(i,2,*(checkbox("1")):*(volumePlus)), par(i,2,*(checkbox("2")):*(volumePlus));
interruttori_noInput=si.bus(4): par(i,2,*(checkbox("1")):*(volumePlus)), par(i,2,*(checkbox("2")):*(volumePlus));
volumePlus = nentry("vol",1,1,9,0.1):si.smoo;






sequencer2 = \(fx,fx2,fx3,degI,mside,tSec,gainRev,in).
    ( in <: (fx,(_ <: _,bpBankPeakEnv)): fx2 );//: ba.selectxbus(1,6, ma.SR/20,fx3(in)));//:mside(fx3(in),degI): _, combApf(tSec,gainRev) : sdmx);
chooser(in) = rilevatorePicchi(0.1,pkTresh), no.noise : ba.sAndH : abs : *(6) : int;
//process = chooser;
//============================
//
degI1 = 0-hslider("degre peak", -3, -180, 180 , 1) : si.smoo;
scaleFreq = hslider("freq SCALER", 1.4, 0.1, 1.6, 0.01): si.smoo;
pp = hslider("polar pattern", .5, 0, 1 , 0.01);
timeReverb = hslider("time reverb", 3, 1, 12, 0.01): si.smoo;
lfoFreq = hslider("freq LFO", 1, .2, 10, 0.01): si.smoo;
//============================
inGain =hslider("[1]gain In", 1, 0, 4, 0.01): si.smoo;
gainReverb = hslider("gain Rev", 0.4, 0, 1, 0.001): si.smoo;

smistatoreChord(amp, in) = in, si.bus(6) : chord2(mappingQfilter8(1.5),noiseFbkBank2(fDev3,scaleFreq,0.01,0.5), degI1,makeMidSide,timeReverb,funtSec,gainReverb);

process=input :inputMid*inGain <: (ampGrave+0), _, bpBankPeakEnv :  smistatoreChord : par(i,2, fi.dcblockerat(8)): par(i,2,LookaheadLimiter(1,.01,0.1)) :output;
//process=input: inputMid : mappingQfilter5(1.5);;
// : interruttori_noInput :> si.bus(2) :par(i,2, fi.dcblockerat(8)): par(i,2,LookaheadLimiter(1,.01,0.1)) :output;
//process=input: inputMid : mappingQfilter5(1.5);

smistatoreSeq(amp) = sequencer2(mappingQfilter6(1.5),noiseFbkBank2(fDev3,scaleFreq,.02,0.43),chooser,degI1,makeMidSide, timeReverb,.2) ;
//process = input : inputMid <: (ampGrave+0), _ : smistatoreSeq;


a(in) = si.bus(6) : ba.selectxbus(1,6, ma.SR/20,chooser(in));
//process= si.bus(7) : a;
//process=chooser;
//process=mappingQfilter8(1.5);
