//evaluate the entire block, here:

// Let's get some other sound files into buffers
(
~dirpath = "MySounds/*".resolveRelative; //when you load up a folder, you gotta have the slash after it!
//~dirpath = "piano and accordian/*".resolveRelative; //this folder also sounds good for these examples.
~filepaths = ~dirpath.pathMatch;
//~buffers = ~filepaths.collect { |path|  Buffer.read(s, path) }; //THIS LINE ACCEPTS STEREO
~buffers = ~filepaths.collect { |path|  Buffer.readChannel(s, path, channels: [0]);};//THIS LINE FORCES MONO

// Make sure the server is booted first
s.boot;

// Wait until server is ready, then create and use the NodeProxy
s.waitForBoot({
  ~np = NodeProxy.audio(s, 2);
  // Set some audio content before playing
  ~np.source = nil;
  ~np.play;
});

)

/*
Now, ~buffers is an array object that contains Buffer objects that represent soundfiles downloaded by the server.
Arrays respond to the message 'choose' by returning one of their elements at random
So, we can use that method to play a random sound file
take note of the last line.
some of you have stereo sound files. this is an easy hack to read only the first channel if you want to mix mono files w stereo for this lesson.
you can take it out if you need to, or you can modify the structure for stereo.
*/



(~np[0] = {
	var buf = ~buffers.choose;
	var rate=1;
	var sig;
	Pan2.ar
				(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate,  doneAction: 2),
				Rand(-1.0, 1.0) //panning left to right randomly
				);
		};
);


//added a feature to pick between two different buffers
(~np[0] = {
    // Create an array with just buffers at index 0 and 2
	var buf = [~buffers[0], ~buffers[1]].choose;
    var rate = 1;
    var sig;

    Pan2.ar(
        PlayBuf.ar(buf.numChannels, buf.bufnum, rate: rate, doneAction: 2),
        Rand(-1.0, 1.0) // panning left to right randomly
    );
};
)

//
(~np[0] = {
    var buf = ~buffers[7..9].choose; //or randomly pick from one of the first three files in the array.
    var rate = 1;

    Pan2.ar(
        PlayBuf.ar(buf.numChannels, buf.bufnum, rate: rate, doneAction: 2),
        Rand(-1.0, 1.0) // panning left to right randomly
    );
};
)

//by the way, one style of coding is to declare each variable as you introduce them,
//instead of all at once at the top. you need to decide which style makes sense.

//just having fun! a sampler player connected to dust.
(~np[0..12] =
{ | lofreq=1|
    var trig = Dust.ar(lofreq);  // Random trigger w controllable argument
	var buf = ~buffers.at(3);
	var notes = (1..37).asArray;
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
~np.gui
~np[0..24]=nil;
~np.removeLast

(~np[0] = {
	var buf = ~buffers.choose;
	var rate = (0..12).choose.midiratio;// It randomly selects an integer between 0 and 12.It then converts this integer to a frequency ratio as if it were a MIDI note number difference.
	var amp = 1.0;
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate,  doneAction: 2) * amp,
				Rand(-1.0, 1.0)
			)
		};
)

//lets talk about a few details. what if we want to use a particular note and focus on it?
(~np[0] = {
	var buf = ~buffers.at(6); //just pick a particular note so we can hear the changes.
	var rate = (0..12).choose.midiratio; // you can change the width of the array to easily expand octaves
	var octave = [1,0.5,0.25].choose;
	var amp = rrand(-40, 0).dbamp; //added a feature for random dynamics. very important—we don't want everyting to be at the same volume.
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate*octave, doneAction: 2) * amp,
				Rand(-1.0, 1.0)
			)
		};
)



(~np[0] = {
	var buf = ~buffers.choose; //just pick a particular note so we can hear the changes.
	var dir = [-1, 1].choose;
	var rate = dir * (0..24).choose.midiratio; // you can change the width of the array to easily expand octaves
	var amp = rrand(-40, 0).dbamp; //added a feature for random dynamics. very important—we don't want everyting to be at the same volume.
	var startPosi; //added a feature for reverse playback
	    if(dir < 0) {
        // If playing backward, start near the end of the buffer
        // This is better than exactly at the end (buf.numFrames - 1)
        startPosi = buf.numFrames * 0.9; // Start at 90% through the buffer
    } {
        // If playing forward, start at the beginning
        startPosi = 0;
    };
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate, startPos: startPosi, doneAction: 2) * amp,
				Rand(-1.0, 1.0)
			)
		};
)


Tuning.directory
~slendro = Tuning.new(Tuning.calcET(5));
//this little piece of code defines a new variable, slendro, to be a 5 tone equal temperament scale.

(~np[0] = {
	var buf = ~buffers.at(5); //just pick a particular note
	var tuningIndex = (0..~slendro.ratios.size-1).choose;  // Choose a random index from the 5-ET tuning
	var rate = ~slendro.ratios[tuningIndex];  // Use the ratio from your 5-ET tuning
	var amp = rrand(-20, 0).dbamp; //random dynamics
	Pan2.ar(
		PlayBuf.ar(buf.numChannels, buf.bufnum, rate: rate, doneAction: 2) * amp,
		Rand(-1.0, 1.0)
	)
};
)


//just having fun! a sampler player connected to dust.tuned to slendro.
//the main difference here is that since i am using synth side controls (ie, controlling the triggering through dust) i need to use synth side objects like TRand.ar and Texprand.
//i don't want to use these retriggering nodeproxies for the rest of this assignment but i will this away for next time i'm improvising with the class
(~np[0..] =
{ | lofreq=1|
	var trig, buf, tuningIndex, rate, rateMultiplier, amp, pan;
    trig = Dust.ar(lofreq);  // Random trigger w controllable argument
	buf = ~buffers.choose;
	tuningIndex = (0..~slendro.ratios.size-1).choose;  // Choose a random index from the 5-ET tuning
	rate = ~slendro.ratios[tuningIndex];  // Base ratio from your slendro tuning
    rateMultiplier = [1, 0.5, 2].choose;  // Possible rate multipliers
    rate = rate * rateMultiplier;  // Final playback rate
	amp = TExpRand.ar(0.01, 1, trig);  // New amplitude on each trigger (-40dB to 0dB)
    pan = TRand.ar(-1.0, 1.0, trig);  // New pan position on each trigger.
	//TRand is a triggered random number generator. TexpRand is the same but exponential for gain.
    Pan2.ar(
        PlayBuf.ar(
            buf.numChannels,
            buf.bufnum,
			rate: rate,
            trigger: trig,  // Retrigger the sample on each Dust impulse
            doneAction: 0   // Don't free the synth when sample finishes
        ) * amp,
        pan     // This will only randomize once when the synth starts
    );
};
)
~np.gui
~np[0..10]={nil}

//going back to the simple approach, single triggers evaluated each time np~[0] runs
(~np[0] = {
    var buf = ~buffers.choose;
    var notesPerOctave = ~slendro.ratios.size;  // Number of notes in your scale (5)
    var note = (0..11).choose;  // Choose a random note number from 0 to 24
    var octave = note.div(notesPerOctave);
    var index = note % notesPerOctave;  // Which note within the octave (0-4)
    // Calculate rate: base ratio × octave multiplier
    var rate = ~slendro.ratios[index] * (2 ** octave);
    var amp = rrand(-40, 0).dbamp;
    Pan2.ar(
        PlayBuf.ar(buf.numChannels, buf.bufnum, rate: rate, doneAction: 2) * amp,
        Rand(-1.0, 1.0)
    )
};
)





Now, what we would like to do is make a shuffle play program.
To do that, we need a means of choosing and playing a soundfile, waiting until it finishes playing and then doing that again.
Buffers respond to the 'duration' method with their duration.

But, to play something, wait and play something again, we need a souped up form of a function provided by the class Task
and the timing facilities of the class TempoClock.

A Task is a function that can stop running using the method 'wait' and then resume running immediately after
wherever that 'wait' in the function definition.  A TempoClock provides the actual timing control to run the task
wait the appropriate amount of time and rerun it.

Here is a simple example:

~np[0] = Task({
	"1 mississippi".postln; 1 .wait;
	"2 mississippi".postln; 1 .wait;
	"3 mississippi".postln; 1 .wait;
	"4 mississippi".postln; 1 .wait;
})


~np[1] =  Task(
	{ var buf, rate, amp, wat;
	 buf =  ~buffers.choose;
	 rate = (0..12).choose.midiratio;
	 amp = 0.8;
	~np[0] = {
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate,  doneAction: 2) * amp,
				Rand(-1.0, 1.0)
			)
		};
	buf.duration.wait;
	buf =  ~buffers.choose;
   rate = (0..12).choose.midiratio;
		~np[0] = {
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate,  doneAction: 2) * amp,
				Rand(-1.0, 1.0)
			)
		};
	buf.duration.wait
})
// This is pretty inefficient.
//all that code just to do two things!

// instead we can use loop to do this autmatically:
~np[1] =  Task({ var buf, rate, amp;
	loop {
		buf =  ~buffers.choose;
		rate = (0..12).choose.midiratio;
		amp = 0.1;
		~np[0] = {
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate,  doneAction: 2) * amp,
				Rand(-1.0, 1.0)
			)
		};
		buf.duration.wait;
	}
});
//now this sample player plays infinitely.

~np[1]=nil

//let's just tweak it so we can control density.

(
~waitTime=0.1;
~np[1] =  Task({
	var buf, rate, amp;
	loop {
		buf =  ~buffers.choose;
		rate = (0..12).choose.midiratio;
		amp = 0.1;
		~np[0] = {
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: rate,  doneAction: 2) * amp,
				Rand(-1.0, 1.0)
			)
		};
	rrand(0.05, 0.013).wait
	}
});
)



//using global variable like ~waitTime.wait means you can change it dynamically.
~waitTime=1

~np[1]=nil

//Now we would like to create a set of sections.

//Happily, NodeProxy has an 'add' method that lets us add in synthesis functions
//without replacing others.

//In this example the duration of the file is divided by 4, so there tend to be four or more sound files playing at the same time.
//Of course the decaying nature of the sound files is important to the sonic restulr

~np[0] = Task({
	var buf;
	"first, the super speedy section".postln;
	50.do { |i | i;
		buf = ~buffers.choose;
		~np.add({
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: (1..12).choose.midiratio, doneAction: 2) * rrand(-40, 0).dbamp,
				Rand(-1.0, 1.0)
			)
		});
		rrand(0.01, 0.018).wait
	};
	"now, the speedy section".postln;
	100.do { | i |
	buf = ~buffers.choose;
	~np.add({
			Pan2.ar(
				PlayBuf.ar(buf.numChannels,buf.bufnum, rate: (1..12).choose.midiratio, doneAction: 2) * rrand(-40, 0).dbamp,
				Rand(-1.0, 1.0)
			);
		});
		rrand(0.05, 0.3).wait
	};
	"done!".postln;
});


