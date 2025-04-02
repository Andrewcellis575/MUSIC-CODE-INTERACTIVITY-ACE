// Buffer recorder with dynamic buffer length that adds to ~sounds array
(
// Create a temporary buffer for recording
~tempBuffer = Buffer.alloc(s, s.sampleRate * 30, 2);  // Temporary 30-second stereo buffer
// State variables
~isRecording = false;
~recorder = nil;
~recordStartTime = 0;
~recordEndTime = 0;

// Create a minimal window for key control
~recorderWindow = Window("Buffer Recorder", Rect(200, 200, 300, 160)).front;

// Simple SynthDef for recording
SynthDef(\bufferRecorder, {
    arg bufnum=0;
    var in = SoundIn.ar([0, 1]);  // Stereo input
    RecordBuf.ar(in, bufnum);
    Out.ar(0, in * 0.0); // Monitor with zero volume
}).add;

// Function to create a properly sized buffer and add to ~sounds
~createAndAddBuffer = { |duration|
    var newBuffer;
    var numFrames = (duration * s.sampleRate).asInteger;

    // Create a new buffer of exactly the right size
    "Creating buffer of % frames (% seconds)".format(numFrames, duration.round(0.01)).postln;
    newBuffer = Buffer.alloc(s, numFrames, 2);  // Stereo buffer

    // Copy data from temp buffer to the final buffer
    ~tempBuffer.copyData(newBuffer, 0, 0, numFrames);

    // Add the new buffer to the ~sounds array
    // Use correct array append method to avoid overwriting
    if(~sounds.isNil) {
        ~sounds = [newBuffer];
    } {
        ~sounds = ~sounds ++ [newBuffer];
    };

    // Return the index of the newly added buffer
    "Buffer added to ~sounds array at index %".format(~sounds.size - 1).postln;
    ~sounds.size - 1;
};

// Space bar handler for recording
~recorderWindow.view.keyDownAction = { |view, char, mod, unicode, keycode|
    if(unicode == 32 && ~isRecording.not) { // Space = start recording
        "Starting recording...".postln;
        ~tempBuffer.zero; // Clear the temp buffer
        ~recordStartTime = Main.elapsedTime;
        ~recorder = Synth(\bufferRecorder, [\bufnum, ~tempBuffer.bufnum]);
        ~isRecording = true;
    };
};

~recorderWindow.view.keyUpAction = { |view, char, mod, unicode, keycode|
    var duration, newIndex;
    if(unicode == 32 && ~isRecording) { // Space = stop recording
        ~recordEndTime = Main.elapsedTime;
        ~recorder.free;
        ~isRecording = false;

        // Calculate duration
        duration = ~recordEndTime - ~recordStartTime;

        // Create the final buffer and add to ~sounds
        newIndex = ~createAndAddBuffer.value(duration);

        // Update the display
        "Recording stopped. New sound added at ~sounds[%]".format(newIndex).postln;
        "Use ~sounds[%].play to play the buffer.".format(newIndex).postln;
    };
};

// Add a record button
Button(~recorderWindow, Rect(20, 20, 260, 40))
    .states_([
        ["Press Space to Record", Color.white, Color.red],
        ["Recording...", Color.black, Color.green]
    ])
    .action_({ |button|
        var duration, newIndex;
        if(~isRecording.not) {
            ~tempBuffer.zero;
            ~recordStartTime = Main.elapsedTime;
            ~recorder = Synth(\bufferRecorder, [\bufnum, ~tempBuffer.bufnum]);
            ~isRecording = true;
            button.value = 1;
            "Recording started...".postln;
        } {
            ~recordEndTime = Main.elapsedTime;
            ~recorder.free;
            ~isRecording = false;
            button.value = 0;

            // Calculate duration
            duration = ~recordEndTime - ~recordStartTime;

            // Create the final buffer and add to ~sounds
            newIndex = ~createAndAddBuffer.value(duration);

            "Recording stopped. New sound added at ~sounds[%]".format(newIndex).postln;
            "Use ~sounds[%].play to play the buffer.".format(newIndex).postln;
        }
    });

// Add a play button for the last recorded sample
Button(~recorderWindow, Rect(20, 70, 260, 40))
    .states_([["Play Last Recorded Sample", Color.white, Color.blue]])
    .action_({
        if(~sounds.notNil && ~sounds.size > 0) {
            ~sounds[~sounds.size - 1].play;
            "Playing the last recorded sample (~sounds[%])".format(~sounds.size - 1).postln;
        } {
            "No recorded samples available.".postln;
        }
    });

// Label showing current count of samples
StaticText(~recorderWindow, Rect(20, 120, 260, 30))
    .string_("Current samples in ~sounds: " ++ if(~sounds.notNil) { ~sounds.size } { 0 })
    .align_(\center)
    .background_(Color.grey(0.9));

"Recording system ready:".postln;
"- Press and hold SPACE to record".postln;
"- After recording, the buffer will be added to the ~sounds array".postln;
"- Use ~sounds[index].play to play a specific buffer".postln;
"- Current number of samples in ~sounds: " ++ if(~sounds.notNil) { ~sounds.size } { 0 }.postln;
)