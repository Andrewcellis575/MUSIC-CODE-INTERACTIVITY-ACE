// First, boot the server
s.boot;

// Define the SynthDefs for four different sounds
(
SynthDef(\sound1, {
    var sig = SinOsc.ar(440) * EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);
    Out.ar(0, sig ! 2);
}).add;

SynthDef(\sound2, {
    var sig = Saw.ar(220) * EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);
    Out.ar(0, sig ! 2);
}).add;

SynthDef(\sound3, {
    var sig = Pulse.ar(330) * EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);
    Out.ar(0, sig ! 2);
}).add;

SynthDef(\sound4, {
    var sig = WhiteNoise.ar * EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);
    Out.ar(0, sig ! 2);
}).add;
)

// Create a window for key input
(
w = Window("Keyboard Interface", Rect(200, 200, 400, 100));
w.view.keyDownAction = { |view, char, modifiers, unicode, keycode|
    case
    { char === $a } { Synth(\sound1) }
    { char === $s } { Synth(\sound2) }
    { char === $d } { Synth(\sound3) }
    { char === $f } { Synth(\sound4) };
};
w.front;
)

// To stop all sounds and close the window
// w.close;