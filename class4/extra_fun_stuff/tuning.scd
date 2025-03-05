t = Tuning.et12;
t.semitones;
t.ratios;        // [ 1, 1.0594630943591, 1.1224620483089, 1.1892071150019, etc. ]

Pbind(\scale, Scale.kurd(t), \degree, Pseq((0..12) ++ (11..0) ++ [\rest], 1), \dur, 0.15).play;

t = Tuning.just;
t.semitones;        // [ 0, 1.1173128526978, 2.0391000173077, 3.1564128700055, etc. ]
t.ratios.collect(_.round(0.001));    // [ 1, 1.067, 1.125, 1.2, 1.25, 1.333, 1.406, 1.5, etc. ]
​
Pbind(\scale, Scale.major(t), \degree, Pseq((0..7) ++ (6..0) ++ [\rest], 1), \dur, 0.25).play;

Tuning.directory
Scale.directory