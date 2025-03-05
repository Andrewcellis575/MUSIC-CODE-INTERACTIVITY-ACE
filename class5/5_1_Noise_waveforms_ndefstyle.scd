// Basic noise generators
Ndef(\noise).play;
Ndef(\noise).gui;
w = Ndef(\noise).gui;  // Store GUI reference
w.parent.front;    // Access the window through .parent
w.parent.alwaysOnTop_(true);  // Set always on top on the parent window

// Different noise sources
Ndef(\whitenoise, { |amp| WhiteNoise.ar * amp.dup }).gui;
// Alternative syntax, equivalent to above
Ndef(\pinknoise).source = { |amp| PinkNoise.ar * amp.dup };
Ndef(\brownnoise, { |amp| BrownNoise.ar * amp.dup });
Ndef(\dustnoise, { |amp, widefreq = 4| Dust.ar(widefreq) * amp.dup });

(q = NdefMixer(s); //define the mixer
q.parent.alwaysOnTop_(true); // show mixer in front of IDE
s.boot;
q.switchSize(2);)

Ndef(\noise).gui
// LF Noise variants with SinOsc

Spec.add(\lo, \freq);
Spec.add(\hi, \freq);

// LFClipNoise version
Ndef(\newnoise, { |widefreq = 30, lo = 200, hi = 200|
    var f = LFClipNoise.ar(widefreq).range(lo, hi);
    SinOsc.ar(f) * 0.1.dup
});

// With envelope control
Ndef(\envelopenoise, { |widefreq = 30, lo = 200, hi = 200, attack = 0.1, decay = 0.1|
    var a, f;
    f = LFClipNoise.kr(widefreq).range(lo, hi);
    a = SinOsc.ar(f) * 0.1;
    a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
    a.dup;
});

// LFNoise0 version
Ndef(\LFNoisey0, { |widefreq = 30, lo = 200, hi = 200, attack = 0.1, decay = 0.1 |
	var a, f;
	f = LFNoise0.kr(widefreq).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
	a.dup;
});
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
