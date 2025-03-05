/////////////////////////////////////
// 1. Granular Pad Synth (SynthDef)
/////////////////////////////////////
(
SynthDef(\granularPad, {
    arg out=0, freq=220, amp=0.5, spread=0.5, grainRate=20;
    var source, env, grains, filter;

    source = Saw.ar(freq, amp) * LFNoise1.kr(0.2).range(0.5, 1);
    env = EnvGen.kr(Env.perc(0.1, 1.5), doneAction: 2);
    grains = GrainSin.ar(2, Impulse.kr(grainRate), 0.1, freq, spread);
    filter = LPF.ar(grains * env * amp, 1000) + HPF.ar(grains * env * amp, 200);

    Out.ar(out, filter);
}).add;
)

/////////////////////////////////////
// 2. Glitch Percussion (NodeProxy)
/////////////////////////////////////
(
~glitchPerc = NodeProxy.audio(s, 2);
~glitchPerc.source = {
    var trig, kick, snare, hat, mix;
    trig = Dust.kr(10);
    kick = SinOsc.ar(60, 0, Decay.kr(trig, 0.2));
    snare = WhiteNoise.ar(Decay.kr(trig, 0.1));
    hat = HPF.ar(WhiteNoise.ar(Decay.kr(trig * 2, 0.05)), 5000);
    mix = Mix([kick, snare, hat]) * 0.5;
    Pan2.ar(mix, LFNoise1.kr(1));
};
~glitchPerc.play;
)

/////////////////////////////////////
// 3. Morphing Bass Synth (Ndef)
/////////////////////////////////////
(
Ndef(\morphBass, {
    arg freq=80, modFreq=0.5, amp=0.8;
    var sig, mod;
    mod = SinOsc.kr(modFreq).range(0.8, 1.2);
    sig = Saw.ar(freq * mod) + SinOsc.ar(freq * mod, 0, 0.3);
    sig = sig.tanh * amp;
    sig = Pan2.ar(sig, SinOsc.kr(0.1));
}).play;
)

/////////////////////////////////////
// 4. Atmospheric Melody (Ndef)
/////////////////////////////////////
(
Ndef(\atmosMelody, {
    arg vol=0.5, speed=1, reverb=0.5;
    var sig, melody;
    melody = SinOsc.ar(Demand.kr(Impulse.kr(speed), 0, Dseq([400, 500, 600, 700, 800], inf)), 0, vol);
    sig = FreeVerb.ar(melody, mix: reverb, room: 0.8, damp: 0.5);
    sig = Pan2.ar(sig, SinOsc.kr(0.1));
}).play;
)

/////////////////////////////////////
// GUI Interface
/////////////////////////////////////
(
Window.new("Synth Controls", Rect(100, 100, 300, 450)).front.do {
    |win|
    var freqSlider, modSlider, ampSlider, grainRateSlider, spreadSlider, glitchPercSlider, glitchVolSlider, melodyVolSlider, melodySpeedSlider, melodyReverbSlider;
    StaticText(win, Rect(10,10,280,20)).string = "Morphing Bass Controls";
    freqSlider = Slider(win, Rect(10, 40, 280, 20)).action_({
        |s| Ndef(\morphBass).set(\freq, s.value.linexp(0,1,40,200))
    });
    modSlider = Slider(win, Rect(10, 70, 280, 20)).action_({
        |s| Ndef(\morphBass).set(\modFreq, s.value.linexp(0,1,0.1,5))
    });
    ampSlider = Slider(win, Rect(10, 100, 280, 20)).action_({
        |s| Ndef(\morphBass).set(\amp, s.value.linlin(0,1,0,1))
    });
    StaticText(win, Rect(10,130,280,20)).string = "Granular Pad Controls";
    grainRateSlider = Slider(win, Rect(10, 160, 280, 20)).action_({
        |s| Synth(\granularPad, [\grainRate, s.value.linexp(0,1,5,50)])
    });
    spreadSlider = Slider(win, Rect(10, 190, 280, 20)).action_({
        |s| Synth(\granularPad, [\spread, s.value.linlin(0,1,0,1)])
    });
    StaticText(win, Rect(10,220,280,20)).string = "Glitch Percussion Controls";
    glitchPercSlider = Slider(win, Rect(10, 250, 280, 20)).action_({
        |s| ~glitchPerc.set(\trigRate, s.value.linexp(0,1,1,20))
    });
    glitchVolSlider = Slider(win, Rect(10, 280, 280, 20)).action_({
        |s| ~glitchPerc.set(\amp, s.value.linlin(0,1,0,1))
    });
    StaticText(win, Rect(10,310,280,20)).string = "Atmospheric Melody Controls";
    melodyVolSlider = Slider(win, Rect(10, 340, 280, 20)).action_({
        |s| Ndef(\atmosMelody).set(\vol, s.value.linlin(0,1,0,1))
    });
    melodySpeedSlider = Slider(win, Rect(10, 370, 280, 20)).action_({
        |s| Ndef(\atmosMelody).set(\speed, s.value.linexp(0,1,0.1,5))
    });
    melodyReverbSlider = Slider(win, Rect(10, 400, 280, 20)).action_({
        |s| Ndef(\atmosMelody).set(\reverb, s.value.linlin(0,1,0,1))
    });
};
)
