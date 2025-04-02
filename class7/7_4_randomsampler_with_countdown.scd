//you might need to evaluate this twice! timming operations delay this a few times from finding all the buffers if the server isn't booted.'
//first, run this, it sets up the directory inside whatever this file is saved inside.
(
//~dirpath = "MySounds/*".resolveRelative; //when you load up a folder, you gotta have the slash after it!
~dirpath = "piano and accordian/*".resolveRelative; //this folder also sounds good for these examples.
~filepaths = ~dirpath.pathMatch;
//~buffers = ~filepaths.collect { |path|  Buffer.read(s, path) };
~buffers = ~filepaths.collect { |path|  Buffer.readChannel(s, path, channels: [0]);};

// Make sure the server is booted first
//s.options.maxSynthDefs = 2048;  // Default is often 1024
s.boot;



// Wait until server is ready, then create and use the NodeProxy
s.waitForBoot({
  ~np = NodeProxy.audio(s, 2);
  // Set some audio content before playing
  ~np.source = nil;
  // Now play it
  ~np.play;
});


~checkAndClearServer = {
    // Check if we're getting close to the SynthDef limit
    var defCount = s.numSynthDefs;
    var maxDefs = s.options.maxSynthDefs;

    if(defCount > (maxDefs * 0.9)) { // If we're at 90% capacity
        "WARNING: SynthDef count high (%/%), clearing NodeProxy...".format(defCount, maxDefs).postln;
		~np[2..1024]=nil;
        0.1.wait; // Give the server a moment to process the clearing
        "NodeProxy cleared.".postln;
        true
    } {
        false
    };
};


// Define the slow section
~slow = {
    var totalEvents = 50;
    "Starting slow section (%/% events)...".format(totalEvents, totalEvents).postln;

    totalEvents.do { |i|
        var eventsLeft = totalEvents - i;
        var buf = ~buffers.choose;

        // Post countdown for every event
        "Slow section: % events remaining".format(eventsLeft).postln;

        ~np.add({
            Pan2.ar(
                PlayBuf.ar(buf.numChannels, buf.bufnum,
                    rate: (1..12).choose.midiratio,
                    doneAction: 2) * rrand(-40, 0).dbamp,
                Rand(-1.0, 1.0)
            )
        });
        (buf.duration/4).wait;
    };

    "Slow section complete.".postln;
};

// Define the speedy section
~fast = {
    var totalEvents = 100;
    "Starting speedy section (%/% events)...".format(totalEvents, totalEvents).postln;

    totalEvents.do { |i|
        var eventsLeft = totalEvents - i;
        var buf = ~buffers.choose;

        // Post countdown for every event
        "Speedy section: % events remaining".format(eventsLeft).postln;

        ~np.add({
            Pan2.ar(
                PlayBuf.ar(buf.numChannels, buf.bufnum,
                    rate: (1..12).choose.midiratio,
                    doneAction: 2) * rrand(-40, 0).dbamp,
                Rand(-1.0, 1.0)
            )
        });
        rrand(0.05, 0.3).wait;
    };

    "Speedy section complete.".postln;
};

~glitchy= {
    var totalEvents = 100;
	"Starting glitchy section (%/% events)...".format(totalEvents, totalEvents).postln;
	totalEvents.do { |i|
		var eventsLeft = totalEvents - i;
            var buf = ~buffers.choose;
            var rate = [-2, -1, 1, 2, 4].choose; //negative rates play backward. may result in some frames dropped. see earlier example for hack to fix
            var start = rrand(0, 0.8);

		 // Post countdown for every event
        "glitchy section: % events remaining".format(eventsLeft).postln;

            ~np.add({
                Pan2.ar(
                    PlayBuf.ar(buf.numChannels, buf.bufnum,
                        rate: rate,
                        startPos: start * buf.numFrames,
                        doneAction: 2) * rrand(-30, -5).dbamp,
                    Rand(-1.0, 1.0)
                )
            });
            rrand(0.1, 0.4).wait;
        };
        "Glitchy section complete.".postln;
    }
;

~newglitchy= {
    var totalEvents = 100;
	"Starting newglitchy section (%/% events)...".format(totalEvents, totalEvents).postln;
	totalEvents.do { |i|
	    var eventsLeft = totalEvents - i;
        var buf = ~buffers.choose;
		var dir = [-1, 1].choose;
        var rate = [-2, -1, 1, 2, 4].choose; //negative rates play backward. may result in some frames dropped. see earlier example for hack to fix
		var startPosi; //added a feature for reverse playback
	    if(dir < 0) { // If playing backward, start near the end of the buffer
        startPosi = buf.numFrames * 0.9; // Start at 90% through the buffer
		}
		{ //else
        startPosi = 0;   // If playing forward, start at the beginning
		};

		 // Post countdown for every event
        "newglitchy section: % events remaining".format(eventsLeft).postln;

            ~np.add({
                Pan2.ar(
                    PlayBuf.ar(buf.numChannels, buf.bufnum,
                        rate: rate,
                        startPos: startPosi,
                        doneAction: 2) * rrand(-30, -5).dbamp,
                    Rand(-1.0, 1.0)
                )
            });
            rrand(0.1, 0.4).wait;
        };
        "newGlitchy section complete.".postln;
    }
;

~slendroglitchy={
    var totalEvents = 100;
	"Starting slendroglitchy section (%/% events)...".format(totalEvents, totalEvents).postln;
	~waitTime = 0.1;
	~slendro = Tuning.new(Tuning.calcET(5));
        totalEvents.do { |i|
		var eventsLeft = totalEvents - i;
		var buf = ~buffers.at(0);
            var start = rrand(0, 0.8);
			var tuningIndex = (0..~slendro.ratios.size-1).choose;  // Choose a random index from the 5-ET tuning
			var rate = ~slendro.ratios[tuningIndex];  // Use the ratio from your 5-ET tuning
		    var octaverate = [-2, -1, 1, 2, 4].choose; //negative rates play backward. may result in some frames dropped. see earlier example for hack to fix
			var amp = rrand(-40, 0).dbamp; //random dynamics
            ~np.add({
                Pan2.ar(
                    PlayBuf.ar(buf.numChannels, buf.bufnum,
                        rate: rate,
                        startPos: start * buf.numFrames,
                        doneAction: 2) * amp,
                    Rand(-1.0, 1.0)
                )
            });
		   "slendro section: % events remaining".format(eventsLeft).postln;
        rrand(0.1, 0.4)*~waitTime.wait;
        };
        "SLENDROglitchy section complete.".postln;
    };



~solo = {
    var totalEvents = 100;
    var eventsLeft, buf, ping;  // Declare all variables at the beginning
    "Starting SOLO section (%/% events)...".format(totalEvents, totalEvents).postln;
    totalEvents.do { |i|
        eventsLeft = totalEvents - i;
        buf = ~buffers[7..9].choose;
        "SOLO section: % events remaining".format(eventsLeft).postln;
		ping = {
			var mouse =  MouseX.kr(0.01, 0.2);
            var signal = PlayBuf.ar(
                buf.numChannels,
                buf.bufnum,
                rate: (1..12).choose.midiratio,
                doneAction: 2
            ) * rrand(-20, 0).dbamp;
            // Apply processing within the function
            signal = Wrap.ar(signal, -1*mouse, mouse) * 7;
            signal = Limiter.ar(signal, 0.7, 0.01);
            Pan2.ar(signal, Rand(-1.0, 1.0))
        };
		~np.add(ping);
        rrand(0.01, 0.25).wait;
    };

    "SOLO section complete.".postln;
};





// Create the looping task
~loopingTask = Task({
    inf.do { |cycle|

	 //Play newGlitchy section
		~newglitchy.value;
		~checkAndClearServer.value;

		//play Glitchy section
	//	~glitchy.value;

        // Play slow section
      //  ~slow.value;

        // Play fast section
        //~fast.value;

		//play the SOLO section
		//~solo.value;

		//play the SLENDRO section
		~slendroglitchy.value;

		~checkAndClearServer.value;
    };
});

// Simple controls
~start = {
    if(~loopingTask.isPlaying.not) {
        ~loopingTask.play;
        "Starting the loop...".postln;
    } {
        "The loop is already running.".postln;
    };
};

~stop = {
    if(~loopingTask.isPlaying) {
        ~loopingTask.stop;
        "Stopping the loop...".postln;
    } {
        "The loop is not running.".postln;
    };
};

~reset = {
	~loopingTask.reset;
 "U have reset the loop".postln;
};


// Show instructions
"SIMPLE CONTROLS:".postln;
"~start.value - Start the loop".postln;
"~stop.value - Stop the loop".postln;
)

~start.value
~stop.value
~reset.value
~np.source=nil  //run this in case your server overflows
