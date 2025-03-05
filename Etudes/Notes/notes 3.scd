// Boot the server
s.boot;

// Define SynthDefs
SynthDef(\leadSynth, {
    arg freq = 440, amp = 0.3, gate = 1;
    var env, sig;

    env = Env.adsr(0.1, 0.2, 0.8, 0.5).kr(doneAction:2);
    sig = SinOsc.ar(freq, 0, amp) * env;

    Out.ar(0, sig!2);
}).add;  // <- FIXED: Ensuring .add; at the end

SynthDef(\perc, {
    arg amp = 0.5, decay = 0.3;
    var env, sig;

    env = Env.perc(0.01, decay).kr(doneAction:2);
    sig = WhiteNoise.ar(amp) * env;

    Out.ar(0, sig!2);
}).add;  // <- FIXED: Ensuring .add; at the end

SynthDef(\padSynth, {
    arg freq = 220, amp = 0.3, gate = 1;
    var env, sig;

    env = Env.adsr(1.0, 1.0, 0.7, 2.0).kr(doneAction:2);
    sig = Saw.ar(freq, amp) * env;

    Out.ar(0, sig!2);
}).add;  // <- FIXED: Ensuring .add; at the end

// Create GUI
(
var win, playButton, freqSlider, ampSlider, padFreqSlider, padAmpSlider, percButton;
var playing = false;

win = Window("Virtual Instruments", Rect(200, 200, 400, 300)).front;
win.view.background = Color.gray(0.2);

// Play/Stop Button
playButton = Button(win, Rect(20, 20, 100, 30))
    .states_([["Play", Color.green], ["Stop", Color.red]])
    .action_({ |btn|
        if (playing.not, {
            playing = true;
            NDef(\leadSynth, { SinOsc.ar(NDef(\leadSynth).kr(\freq, 440), 0, NDef(\leadSynth).kr(\amp, 0.3)) }).play;
            NDef(\padSynth, { Saw.ar(NDef(\padSynth).kr(\freq, 220), NDef(\padSynth).kr(\amp, 0.3)) }).play;
            btn.value = 1;
        }, {
            playing = false;
            NDef(\leadSynth).stop;
            NDef(\padSynth).stop;
            btn.value = 0;
        });
    });

// Lead Synth Frequency Slider
StaticText(win, Rect(20, 60, 120, 20)).string_("Lead Synth Frequency:");
freqSlider = Slider(win, Rect(20, 80, 300, 20))
    .value_(0.5)
    .action_({ |s| NDef(\leadSynth).set(\freq, s.value.linexp(0, 1, 100, 1000)) });

// Lead Synth Amplitude Slider
StaticText(win, Rect(20, 110, 120, 20)).string_("Lead Synth Amplitude:");
ampSlider = Slider(win, Rect(20, 130, 300, 20))
    .value_(0.3)
    .action_({ |s| NDef(\leadSynth).set(\amp, s.value.linlin(0, 1, 0.1, 1)) });

// Pad Synth Frequency Slider
StaticText(win, Rect(20, 160, 120, 20)).string_("Pad Frequency:");
padFreqSlider = Slider(win, Rect(20, 180, 300, 20))
    .value_(0.5)
    .action_({ |s| NDef(\padSynth).set(\freq, s.value.linexp(0, 1, 100, 500)) });

// Pad Synth Amplitude Slider
StaticText(win, Rect(20, 210, 120, 20)).string_("Pad Amplitude:");
padAmpSlider = Slider(win, Rect(20, 230, 300, 20))
    .value_(0.3)
    .action_({ |s| NDef(\padSynth).set(\amp, s.value.linlin(0, 1, 0.1, 1)) });

// Percussion Trigger Button
percButton = Button(win, Rect(20, 260, 120, 30))
    .states_([["Hit Percussion"]])
    .action_({ Synth(\perc, [\amp, 0.7, \decay, 0.3]) });

// Ensure everything stops when the window closes
win.onClose = {
    NDef(\leadSynth).stop;
    NDef(\padSynth).stop;
    playing = false;
};
)
