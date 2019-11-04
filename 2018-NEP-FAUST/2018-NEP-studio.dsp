//--------------------------------------------------------------------------------------------------
// 2018 - GIUSEPPE SILVI - GRAZIE. LUCI E RABBIA. SPAZIO.
//--------------------------------------------------------------------------------------------------

declare name "nulla è pari, per clarinetto basso e olofoni";
declare version "0.1";
declare author "Giuseppe Silvi";
declare copyright "Giuseppe Silvi 2018";
declare license "BSD";
declare reference "giuseppesilvi.com";
declare description "AMBIENTE ESECUTIVO";

import("math.lib");
import("music.lib");
import("filter.lib");

mt2samp = *(ma.SR/VS);

vmeter(x)	= attach(x, envelop(x) : vbargraph("[unit:dB]", -70, 0));
hmeter(x)	= attach(x, envelop(x) : hbargraph("[unit:dB]", -70, 0));
  envelop = abs : max(db2linear(-70)) : linear2db : min(10)  : max ~ -(80.0/SR);

d = hslider("speaker distance (m)", 0.5, 0.1, 10, 0.1);
x = hslider("x (m)", 0,0,10,0.1) : smooth(tau2pole(0.001));
y = hslider("y (m)", 1,1,100,0.1) : smooth(tau2pole(0.001));
nSpeakers = 7;

Quad(x) = x * x;
D(d,i,x,y) = Quad(x - (i - 1) * d) + Quad(y) : sqrt;

// amplitude assignments:
Amp(d,i,x,y,sig) = sig / D(d,i,x,y);
OutA(d,1,x,y,sig) = Amp(d,1,x,y,sig);
OutA(d,i,x,y,sig) = OutA(d,i-1,x,y,sig), Amp(d,i,x,y,sig);

// delay amount assignments:
R(d,i,x,y) = fdelay1s(D(d,i,x,y) * SR / 343); // questo delay è antico, vedi delay.lib per lagrange.
OutR(d,1,x,y) = R(d,1,x,y);
OutR(d,i,x,y) = OutR(d,i-1,x,y), R(d,i,x,y);

// sequence composition:
Out(d,n,x,y,sig) = OutA(d,n,x,y,sig) : OutR(d,n,x,y) ;

process = vgroup("[0] Source Position", Out(d,nSpeakers,x,y)) :
          vgroup("[1] - - - - - OUT - OLOFONI - - - - -", hmeter, hmeter, hmeter, hmeter, hmeter, hmeter, hmeter);
