Here are some noise generators
WhiteNoise
PinkNoise
BrownNoise
Dust.ar(density: 0)

n = NodeProxy.audio(s, 2).play;

//you remember what this means. we're using the global variable n as a placeholder
//

n.gui;
w = n.gui;  // This returns an NdefGui
w.parent.front;    // Access the window through .parent
w.parent.alwaysOnTop_(true);  // Set always on top on the parent window


n[0] = { | amp | WhiteNoise.ar * amp.dup };
//remember, n[0] is just putting an infinite input channel mixer array at the source of n. you could also just say0 :

 = { | amp | PinkNoise.ar * amp.dup };
//it's the same thing.

//you could ALSO use the convention Ndef to create a global synth on the server instead of just a local varible
//like this:
Ndef(\noise);
//which you can play
Ndef(\noise).play;
//or see
Ndef(\noise).gui;
Ndef(\noise).clear;
//and then fill with information
Ndef(\noise, { |amp, freq| RLPF.ar(WhiteNoise.ar, freq, 0.5, amp.dup )});
//this is exactly like using a synthdef, but simpler, no output needed.
n[0] = { | amp |  BrownNoise.ar * amp.dup };
n[0] = { |amp, widefreq = 4|  Dust.ar(widefreq) * amp.dup };

These generate random signals of different sorts at a controllable frequency
LFClipNoise.ar(freq: 500)
LFNoise0.ar(freq: 500 )
LFNoise1.ar(freq: 500 )
LFNoise2.ar(freq: 500 )

n = NodeProxy.audio(s, 2).play;
n.gui;
Spec.add(\lo, \freq);
Spec.add(\hi, \freq);

n[0] = { |widefreq = 30, lo = 200, hi = 200 |
	var f = LFClipNoise.ar(widefreq).range(lo, hi);
	LFSaw.ar(f ) * 0.1.dup
};

n[0] = { |widefreq = 30, lo = 200, hi = 200, attack = 0.1, decay = 0.1 |
	var a, f;
	f = LFClipNoise.kr(widefreq).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
	a.dup;
};

//can you adapt this with randomized for multichannel iteration over the break?

n = NodeProxy.audio(s, 2).play;

n[0..7] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
	var a, f;
	lo = lo * exprand(1, 200);
	hi = hi * exprand(1, 200);
	f = LFClipNoise.kr(widefreq*rrand(0.1, 4.0)).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
	a.dup;
};
//


n.gui
n.source = nil

n[0] = { |widefreq = 30, lo = 200, hi = 200, attack = 0.1, decay = 0.1 |
	var a, f;
	f = LFNoise0.kr(widefreq).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
	a.dup;
};
//show the difference LFNoise shapes!

n[0] = { |widefreq = 30, lo = 200, hi = 200, attack = 0.1, decay = 0.1 |
	var a, f;
	f = LFNoise1.kr(widefreq).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
	a.dup;
};

//show the difference LFNoise shapes!

n[0] = { |widefreq = 30, lo = 200, hi = 200, attack = 0.1, decay = 0.1, thresh = 1000.1 |
	var a, f;
	f = LFNoise2.kr(widefreq).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)) > thresh, attack, 1, decay) * a;
	a.dup;
};

//they all have unique parameters

Here are UGens that generate static waveforms
LFSaw
LFTri
LFPulse
Impulse
LFGauss  //the  argument is period rather than frequency
{ [ LFSaw.ar, LFTri.ar, LFPulse.ar,  Impulse.ar, LFGauss.ar(duration: 1/500, width: 0.1),]}.plot;

Here are UGens that generate waveforms that can change their shape
VarSaw
SyncSaw
Formant
Blip
{[ VarSaw.ar(width: Line.kr(0.01, 0.99, 0.015)),
	SyncSaw.ar(Line.kr(400, 600, 0.02), 700),
	Formant.ar(440,Line.kr(1720, 3500, 0.02) ),
	Blip.ar(1500,Line.kr(1,8, 0.02))]
}.plot(0.02)

// Here are some "chaotic" generators.  These have finicky parameters.
Crackle.ar(chaosParam:1.5)  // range from 1 to 2
Logistic.ar(chaosParam: 3.5)   // range 3.42 to 4.0
Spec.add(\lseed, [3.42, 4.0, 'exp'])

n[0] = { | amp, seed = 1.5|  Crackle.ar(seed.min(2).max(1)) * amp.dup };
n[0] = { | amp, lseed = 1.5|  Logistic.ar(lseed) * amp.dup };
n[0] = { | amp, seed = 1.5, prat = 20 |
	var audio;
	audio = Crackle.ar(seed.min(2).max(1));
	PitchShift.ar( audio, pitchRatio:  prat) * amp.dup
};


