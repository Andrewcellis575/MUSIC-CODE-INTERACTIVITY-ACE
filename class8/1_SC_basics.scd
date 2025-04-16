//Welcome to SuperCollider!

//SuperCollider is a text-based computing environment for musical coding and sound processing.
//SuperCollider is open source! It's easy to hack, embed, free, & runs on any system. Files are small, gives us powerful sounds with very little memory.

//SuperCollider has two different programs inside it that operate simultaneously.

//We're now inside the interpreter. To make sound, we send data to the server, which is the black box that calculates everything for us.

//this is how you boot the server
Server.default.boot;
//or for short
s.boot;

//select the code and Evaluate it by running command+period.

//SuperCollider is Object-Oriented, which means it's made up of over 2000 constructs that do different things. Those objects, always in capital letters, have different ways of doing things, called methods.

//think of it like Nouns or Verbs. The Class is the noun, and the methods are all the things it can do.

Date.getDate;

//Date is the Object, and .getDate is the method we run on it, and semicolon ends the line.
//select the code and Evaluate it by running command+period.

//now let's make sound
 // to make any sound, you have to turn on the server
s.boot;

(midinote:70).play;  //simplest possible sound event in Supercollider!

(midinote:[65,50,70]).play; //picking chords

{PinkNoise.ar(0.1)}.play; // put a synthesis function inside

//you gotta shut it off! command period

{SinOsc.ar(440)}.play; //evaluate with command + return, turn off by doing command + period

{SinOsc.ar(440)}.freqscope;
{SinOsc.ar(440)}.scope;

{SinOsc.ar(MouseX.kr(40,4000),0,MouseY.kr(0,1))}.scope; //already this is getting kind of hard to read


(
t =
{
	var mx = MouseX.kr(40,4000);
	var slow = MouseX.kr(0.1,10);
	var my = MouseY.kr(0,1);
	var lfo = MouseY.kr(1,1000);
	var offset = MouseX.kr(200,4000);
	var modulator = SinOsc.ar(slow, 0, lfo, offset);
	var sound = SinOsc.ar(modulator,0, 1);
	sound;
};
)

x = t.scope



//let's create the global variable w, dummy variable for the thing we made

//let's have one sine wave controlling pitch and another controlling rhythm
( w =
	{
	var pitch = exprand(70, 3000); //so we need a few local variables in our synthesis function
	var rhythm = exprand(1, 5);
	var pulse = SinOsc.ar(rhythm)*0.1;
	SinOsc.ar(pitch, 0, pulse);
	};
)

x = w.play; //x is now a new circuit that allows us to turn on the previous thing
x.release;  // and off  without completely losing the thing.

//random is a special attribute because everytime you run this patch it picks a new note

//but these systems aren't efficient because it involves shutting down the whole processing chain.

//so we need a better container for our soundmaker

//this container called a node proxy.  it represents an arbitrary signal on the audio server than can be redefined infinitely.
//we'll return to this container anytime we want to set up a signal on the server for complex chains of interactions

(
~np = NodeProxy.new.play;
~np.fadeTime=1;
)
//make sure you evaluate it

~np = NodeProxy.new.play.fadeTime_(2).source_(nil); //is the same as above


//
(~np[0..10]= {
	var pitch = exprand(60, 3000);
	var harm = rrand(1, 32);
	var rhythm = exprand(1, 5);
	var pulse = LFTri.ar(harm*0.4).range(0,0.1);
	//var sig = SinOsc.ar(harm*100, 0, pulse);
    var sig = SinOsc.ar(pitch*1, 0, pulse); //less harmonically related
	sig = sig * 0.4;
	};
)

~np.play; //actually our node didn't disappear!
~np[0..10]=nil; //if we want to fade out all ten at once.

( ~np[0..60] =
	{
	var pitch = exprand(60, 3000);
	//var harm = rrand(1, 32);
	var rhythm = exprand(0.4, 8);
	var pulse = LFTri.ar(rhythm)*0.4;
	var pulse2 = LFTri.ar(rhythm/1.5)*0.4;
	SinOsc.ar(pitch, 0, pulse*pulse2);
	};
)

~np.source=nil
//let's introduce a new modulator, LFNoise1
//here's a totally different approach using a random low frequency ramp to change pitch


( ~np[0..5] =
	{
	var rhythm = exprand(0.4, 8);
	var pitch = LFNoise1.ar(0.1*rhythm).exprange(1,100); //exprange sets range as unipolar!
	var pulse = LFTri.ar(rhythm).range(0,0.1);
	SinOsc.ar(20*pitch, 0, pulse);
	};
)




~np[0..23]=nil;
~np.removeLast;

//now lets make some of these controls accessible arguing the parameter type called argument.

~np= NodeProxy.new.play;

( ~np[0..5] =
	{
	|lofreq=0.1, freak=40|
	var rhythm = exprand(0.4, 3);
	var pitch = LFNoise1.ar(lofreq*rhythm).exprange(1,freak);
	var pulse = LFTri.ar(rhythm).range(0,0.1);
	LFTri.ar(50*pitch, 0, pulse);
	};
)

~np.guil


~np = NodeProxy.new.play.fadeTime_(2).source_(nil);
~np.play; // or just this!

(
~np[0]={
  var snare, bdrum, hihat;
  var tempo = 8;

  tempo = Impulse.ar(tempo);
  snare = PinkNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 4, 2), 0.005, 0.5));
  bdrum = LFSaw.ar(Line.ar(120,60, 1), 0, Decay2.ar(PulseDivider.ar(tempo, 4, 0), 0.005, 0.5));
  hihat = HPF.ar(WhiteNoise.ar(1), 10000) * Decay2.ar(tempo, 0.005, 0.5);
 (snare + bdrum + hihat) * 0.2 ! 2;
}
)

(
~np[1..10] = { |widefreq = 4, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
	var a, f;
	lo = lo * exprand(1, 200);
	hi = hi * exprand(1, 200);
	f = LFClipNoise.kr(widefreq*IRand(2,8)).range(lo, hi);
	a = LFTri.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
};
)

~np.removeLast;
~np[0..23]=nil;

~np.source.freqscope;
~np.source.scope;