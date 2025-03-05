//you might need to evaluate this twice!
//first, run this, it sets up the directory inside whatever this file is saved inside.
(
//~dirpath = "MySounds/*".resolveRelative; //when you load up a folder, you gotta have the slash after it!
~dirpath = "piano and accordian/*".resolveRelative; //this folder also sounds good for these examples.
~filepaths = ~dirpath.pathMatch;
~buffers = ~filepaths.collect { |path|  Buffer.read(s, path) };
~buffers = ~filepaths.collect { |path|  Buffer.readChannel(s, path, channels: [0]);};

// Make sure the server is booted first
s.boot;

// Wait until server is ready, then create and use the NodeProxy
s.waitForBoot({
  ~np = NodeProxy.audio(s, 2);
  // Set some audio content before playing
  ~np.source = { nil };
  // Now play it
  ~np.play;
});

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



// Create the looping task
~loopingTask = Task({
    inf.do { |cycle|

        // Play slow section
        ~slow.value;

        // Play fast section
        ~fast.value;

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
}

// Show instructions
"SIMPLE CONTROLS:".postln;
"~start.value - Start the loop".postln;
"~stop.value - Stop the loop".postln;
)

~start.value
~stop.value
~reset.value