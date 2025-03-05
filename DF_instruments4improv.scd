//Some instruments i like

//frog simulator

~frogs = NodeProxy.audio(s, 2);  // audio rate NP running on the default server with two internal channels
~frogs.fadeTime = 2; //let's define the fadetime
~frogs.source = {nil}; //test it, make sure it works.
~frogs.play // whoops, forgot to fire it
~frogs.free //let's free it. the source is still loaded inside the nodeproxy.


~frogs[1..4]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(1,10)*pitch, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};
// adding some basic controls.i'm just messing around here, but these are attributed to all channels inside the nodeproxy of N.
//so it's kind of like master controls.

~frogs.gui

///same story but now the instrument can work with your own sound files.
~peepers = NodeProxy.audio(s, 2).play;

~peepers.source= nil; //fade out all the crickets!
~peepers.source={ };

~b = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/whineTRILL.wav");
~c = Buffer.read(s,"/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxHH_4.wav");
~b.play
~c.play
~d = Buffer.read(s,"/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/skeleton_bones.wav");

~peepers.gui
~peepers[0..10]={nil}

~peepers[0..8]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix, samp;
	samp=~b;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = PlayBuf.ar(numChannels: samp.numChannels,
		bufnum: samp,
		rate: rrand(1,10)/600*pitch*BufRateScale.kr(samp),
		loop: 1,
	)*frog1*frog2;
	out = Pan2.ar(sig, 1.0.rand2);
	out = out*20;
};

~peepers.gui


//twosteps

~twosteps = NodeProxy.audio(s, 2).play;

~twosteps[0..2] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
	var a, f;
	lo = lo * exprand(1, 200);
	hi = hi * exprand(1, 200);
	f = LFClipNoise.kr(widefreq*rrand(0.1, 4.0)).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
	a.dup;
};

~twosteps.gui

//////////////////
let's do the sound file version
//first we need a buffer
~b0 = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxCHORD.wav");
~b0.play

//set up a NodeProxy
~twosteps = NodeProxy.audio(s, 2).play;

// Modified version using PlayBuf
(~twosteps[0..3] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
    var audio, mod;
    lo = lo * exprand(1, 200);
    hi = hi * exprand(1, 200);

    // Instead of direct frequency modulation, we'll use rate multiplication
    mod = LFClipNoise.kr(widefreq * rrand(0.1, 4.0)).range(lo/440, hi/440);

    // PlayBuf replaces SinOsc
    audio = PlayBuf.ar(
        numChannels: ~b0.numChannels,
        bufnum: ~b0,
        rate: mod * BufRateScale.kr(~b0), //bingo!
        loop: 1
    ) * 0.1;

    // Keep the amplitude envelope
    audio = Linen.kr(abs(Slope.kr(mod)), attack, 1, decay) * audio;
    audio.dup;
};
)

~twosteps[0..12]=nil
~twosteps.gui


////
(
//~dirpath = "MySounds/*".resolveRelative; //when you load up a folder, you gotta have the slash after it!
~dirpath = "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class7/piano and accordian/".resolveRelative;
 //this folder also sounds good for these examples.
  ~filepaths = PathName(~dirpath).entries.collect(_.fullPath);
~buffers = ~filepaths.collect { |path|  Buffer.read(s, path) };
~buffers = ~filepaths.collect { |path|  Buffer.readChannel(s, path, channels: [0]);};
// Make sure the server is booted first
s.boot;

// Wait until server is ready, then create and use the NodeProxy
s.waitForBoot({
  ~dusty = NodeProxy.audio(s, 2);
  // Set some audio content before playing
  ~dusty.source = { nil };
  // Now play it
  ~dusty.play;
});
)

(~dusty[0..10] =
{ | lofreq=1|
    var trig = Dust.ar(lofreq);  // Random trigger w controllable argument
    var buf = ~buffers.choose;
	var notes = (1..12).asArray;
    // Use the trigger to start the sample playback
    Pan2.ar(
        PlayBuf.ar(
            buf.numChannels,
            buf.bufnum,
			rate: notes.midiratio.choose,
            trigger: trig,  // Retrigger the sample on each Dust impulse
            doneAction: 0   // Don't free the synth when sample finishes
        ),
        Rand(-1.0, 1.0)     // This will only randomize once when the synth starts
    );
};
)
~dusty.gui
~dusty[0..10]={nil}
~dusty.removeLast








////////////

// Frog Simulator using SynthDef instead of NodeProxy

// Define a SynthDef for our frog sound
SynthDef(\frogSound, {
    arg out=0, max=8, pitch=200, pan=0, amp=0.5;
    var frog1, frog2, sig;

    // The same sound generation from the original example
    frog1 = Mix.ar(SinOsc.ar(exprand(0.3, max) * [rrand(0.7, 1.3), 1], [2pi.rand, 2pi.rand], 0.1)).max(0);
    frog2 = Mix.ar(SinOsc.ar(exprand(6, 24) * [rrand(0.7, 1.3), 1], [2pi.rand, 2pi.rand], 0.1)).abs;
    sig = SinOsc.ar(rrand(1, 10) * pitch, 2pi.rand, frog1 * frog2);

    // Output with panning and amplitude control
    Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;

// Create a control for number of frog instances
~numFrogs = 5; // Default starting value

// Create a group to contain all our frog synths
~frogGroup = Group.new;

// Array to store synth IDs
~frogSynths = Array.newClear(20); // Max capacity of 20

// Function to update the number of frogs
~updateFrogs = {
    arg num;
    var currentNum = ~frogSynths.count({ |synth| synth.notNil });

    // If we need to add frogs
    if(num > currentNum, {
        (num - currentNum).do({ |i|
            var index = currentNum + i;
            // Create new frog synth with randomized parameters
            ~frogSynths[index] = Synth(\frogSound, [
                \max, rrand(4.0, 12.0),
                \pitch, rrand(100.0, 300.0),
                \pan, rrand(-1.0, 1.0),
                \amp, rrand(0.3, 0.7)
            ], ~frogGroup);
        });
    });

    // If we need to remove frogs
    if(num < currentNum, {
        (currentNum - num).do({ |i|
            var index = currentNum - i - 1;
            // Free the synth and remove from array
            ~frogSynths[index].free;
            ~frogSynths[index] = nil;
        });
    });

    // Return the new number of frogs
    ~numFrogs = num;
};

// Create a GUI to control the number of frogs
~frogGUI = {
    var window, slider, numberBox, startButton, stopButton;

    window = Window("Frog Control", Rect(200, 200, 300, 150));

    // Create a slider to adjust number of frogs
    slider = Slider(window, Rect(20, 20, 200, 20))
        .value_(~numFrogs/20)
        .action_({ |sl|
            var num = (sl.value * 20).round.asInteger;
            numberBox.value = num;
            ~updateFrogs.(num);
        });

    // Number box to display/set frog count
    numberBox = NumberBox(window, Rect(230, 20, 50, 20))
        .value_(~numFrogs)
        .clipLo_(1)
        .clipHi_(20)
        .action_({ |nb|
            slider.value = nb.value/20;
            ~updateFrogs.(nb.value.asInteger);
        });

    // Start button - initializes with current frog count
    startButton = Button(window, Rect(20, 60, 100, 30))
        .states_([["Start Frogs"]])
        .action_({
            // Free any existing synths first
            ~frogGroup.freeAll;
            ~frogSynths = Array.newClear(20);

            // Create the initial frogs
            ~updateFrogs.(~numFrogs);
        });

    // Stop button
    stopButton = Button(window, Rect(130, 60, 100, 30))
        .states_([["Stop Frogs"]])
        .action_({
            ~frogGroup.freeAll;
            ~frogSynths = Array.newClear(20);
        });

    // Parameter sliders for all frogs
    StaticText(window, Rect(20, 100, 100, 20)).string_("Max:");
    Slider(window, Rect(120, 100, 160, 20))
        .value_(0.5)
        .action_({ |sl|
            var maxVal = sl.value.linexp(0, 1, 2, 20);
            ~frogGroup.set(\max, maxVal);
        });

    StaticText(window, Rect(20, 125, 100, 20)).string_("Pitch:");
    Slider(window, Rect(120, 125, 160, 20))
        .value_(0.5)
        .action_({ |sl|
            var pitchVal = sl.value.linexp(0, 1, 50, 500);
            ~frogGroup.set(\pitch, pitchVal);
        });

    window.front;
};

// Initialize the frog group
~frogGroup = Group.new;

// Run the GUI
~frogGUI.value;

// Cleanup function when you want to stop everything
~cleanupFrogs = {
    ~frogGroup.free;
    ~frogSynths = nil;
};

// To clean up when done
// ~cleanupFrogs.value;
