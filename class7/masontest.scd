(
~dirpath = "MySounds/*".resolveRelative;
~filepaths = ~dirpath.pathMatch;
~buffers = ~filepaths.collect { |path|  Buffer.read(s, path) };
~buffers = ~filepaths.collect { |path|  Buffer.readChannel(s, path, channels: [0]);};

s.options.maxSynthDefs = 2048;

s.boot;

s.waitForBoot({
  ~np = NodeProxy.audio(s, 2);
  ~np.source = { nil };
  ~np.play;
});



~inHere = {
    "Playing inHere section with band-pass filter...".postln;
    120.do { |i|
        var buf = ~buffers.choose;

        var signal = PlayBuf.ar(buf.numChannels, buf.bufnum,
            rate: (1..120).choose.midiratio,
            doneAction: 2
        );

        // Apply band-pass filter to emphasize mid frequencies
        var filteredSignal = BPF.ar(signal, 20, 200);  // Center frequency = 2000 Hz, Bandwidth = 200 Hz

        // Apply a reasonable gain for volume
        ~np.add({
            filteredSignal * 0.5  // Simple gain applied after filtering
        });

        (buf.duration/4).wait;
    };
};



~outThereHorror = {
    "Playing outThere section with reverb and reverse...".postln;
    100.do { |i|
        var buf = ~buffers.choose;

        // Random rate for the playback speed
        var rate = (1..12).choose.midiratio;  // Random positive rate (midi to ratio)

        // Reverse playback by multiplying the rate by -1
        var reversedRate = rate * 0.8;  // Reverse playback (negative rate)

        var amp = rrand(-40, 0).dbamp;  // Random amplitude

        // Apply reverb directly while reversing the playback
        ~np.add({
            var signal = PlayBuf.ar(buf.numChannels, buf.bufnum,
                rate: reversedRate,  // Reverse playback (negative rate)
                doneAction: 2
            ) * amp;

            // Pan2 applied to give stereo effect (this makes it panned randomly between L/R channels)
            var pannedSignal = Pan2.ar(signal, Rand(-1.0, 1.0));

            // Apply FreeVerb for heavy reverb
            var reverbSignal = FreeVerb.ar(
                pannedSignal,
                mix: 0.9,   // 90% wet signal
                room: 0.9,  // Larger room size
                damp: 0.5   // Moderate dampening
            );

            // Apply Low-Pass Filter to emphasize lower frequencies
            var lowPassSignal = LPF.ar(reverbSignal, 1500); // Adjust cutoff frequency as needed

            // Apply High-Pass Filter to reduce rumble or excessive low frequencies
            var filteredSignal = HPF.ar(lowPassSignal, 100); // Adjust cutoff frequency as needed

            // Add the filtered reverb signal to the node proxy
            filteredSignal
        });

        // Slight overlap between buffers (spillover effect)
        rrand(0.1, 0.9).wait;  // Increase wait time slightly to allow reverb to spill over
    };
    "OutThere section with reverb and reverse complete.".postln;
};




~stinky= {
        "Playing Stinky! section...".postln;
        89.do { |i|
            var buf = ~buffers.choose;
            var rate = [-5, -1, 5, 12, 10].choose;
            var start = rrand(0, 0.8);
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
        "Stinky! section complete.".postln;
    }
;

~loopingTask = Task({
    inf.do { |cycle|
        "Starting cycle %...".format(cycle + 1).postln;

		~inHere.value;
		~np.source = { nil };

		~outThereHorror.value;
		~np.source = { nil };

        ~stinky.value;
		~np.source = { nil };

        "Completed cycle %".format(cycle + 1).postln;
    };
});

~start = { ~loopingTask.play; "Starting the loop...".postln; };
~stop = { ~loopingTask.stop; "Stopping the loop...".postln; };
)
"SIMPLE CONTROLS:".postln;
"~start.value - Start the loop".postln;
"~stop.value - Stop the loop".postln;

~start.value;
~stop.value;



