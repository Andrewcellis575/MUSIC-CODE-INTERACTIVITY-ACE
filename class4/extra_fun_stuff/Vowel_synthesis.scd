//from melany!

(
a = NodeProxy.new.play;
a.fadeTime=2;
a.source = { };
)


(
a.source=
{ var v = Vowel.compose(
	[\a, \e, \i, \o],
	[\soprano, \bass, \tenor, \alto],
	({10.rand}!5).normalizeSum
);
Formants.ar(50 + 300.rand, v) * 0.1;
}
)

a[0..3] = { var v = Vowel.compose(
    [\a, \e, \i, \o],
    [\soprano, \bass, \tenor, \alto],
    ({10.rand}!5).normalizeSum
);
Formants.ar(60.midicps + 24.rand, v) * 0.1;
}


a[0..12] = {nil}

(

(
a.source =
{ // even odd harmonics
	var baseFreq = 10;
	var numFreqs = 79;
	var vowel = Vowel(\a, \bass);
	var startFilterOrder = 4.0;
	var stopFilterOrders = [0.8, 0.65, 0.5, 0.35, 0.1];
	var freqs, evenFreqs, oddFreqs, amps, evenAmps, oddAmps, orders;
	var dur = 40;
	var evenAmpMod = SinOsc.kr(freq: 1).exprange(0.04, 1).sqrt;
	var oddAmpMod = SinOsc.kr(freq: 1, phase: pi).exprange(0.04, 1).sqrt;

	evenFreqs = ((1, 3 .. numFreqs) * baseFreq);
	oddFreqs = ((2, 4 .. numFreqs) * baseFreq);


	// there are 5 formants in each vowel, ergo 5 filter orders may be provided
	orders = stopFilterOrders.collect{|stop, i|
		XLine.kr(startFilterOrder, stop, dur * ( 4 + (2 * i)/dur))
	};

	evenAmps = vowel.ampAt(evenFreqs, orders ) * evenAmpMod;
	oddAmps = vowel.ampAt(oddFreqs, orders ) * oddAmpMod;


	freqs = evenFreqs ++ oddFreqs;
	amps = evenAmps ++ oddAmps;

	amps = amps.normalizeSum; // tame amplitudes

	DynKlang.ar(`[freqs, amps , n=il] ) * 0.1 ;
}
)


Formants.ar()