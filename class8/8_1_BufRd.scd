
/* Download sound files for audio playback from a folder named "moresounds"
The folder needs to be in the same folder as this file.
*/
(
s.waitForBoot({												    // guarantee the server is running
	~files = "moresounds/*".resolveRelative.pathMatch;		   	// find files in the folder "moresounds", which
	~sounds = ~files.collect{ | f | Buffer.read(s, f) };	    // load those sounds into  buffers on the server
	    s.boot;                                                  // the server, of course,  needs to be running
});
)


~sounds[2].play //test the player

~numChannels = 2;				// number of channels in the sound file. you can adjust this if the sampler yells at you
~soundFileIndex = 7;				// which sound file in the array ~buffers. use different numbers to select files for



(
~dj = NodeProxy.new.play;
~dj.fadeTime=2;
~dj.source = nil;
) //fill it with silence.

(~dj[0] = {
    |amp=1, rate=1, lofreq=5|
    var sig, ptr;
	var start, end;
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
    start = 0;
    end = buf.numFrames-1;
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
    sig = BufRd.ar(~numChannels, buf, ptr);
    sig = sig * amp;
};
)

(
~dj = NodeProxy.audio(s, 2); // set up our NodeProxy
~dj.play; // turn it on!
~dj.source = nil;
) //fill it with silence.

// Define a function to update the sound file
~setSound = { |index|
    ~soundFileIndex = index;
    // Re-create the synth with the new buffer
    ~dj[0] = {
        |amp=1, rate=1, lofreq=5|
        var sig, ptr;
        var buf = ~sounds[~soundFileIndex];
        var start = 0;
        var end = buf.numFrames-1;
        ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
        sig = BufRd.ar(~numChannels, buf, ptr);
        sig = sig * amp;
    };
};

// Initialize with sound file 0
~setSound.(0);

// To change sound files later:
~setSound.(2);


(~dj[0] = {
    |amp=1, rate=1, lofreq=5|
	var sig, ptr; //we need a variable for signal, and ptr is a pointer, the "now" that scrubs through the file
	var start, end; //of course we also need a beginning and an end
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
    start = 0; //start at zero
	end = buf.numFrames-1; //read the buffer's total frames and then subtract 1 so it's just one sample before end
	//rate = MouseX.kr(0.1, 10.0, 2.0); // maybe you want to control speed?
	//rate = [2, 4, 1];  //rate can be an expandable array for multiple buffers
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end); // asaw wave that reads file from start to end.
    sig = BufRd.ar(~numChannels, buf, ptr); //the index is controlled by pointer
    sig = sig * amp;
};
)


~dj.set(\rate, 2.0);
~dj.setAt(0, \rate, 4.0)
~dj.source = nil



(~dj[0] = {
    |amp=1, rate=1, lofreq=3|
    var sig, ptr;
	var start, end;
	var buf = ~sounds.choose;  // pick a sound file in the array with associated sound file number.
	var dusty = Dust.ar(lofreq)*rrand(0.1,2.1); //retriggerable by the dust UGen
	start = 0;
    end = buf.numFrames-1;
	ptr = Phasor.ar(dusty, BufRateScale.kr(buf) * rate, start, end);
    sig = BufRd.ar(~numChannels, buf, ptr);
    sig = sig * amp;
};
)

~dj.source = nil



(~dj[0..2] = {
    |amp=1, rate=1, lofreq=5, vibratoRate=1, vibratoDepth=0.01|
    var sig, ptr;
	var start, end;
	var vibrato;
	var buf = ~sounds.choose;  // pick a sound file in the array with associated sound file number.
    start = 0;
    end = buf.numFrames-1;
	 // Create subtle vibrato with sine oscillation
    vibrato = SinOsc.ar(vibratoRate) * vibratoDepth * end;
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end) + vibrato;
    sig = BufRd.ar(~numChannels, buf, ptr);
    sig = sig * amp;
};
)

~dj.set(\rate, 1.0, \amp, 1);
~dj.gui



//crazy pointers with randomized LF noise
(~dj[0] =
{
    |amp=1, rate=1, lofreq=0.2|
    var sig, ptr;
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
    var start = 0;
    var end = buf.numFrames-1;
	rate = rate * LFNoise1.kr(lofreq).range(0.1, 4.0);
//	rate = (1..12).asArray;
//	rate= rate.midiratio;
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
    sig = BufRd.ar(~numChannels, buf, ptr);
    sig = sig * amp;
};
)
~dj.source = nil


~dj.gui

//a different approach that does "windowing" on the buffer
(
~dj[0]=
    {
	| amp=1, rate=1, lofreq=1|
    var sig, ptr;
    var start, windowWidth, end;
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
   	var totalFrames = BufFrames.kr(buf);
	// MouseX controls the starting point (normalized 0-1)
    // MouseY controls the window width (normalized 0-1, smaller at the top)
    start = MouseX.kr(0, totalFrames - 100).round;
    windowWidth = MouseY.kr(min(88200, totalFrames/2), 100).round;
//  Ensure end doesn't exceed buffer boundaries
    end = min(start + windowWidth, totalFrames - 1);
//	rate = [2, 0.5, 1];  //rate can be an expandable array for multiple buffers
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, start);
    sig = BufRd.ar(~numChannels, buf, ptr);
    // Convert mono to stereo
    sig = sig * amp;
};
)
~dj.gui

~dj.source = nil

//squiggle the window my way
(~dj[0]=
    {
	| amp=1, rate=1, lofreq=0.1|
    var sig, ptr;
    var start, windowWidth, end;
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
   	var totalFrames = BufFrames.kr(buf);
	var squiggle;
	// MouseX controls the starting point (normalized 0-1)
    // MouseY controls the window width (normalized 0-1, smaller at the top)
    start = MouseX.kr(0, totalFrames - 100).round;
    windowWidth = MouseY.kr(min(88200, totalFrames/2), 100).round;
//  Ensure end doesn't exceed buffer boundaries
    squiggle = LFNoise1.kr(lofreq).range(0.1, 1.0);
	end = min(start + windowWidth, totalFrames - 1);
	start = start * squiggle;
	end = end * squiggle;
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, start);
	sig = BufRd.ar(~numChannels, buf, ptr, interpolation: 4 );
    // Convert mono to stereo
    sig = sig * amp;
};
)

//squiggle the window slide the window
(~dj[0]=
    {
    | amp=1, rate=1, lofreq=0.1, squig=0.125|
    var sig, ptr;
    var start, windowWidth, end;
    var buf = ~sounds[~soundFileIndex];
    var totalFrames = BufFrames.kr(buf);
    var squiggle;
    start = MouseX.kr(0, totalFrames - 100).round;
    windowWidth = MouseY.kr(min(88200, totalFrames/2), 100).round;
    end = min(start + windowWidth, totalFrames - 1);
    // Fluctuate by up to 25% of the total frames
    squiggle = LFNoise1.kr(lofreq) * squig * totalFrames;
    // Apply squiggle offset while keeping window width constant
    start = (start + squiggle).clip(0, totalFrames - windowWidth);
    end = start + windowWidth;
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, start);
    sig = BufRd.ar(~numChannels, buf, ptr, interpolation: 4);
    sig = sig * amp;
};
)

~dj.gui

// Optionally, to change the rate:
~dj.set(\rate, 1.0);
~dj.set(\rate, -3.midiratio);
~dj.set(\rate, -7.midiratio);

(
~ratePattern = Pbind(
    \type, \set,
    \id, ~dj.nodeID,
    \args, [\rate],
    \dur, 0.1,
    \midinote, Prand([0, 4, 0, 7, 4, 0, 0], inf),
    \rate, Pfunc({ |ev| ev.midinote.midiratio })  // Using midiratio instead of freqratios
);
~ratePlayer = ~ratePattern.play;
~ratePlayer.stop;
)



(

Pbind(\dur,0.125,
	\midinote, Pseq([0, 4, 0, 7, 4, 0, 0] + 60,inf),
	\amp, Prand([0.125, 0.2, 0.25],inf)
).play

)





//I find that Phasor is usually the right tool for looping through a buffer, but there are a couple alternatives to Phasor.

//But BufRd is even more flexible, because you can use ANY audio rate UGen as a frame pointer, so long as that UGen has an appropriate output range. For example, I can read a buffer forward and backward, sinusoidally by using SinOsc as an audio rate pointer. I'll set the initial phase offset for the sine wave generator to be 3pi/2, so that SinOsc starts at its lowest point, which corresponds to the beginning of the buffer.

(
~dj[0]= {
	arg amp=1, buf, freq=0.2;
	var sig, ptr;
	var start, end;
	buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
//	freq = MouseX.kr(0.1, 10.0, 2.0);
	start = 0;
    end = buf.numFrames-1;
	ptr = SinOsc.ar(freq, 3pi/2).range(start, end);
	sig = BufRd.ar(~numChannels, buf, ptr);
	sig = sig * amp;
}
)

~dj.source=nil


(
~dj[0]={
	arg amp=1, buf, lofreq=1;
	var sig, ptr;
	var start, end;
	buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
	start = 0;
    end = buf.numFrames-1;
	ptr = LFDNoise1.ar(lofreq*rrand(0.1, 2.0)).range(start, end);
	sig = BufRd.ar(~numChannels, buf, ptr);
	sig = sig * amp;
};
)



~dj.source=nil





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
