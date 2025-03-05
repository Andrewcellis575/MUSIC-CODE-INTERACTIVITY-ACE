s.boot;

// Load your buffers (replace paths with your actual audio file paths)
(~b0 = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class4/daxos/DAXfournote 2.wav");
~b1 = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class4/daxos/crazybass.wav");
~b2 = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class4/daxos/dax_MULTIPHONIC.wav");
~b3 = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class4/daxos/coldSHOLD_1.wav");
)
//just drag and drop!

~b0.play; // plays a buffer

~b0.zero; //clears the content of the buffer without removing the buffer
~b0.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class4/daxos/bouncy.wav")
//add a new file into the buffer

~b0.free; //



//frames
~b0.numFrames;
~b0.numChannels;

~b0.duration;

// buffer numbers are integers that are assigned in sequence when buffers are created.
//any buffer on the server has a random index number associated with it
~b0.bufnum;

~b0.sampleRate;

//give all aspects of the buffer
~b0.query;




(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf; // magic argument means you can point to different wav files
	var sig;
	sig = PlayBuf.ar(2, buf);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~b2.bufnum]);

//clear all on server
s.freeall

(
SynthDef.new(\playbuf1, {
	arg amp=1, out=0, buf, da=2, playback; // magic argument means you can point to different wav files
	var sig;
	playback = MouseX.kr(0.125, 8);
	sig = PlayBuf.ar(2, buf, rate: playback, doneAction:da, loop: 1);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\playbuf1, [\buf, ~b2.bufnum, \playback, 1]);
x.free

// Single SynthDef for playing buffers
(
SynthDef(\bufPlayer, { |bufnum = 0, rate = 1, amp = 0.5|
    var sig = PlayBuf.ar(
        numChannels: 2, // Adjust if your files are mono
        bufnum: bufnum,
        rate: BufRateScale.kr(bufnum) * rate,
        doneAction: 2
    );
    Out.ar(0, sig * amp);
}).add;
)

// Create a window for key input
(
w = Window("Buffer Player", Rect(200, 200, 400, 100));
w.view.keyDownAction = { |view, char, modifiers, unicode, keycode|
    case
    { char === $a } { Synth(\bufPlayer, [\bufnum, ~b0]) }
    { char === $s } { Synth(\bufPlayer, [\bufnum, ~b1]) }
    { char === $d } { Synth(\bufPlayer, [\bufnum, ~b2]) }
    { char === $f } { Synth(\bufPlayer, [\bufnum, ~b3]) };
};
w.front;
)

// To clean up when done:
// w.close;
// ~b0.free; ~b1.free; ~b2.free; ~b3.free;