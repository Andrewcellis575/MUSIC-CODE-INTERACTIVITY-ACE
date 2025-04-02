s.boot;
s.makeWindow;

().play

( freq:[440*(1/1),(5/4)] ).play;

(midinote: {60+1.0.xrand2}.dup(100)).play;

e = (sustain: 4, freq: [69, 73].midicps).play
// major triad in 12 tempered tuning

f = (sustain: 4, freq: {440 * [1/1, 5/4]}).play
//major triad in just

{SinOsc.ar(200)}.play;


{ SinOsc.ar([60, 63].midicps, 0, 0.5) }.play;
//
{ SinOsc.ar(261.625565*[1/1, 7/6], 0, 0.5) }.play;
{ SinOsc.ar(261.625565*[1/1, 6/5], 0, 0.5) }.play;

(
a = NodeProxy.new.play; // play to hardware output.
a.fadeTime = 1; // fadeTime specifies crossfade
a.source = { }; // set the source

) // start your engines, A is empty!

a.source = { }; // start your engines, A is empty!


a.source = { SinOsc.ar([350, 351.3], 0, 0.2) };

a.source = { SinOsc.ar(350*[1/1, 6/5], 0, 0.2) };

a.source = { SinOsc.ar(350*1/1, 0, 0.2) };

a.scope;
a.source = { LFPulse.ar(350*[1/1, 3/2], 0, 0.5, 0.2) }; //change to square

a.source = { LFTri.ar(350*[1/1, 3/2], 0, 0.5, 0.2) }; //change to square

a.source = { LFSaw.ar(350, 0, 0.2) }; // change to sawtooth

(a.source =
{ var volume, pitch;
	volume = MouseY.kr(0, 1, 0);
	pitch = MouseX.kr(5, 300);
	LFSaw.ar(pitch, 0, volume);};

) // add a volume knob...using a veriable

a.source = { LFSaw.ar(MouseX.kr(1,200)*[1/1, 3/2], 0, 0.2) }; // change interval

a.source = { LFSaw.ar(MouseX.kr(10,50), 0, 0.9) };  // show rhythm LFO

a.source = { LFSaw.ar(Line.ar(0.1, 50, 10)*[1/1, 3/2], 0, 0.2) };  // slide rhythm to pitch

a.source = { LFSaw.ar(MouseX.kr(1, 100, 10)*[1/1, 5/4, 7/4], 0, 0.2) };  // slide rhythm to pitch w cursor

a.source = { Blip.ar(100*[1/1, 1/1], (MouseX.kr(1,16,0)), 0.5)}; // slide XY to show different overtones over fundamental

a.source = { Blip.ar(100, (MouseX.kr(1,32,0)), 0.5)};  //try more overtones

a.source = { LFPulse.ar((MouseX.kr(1,32,0).round(1))*100, 0, 0.5, 0.1)};  //try more overtones


a.free;

a.source = { };

a.scope;

//let's do control voltage

//the following examples applies one wave to the pitch of another.

//first we will change volume.
//we do this by MULTIPLYING one waveform by another
(
a.source = {
	var pitch, mod, tempo, intensity;
	tempo = MouseX.kr(0, 60);
	intensity = MouseY.kr(0, 1);
 	mod = SinOsc.ar(tempo, 0, intensity);
	pitch = SinOsc.ar(440, 0, 1 * mod);
	pitch;
	};
)

//actually the version below has an OFFSET that i rather link that is more functional.
(
a.source = {
	var pitch, mod, tempo, intensity;
	tempo = MouseX.kr(0, 60);
	intensity = MouseY.kr(0, 0.5);
 	mod = SinOsc.ar(tempo, 0, intensity);
	pitch = SinOsc.ar(440, 0, 0.5 + mod);
	pitch;
	};
)

//now we will change pitch.
//the key is that the root of the first oscillators pitch is ADDED with the offset of another
//this is called FREQUENCY modulation.
(
a.source = {
	var pitch, mod, tempo, intensity;
	tempo = MouseX.kr(0, 30);
	intensity = MouseY.kr(0, 400);
 	mod = SinOsc.ar(tempo, 0, intensity);
	pitch = SinOsc.ar(440+mod, 0, 0.6);
	pitch;
	};
)



