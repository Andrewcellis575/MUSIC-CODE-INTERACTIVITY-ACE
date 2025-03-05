// Buffer recorder with dynamic buffer length
(
// Create a temporary buffer for recording
~tempBuffer = Buffer.alloc(s, s.sampleRate * 30, 1);  // Temporary 30-second buffer

// State variables
~isRecording = false;
~recorder = nil;
~recordStartTime = 0;
~recordEndTime = 0;

// Create a minimal window for key control
~window = Window("Buffer Recorder", Rect(200, 200, 200, 80)).front;

// Simple SynthDef for recording
SynthDef(\bufferRecorder, {
    arg bufnum=0;
    var in = SoundIn.ar(0);
    RecordBuf.ar(in, bufnum);
    Out.ar(0, in.dup * 0.0); // Monitor with zero volume
}).add;

// Player SynthDef - standard playback
SynthDef(\bufferPlayer, {
    arg bufnum=0;
    var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 1);
    Out.ar(0, sig.dup * 0.5);
}).add;

// Create a simple play function
~playBuffer = {
    Synth(\bufferPlayer, [\bufnum, b.bufnum]);
    "Playing buffer...".postln;
};

// Function to create a properly sized buffer
~createFinalBuffer = { |duration|
    var numFrames = (duration * s.sampleRate).asInteger;

    // Free any existing final buffer
    if(b.notNil) { b.free };

    // Create a new buffer of exactly the right size
    "Creating buffer of % frames (% seconds)".format(numFrames, duration.round(0.01)).postln;
    b = Buffer.alloc(s, numFrames, 1);

    // Copy data from temp buffer to the final buffer
    ~tempBuffer.copyData(b, 0, 0, numFrames);

    "Final buffer created with ID: %".format(b.bufnum).postln;
};

// Space bar handler for recording
~window.view.keyDownAction = { |view, char, mod, unicode, keycode|
    if(unicode == 32 && ~isRecording.not) { // Space = start recording
        "Starting recording...".postln;
        ~tempBuffer.zero; // Clear the temp buffer
        ~recordStartTime = Main.elapsedTime;
        ~recorder = Synth(\bufferRecorder, [\bufnum, ~tempBuffer.bufnum]);
        ~isRecording = true;
    };
};

~window.view.keyUpAction = { |view, char, mod, unicode, keycode|
    var duration;

    if(unicode == 32 && ~isRecording) { // Space = stop recording
        ~recordEndTime = Main.elapsedTime;

        ~recorder.free;
        ~isRecording = false;

        // Calculate duration
        duration = ~recordEndTime - ~recordStartTime;

        // Create the final buffer with the exact duration
        ~createFinalBuffer.value(duration);

        "Recording stopped. Use ~playBuffer.value to play the buffer.".postln;
    };
};

// Add a single record button
Button(~window, Rect(20, 20, 160, 40))
    .states_([["Press Space to Record", Color.white, Color.red]])
    .action_({
        var duration;

        if(~isRecording.not) {
            ~tempBuffer.zero;
            ~recordStartTime = Main.elapsedTime;
            ~recorder = Synth(\bufferRecorder, [\bufnum, ~tempBuffer.bufnum]);
            ~isRecording = true;
            "Recording started...".postln;
        } {
            ~recordEndTime = Main.elapsedTime;
            ~recorder.free;
            ~isRecording = false;

            // Calculate duration
            duration = ~recordEndTime - ~recordStartTime;

            // Create the final buffer with the exact duration
            ~createFinalBuffer.value(duration);

            "Recording stopped. Use ~playBuffer.value to play the buffer.".postln;
        }
    });

"Recording system ready:".postln;
"- Press and hold SPACE to record".postln;
"- After recording, the buffer 'b' will contain exactly what you recorded".postln;
"- Use ~playBuffer.value to play the buffer".postln;
)
