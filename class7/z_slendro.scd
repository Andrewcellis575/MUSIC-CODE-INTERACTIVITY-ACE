
// 12-tone equal temperament - this is a Tuning object
t = Tuning.et12;
t.semitones;  // Works: returns [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]
t.ratios;     // Works: returns [ 1, 1.0594630943591, 1.1224620483089, ... ]

// calcET returns an Array, not a Tuning object
v = Tuning.calcET(5);  // Returns [ 0.0, 2.4, 4.8, 7.2, 9.6 ]
// These semitone values represent the 5 equal divisions of the octave

// To get a proper Tuning object with 5-ET
~slendro = Tuning.new(Tuning.calcET(5));
~slendro.semitones;  // Now this should work
~slendro.ratios;     // Now this should work
~slendro.cents

// Play sine waves using all ratios from the tuning
{
    Mix.new(SinOsc.ar(261.625565 * v.ratios, 0, 0.5 / v.ratios.size))
}.play;

(
p = Pbind(
    \instrument, \default,
    \degree, Pseq((0..v.ratios.size-1), inf),
    \dur, 0.25,
    \freq, Pfunc({ |ev| 100 * v.ratios[ev.degree] }),
    \amp, 0.3,
    \legato, 0.8
).play;
)

// To stop
p.stop;