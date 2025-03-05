s.boot;

(
var a, c, d, s, z, y;
d = 6; // number of percolators
c = 6; // number of comb delays
a = 4; // number of allpass delays

b = NodeProxy.new; // create NodeProxy without direct output
b.fadeTime = 10; // set fade time

// Set initial source for NodeProxy b
b.source = {Mix.ar(Array.fill(d, { Resonz.ar(Dust.ar(2/d, 50), 200 + 3000.0.rand, 0.003)}) )};
	//	b.source = {Decay.ar(Dust.ar(12 / d, 0.2), 0.15, PinkNoise.ar)};


// Now create the main processing chain that uses NodeProxy b
b = b.play;


// Main processing chain
(
    play({
        // Get the source from NodeProxy b
        var source = b.ar;

        // Reverb predelay time
        z = DelayN.ar(source, 0.048);

        // 6 modulated comb delays in parallel
        y = Mix.ar(CombL.ar(z, 0.1, LFNoise1.kr(Array.fill(c,{0.1.rand}), 0.04, 0.05), 15));

        // Chain of 4 allpass delays on each of two channels (8 total)
        a.do({ y = AllpassN.ar(y, 0.050, [0.050.rand,0.050.rand], 1) });

        // Add original sound to reverb and play it
        source + y
    })
);

)

b.fadeTime = 1; // set fade time


// Example: After some time, switch to a different source, make sure to update any variables that you use.
(
var d;
d=12;
b.source = {Decay.ar(Dust.ar(12 / d, 0.2), 0.15, PinkNoise.ar)};
)

(
var d;
d=20;
b.source = {Mix.ar(Array.fill(d, { Resonz.ar(Dust.ar(2/d, 50), 200 + 3000.0.rand, 0.003)}) )};
)

//or you can declare a global variable like this ~d.


// Clear NodeProxy b after 3 seconds if needed
b.clear(3);
)


/////the following is not really any different is just uses a global variable, ~d, so you don't have to energize that variable with each declaration of nodeproxy.

s.boot;

(
var a, c, s, z, y;
~d = 6; // Set the global variable
c = 6; // number of comb delays
a = 4; // number of allpass delays

b = NodeProxy.new; // create NodeProxy without direct output
b.fadeTime = 10; // set fade time

// Set initial source for NodeProxy b using the global variable
b.source = {
    Mix.ar(Array.fill(~d, { Resonz.ar(Dust.ar(2/~d, 50), 200 + 3000.0.rand, 0.003)}) )
};

// Now create the main processing chain that uses NodeProxy b
b = b.play;

// Main processing chain
(
    play({
        // Get the source from NodeProxy b
        var source = b.ar;

        // Reverb predelay time
        z = DelayN.ar(source, 0.048);

        // 6 modulated comb delays in parallel
        y = Mix.ar(CombL.ar(z, 0.1, LFNoise1.kr(Array.fill(c,{0.1.rand}), 0.04, 0.05), 15));

        // Chain of 4 allpass delays on each of two channels (8 total)
        a.do({ y = AllpassN.ar(y, 0.050, [0.050.rand,0.050.rand], 1) });

        // Add original sound to reverb and play it
        source + y
    })
);
)

b.fadeTime = 3; // set fade time

// Example: After some time, switch to a different source
(	 ~d=1;
	b.source = {    Decay.ar(Dust.ar(12 / ~d, 0.2), 0.15, PinkNoise.ar)};)

// Clear NodeProxy b after 3 seconds if needed
b.clear(3);

/////

/* Assignment #1:Add to the program variables named
	r1, r2 for the rates of mod1 and mod2
	g 		for the rate of the main glissando
	delay	for the duration of the delay
	decay	for how long an echo takes to fade away

All you need to do is to add the following line at the top of the synthesis function:

var r1,r2,g,delay,decay;

Assign each variable the value used in the original program ((i.e., 8, 7.23, 0.4, 0,2, 4)
Then make four copies of the patch and change those values to create different sounds

*/

(
{
	var k, f, a, mod1, mod2;
	mod1 = LFSaw.kr(2);
	mod1 = mod1.range( 60, 84);

	mod2 = LFSaw.kr(7.2);					// define the second modulator
	mod2 = mod2.range( 78, 84);

	k = LFSaw.kr(0.4) * 2 + [mod1, mod2];	// use the second modulator
	f = k.midicps;
	a = SinOsc.ar(f) * 0.04;
	CombN.ar(a, 0.2, 0.2, 4)
}.play
)

/*Assignment #2:
Select your favorite variant and use the Env class to create an envelope so that it
plays for a fixed duration and falls silent.  (You will play this in class.)
Below is an example you can draw upon.

*/

(
{ var levels, times, doneAction, env, a;
	// THIS IS JUST THE TEST SOUND
	a = PinkNoise.ar;
	a = RLPF.ar(a, [500, 400], 0.01).softclip * 0.01;

	// HERE IS THE ENVELOPE
	doneAction = 2;				// when the envelope finishes, it will dispose of the synth
	levels = [0,1,1,0];			// envelope will begin at 0 go to 1, stay there and then decay
	times = [2, 5, 1];			// 0 to 1: 20 seconds, 1 to 1: 3 seconds, 1 to 0: 0.1 seconds
	env = Env(levels, times);	// define the envelope
	env = env.kr(doneAction);	// make it run as a UGen
	env = env.lincurve(0, 1, 0,4, 3); // read the SimpleNumber helpfile discussion of lincurve

	// applying the envelope to the sound
	a = env * a;
}.play;
)
