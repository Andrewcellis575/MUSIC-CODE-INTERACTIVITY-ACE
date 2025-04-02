

Buffer.freeAll;//completely empty all buffers on server

//LOAD UP SOME SOUNDS

~b0 = Buffer.read(s,"/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxSNARE_3.wav" );
~b0.play;
~b1 = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/mewl.wav");
~b2 = Buffer.read(s,"/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxSHIVEr.wav");
~b3 = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/TINGLYdaxCHORD_1.wav" );
~b0.play;
~b1.play;
~b2.play
~b3.play;



//Cool, ok let's now turn our attention to BufRd. BufRd starts with the same two arguments as PlayBuf: the number of channels, and the bufnum. The third argument must be an audio rate signal, which will be used as a frame pointer into the buffer. So let's make another variable called pointer.

//Suppose we just want to read through this buffer once. The simplest way to do this is to use Line, which goes from point A to point B over a given duration. Remember that the read pointer for BufRd must run at the audio rate, so I'm choosing dot ar. We want to start at the zeroth frame, and travel to the last frame. This is a good opportunity to revisit the Buffer Info UGens. Here we can use BufFrames, making sure to subtract 1, and then for the duration argument, we can use BufDur, to ensure that the Line takes the correct amount of time to travel from start to finish. And for good measure, I'll specify doneAction:2 on the Line so that the Synth will free itself at the end.


(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf, start, end;
	var sig, ptr;
	ptr = Line.ar(start, end, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)



~bufrd_test.set(\buf, ~b1, \start, 0, \end, ~b1.numFrames-1);

~bufrd_test.gui

//Now we can play the file forward, or backward

Synth.new(\bufrd_test, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1]);
Synth.new(\bufrd_test, [\buf, ~b2.bufnum, \start, ~b2.numFrames-1, \end, 0]);

//To loop a buffer, we'll need to choose a UGen other than Line, because Line isn't capable of looping.
//Phasor is usually an excellent choice for this, because it's a linear ramp oscillator with inputs for start, end, and rate.
//Phasor.ar!

//I'll just provide a zero for the trigger argument because I don't plan on retriggering Phasor, and go to the second argument, which is rate. And once again, this is a great opportunity to use BufRateScale.

//remember,BufRateScale finds the buffer rate in respect to the sample rate if your file is recorded at the same sample rate as the server is running, you could just use 1.

(
SynthDef.new(\bufrd_loop, {
	arg amp=1, out=0, buf, rate=1, start, end;
	var sig, ptr;
//	rate = MouseX.kr(0.1, 10.0, 2.0);
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\bufrd_loop, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1]);
x.free

(
~bufrd_loop = NodeProxy.audio(s, 2); // set up our NodeProxy
~bufrd_loop.play; // turn it on!
~bufrd_loop.source = nil) //fill it with silence.

(~bufrd_loop[0] = {
    |amp=1, rate=1, lofreq=5|
    var sig, ptr;
    var buf = ~b0;  // Directly use the buffer variable
    var start = 0;
    var end = buf.numFrames-1;
//	rate = MouseX.kr(0.1, 10.0, 2.0);
//	var dusty = Dust.ar(lofreq);
 //rate = rate * LFNoise1.kr(0.2).range(0.1, 4.0);
//	rate = (1..12).asArray;
//	rate= rate.midiratio;
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
    sig = BufRd.ar(2, buf, ptr);
    sig = sig * amp;
    sig;
};
)

~bufrd_loop.gui

//

~bufrd_loop.source = nil


// To use it with a specific buffer:
~bufrd_loop.set(\buf, ~b0, \start, 0, \end, ~b0.numFrames-1);

// Optionally, to change the rate:
~bufrd_loop.set(\rate, 2.0);


I can change the start and end points, for example, to only read the second half of the file

x.set(\start, ~b2.numFrames/2, \end, ~b2.numFrames-1);

or I can choose a more specific range of frames

x.set(\start, 2000, \end, 26000);

and I can change the rate too, just like I did with PlayBuf

x.set(\rate, -3.midiratio);
x.set(\rate, -7.midiratio);

x.free;


(
SynthDef.new(\bufrd_loop_mouse, {
    arg amp=1, out=0, buf, rate=1;
    var sig, ptr;
    var start, windowWidth, end;

    // MouseX controls the starting point (normalized 0-1)
    // MouseY controls the window width (normalized 0-1, smaller at the top)
    start = MouseX.kr(0, BufFrames.kr(buf) - 1000);
    windowWidth = MouseY.kr(BufFrames.kr(buf) / 2, 1000); // Min 100 frames, max half the buffer
    end = start + windowWidth;

    // Ensure end doesn't exceed buffer boundaries
    end = min(end, BufFrames.kr(buf) - 1);

    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, start);
    sig = BufRd.ar(1, buf, ptr); // Note: using 1 channel since your buffer is mono

    // Convert mono to stereo
    sig = [sig, sig] * amp;

    Out.ar(out, sig);
}).add;
)

x = Synth.new(\bufrd_loop_mouse, [\buf, ~b3.bufnum]);


// Run this after the SynthDef is added:
x = Synth.new(\bufrd_loop_mouse, [\buf, ~b2.bufnum]);

I find that Phasor is usually the right tool for looping through a buffer, but there are a couple alternatives to Phasor, in particular there's Sweep and LFSaw, which you might find useful as a frame pointer in some situations.

But BufRd is even more flexible, because you can use ANY audio rate UGen as a frame pointer, so long as that UGen has an appropriate output range. For example, I can read a buffer forward and backward, sinusoidally by using SinOsc as an audio rate pointer. I'll set the initial phase offset for the sine wave generator to be 3pi/2, so that SinOsc starts at its lowest point, which corresponds to the beginning of the buffer.

(
SynthDef.new(\bufrd_sine, {
	arg amp=1, out=[0,1], buf, freq=0.2, start, end;
	var sig, ptr;
//	freq = MouseX.kr(0.1, 10.0, 2.0);
	ptr = SinOsc.ar(freq, 3pi/2).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\bufrd_sine, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 0.2]);
x.free;

One of my personal favorites, you can use a noise generator as a buffer playback pointer. Using a low frequency noise generator, you'll hear random sections of the soundfile, at random speeds, sometimes forward, sometimes backward.

(
SynthDef.new(\bufrd_noise, {
	arg amp=1, out=0, buf, freq=2.75, start, end;
	var sig, ptr;
	ptr = LFDNoise1.ar(freq).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
	Out.ar(out, [sig,sig]); //can add to convert mono to streo!
}).add;
)

x = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1]);

x.free;

With multiple Synths, each playing a different sound, you can get some interesting layered effects.

w = Synth.new(\bufrd_noise, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 0.6, \amp, 0.5]);
x = Synth.new(\bufrd_noise, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 0.8, \amp, 0.5]);
y = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 0.7, \amp, 0.5]);
z = Synth.new(\bufrd_noise, [\buf, ~b3.bufnum, \start, 0, \end, ~b3.numFrames-1, \freq, 5.5, \amp, 0.2]);

s.freeAll;

The higher the frequency of the noise generator, the faster the playback pointer will move, and it'll give your sound a more chaotic and glitchy sound.

g = Group.new;

w = Synth.new(\bufrd_noise, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 2.5, \amp, 0.5], g);
x = Synth.new(\bufrd_noise, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 3.4, \amp, 0.5], g);
y = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 2.7, \amp, 0.5], g);
z = Synth.new(\bufrd_noise, [\buf, ~b3.bufnum, \start, 0, \end, ~b3.numFrames-1, \freq, 3.3, \amp, 0.2], g);

g.set(\freq, 16);
g.set(\freq, 60);
g.set(\freq, 200);
g.set(\freq, 0.16);

s.freeAll;

//same technique using nodeproxy
(~turntable = NodeProxy.audio(s, 2);
~turntable.play;
~turntable.source=nil;
~turntable.source= {
    |amp=1, buf, lofreq=0.75, start=0, end|
    var sig, ptr;
    end = end ? BufFrames.kr(buf) - 1; //"If the variable end is nil (i.e., not defined or explicitly set to nil), then assign it the value of BufFrames.kr(buf) - 1; otherwise, keep its existing value."
    ptr = LFDNoise3.ar(lofreq).range(start, end); //try LFDNoise1, LFNoise2, LFDNoise3
    sig = BufRd.ar(2, buf, ptr);
    sig = sig * amp;
	Pan2.ar(sig, 0);
	};
)

//but because we've built it with buf as an argument, we need to plug in manually which soundfile, or record we're going to use

~turntable.set(\buf, ~b0, \start, 0, \end, ~b0.numFrames-1)
~turntable.set(\buf, ~b1, \start, 0, \end, ~b1.numFrames-1)

~turntable.set(\buf, ~b2, \start, 0, \end, ~b2.numFrames-1)

~b0.zero
~b0.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/new_highlights/niceCHORDS.wav");
//change the sound!

~turntable.gui


(~fader = NodeProxy.audio(s,2);
~fader.play;
~fader.source=nil;
~fader.source=
{|pan=0|
	XFade2.ar(~turntable.ar, PinkNoise.ar(1), pan, 1); //you can trick this UGEN input by using a NodeProxy at audio rate!
}
)

~fader.gui

(
~drumbeat = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class8/FREE_Hip-hop_Beats.mp3");
~beatbox = NodeProxy.audio(s, 2);
)

(~beatbox.source = {
    |amp=1, rate=1|  // Added default value for rate
    var sig, buf, start, end;
	buf=~drumbeat;
	start=0;
    end = buf.numFrames-1;
	sig = PlayBuf.ar(numChannels: buf.numChannels, bufnum: buf.bufnum, rate: rate, loop:1);
    sig = sig * amp;
};
~beatbox.play;
)
~beatbox.gui



// Create the Ndef version of bufrd_noise
Ndef(\bufrd_noise,
	{
    |amp=1, buf, lofreq=0.75, start=0, end|
    var sig, ptr;
    end = end ? BufFrames.kr(buf) - 1;
    ptr = LFDNoise3.ar(lofreq).range(start, end);
    sig = BufRd.ar(2, buf, ptr);
    sig = sig * amp;
	}
);

// Play the Ndef with your buffer
Ndef(\bufrd_noise).set(\buf, ~b2, \start, 0, \end, ~b2.numFrames-1);
Ndef(\bufrd_noise).play;

Ndef(\bufrd_noise).stop;
Ndef(\bufrd_noise).gui;


// Make a simple GUI
