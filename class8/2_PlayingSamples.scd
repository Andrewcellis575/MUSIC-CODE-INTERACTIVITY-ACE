/* Download sound files for audio playback from a folder named "moresounds"
The folder needs to be in the same folder as this saved file.
*/
(
s.waitForBoot({											   // guarantee the server is running
	~files = "moresounds/*".resolveRelative.pathMatch;	   // find files in the folder "moresounds", which
	~sounds = ~files.collect{ | f | Buffer.read(s, f) };   // load those sounds into  buffers on the server
	~numChannels = 2;		// number of channels in the sound file. you can adjust this if needed
	s.boot;                                                // the server, of course,  needs to be running
});
)


~sounds[5].play //test the player


//you have to evaluate these, or the subsequent code will fail.
~soundFileIndex = 0;	// which sound file in the array ~buffers. use different numbers to select files.
                         //above the number of files won't work


~dj = NodeProxy.new.play;

~dj = NodeProxy.new.play.fadeTime_(0).source_(nil); //is a shortcut to create the node with a fadeTime built in, with no sound in it.


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

~dj.set(\rate, 1.0);
~dj.setAt(0, \rate, 0.5)
~dj.source = nil


//let's take a minute to talk about what's happening. we have some new variables.
//sig is the soundfile buffer
//
~soundFileIndex = 0;
~dj = NodeProxy.new.play;

(~dj[0] = {
    |amp=1, rate=1, lofreq=5|
	var sig, ptr; //we need a variable for signal, and ptr is a pointer, the "now" that scrubs through the file
	var start, end; //of course we also need a beginning and an end
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
    start = 0; //start at zero
	end = buf.numFrames-1; //read the buffer's total frames and then subtract 1 so it's just one sample before end
	rate = MouseX.kr(0.25, 5.0, 1.0); // maybe you want to control speed?
	rate = [2, 3, 4, 5]/2;  //rate can be an expandable array for multiple buffers
	rate = 8/(8..16).asArray; //whoa!!
	rate=4/(3,5..9).asArray; // cool!
	rate = 2/[MouseX.kr(0.25, 5, 1), MouseX.kr(0.15, 4, 1), MouseX.kr(8, 0.1, 1),MouseX.kr(0.1, 3, 1)]; // how about four adjustable mouse rates
	rate = 0.125*(1,3..12).asArray; //the power of multichannel expansion!!!!!!!!
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end); // asaw wave that reads file from start to end.
    sig = BufRd.ar(~numChannels, buf, ptr); //the index is controlled by pointer
    sig = sig * amp;
};
)
~dj.source = nil




//this is another way of iterating. i'm using the choose method on ~sounds to pick random files. also i'm using the duct Ugen to fire the phasor buffer reader index at different times.

(~dj[0..2] = {
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

~dj = NodeProxy.new.play;

~dj.gui;
~dj.source = nil;

//the thing that's so amazing about supercollider is everything is modulable.
//instead of changing the ptr with a smooth line...
//now we're going to it with a complex synthesis function.

~dj = NodeProxy.new.play.fadeTime_(2).source_(nil); //in case you forgot your node
~soundFileIndex = 7; //in case you want to change your sound file
(
~dj[0]= {
	arg amp=1, buf, freq=0.2;
	var sig, ptr;
	var start, end;
	buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
	freq = 0.5;
	freq = MouseX.kr(0.1, 10.0, 1.0);
	freq = [1, 0.2, 2.5, 3.33, 4.5, 1.5];
	start = 0;
    end = buf.numFrames-1;
	ptr = SinOsc.ar(freq, 3pi/2).range(start, end);
	sig = BufRd.ar(~numChannels, buf, ptr);
	sig = sig * amp;
}
)

~dj.source=nil
~dj = NodeProxy.new.play.fadeTime_(2).source_(nil); //in case you forgot your node

~dj.gui

//Lets return to LFNoise, specifically, LFDNoise3
{LFDNoise3.kr(1)}.scope
{LFNoise1.kr(1)}.scope

~soundFileIndex = 3;	// which sound file in the array ~buffers. use different numbers to select files for
~sounds[3].play //test the player

~dj = NodeProxy.new.play.fadeTime_(2).source_(nil); //in case you forgot your node

(
~dj[0..2]= {
    |amp=1, lofreq=0.75, start=0, end|
    var sig, ptr;
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
	start = 0;
    end = buf.numFrames-1;
	ptr = LFNoise1.ar(lofreq).range(start, end); //try LFDNoise1, LFNoise2, LFDNoise3
	ptr = LFNoise1.ar(lofreq*[2, 1, 0.5]).range(start, end);
	ptr = LFDNoise3.ar(lofreq).range(start, end);
	sig = BufRd.ar(~numChannels, buf, ptr);
    sig = sig * amp;
	};
)

~dj.gui


(
~beat = Buffer.read(s, "FREE_Hip-hop_Beats.mp3".resolveRelative); //resolveRelative finds the file in the same dir as this file
)

w=~beat.play
w.release

~dj.source=nil

~dj = NodeProxy.new.play



~soundFileIndex = 0;	// pick a bell sound again
~soundFileIndex = 3;

~dj = NodeProxy.new.play.fadeTime_(2).source_(nil); //in case you forgot your node

//crazy pointers with randomized LF noise
//going back to phasor and adjusting its rate using LFnoise
(~dj[0..5] =
{
    |amp=1, rate=1, lofreq=0.2|
    var sig, ptr;
	var buf = ~sounds[~soundFileIndex];  // pick a sound file in the array with associated sound file number.
    var start = 0;
    var end = buf.numFrames-1;
	rate = 2*(1,2..24).asArray.choose;
	rate= rate.midiratio/4;
//	rate = rate * LFNoise1.kr(lofreq).range(0.1, 2.0);
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
    sig = BufRd.ar(~numChannels, buf, ptr);
    sig = sig * amp;
};
)
~dj.gui

~dj.source = nil

~dj[0..13]=nil

~dj = NodeProxy.new.play.fadeTime_(2).source_(nil); //in case you forgot your node


~dj.gui


~soundFileIndex = 5;	// pick a longer sound like this guy talking
~soundFileIndex = 6;	// pick a longer sound like this salsa band
~dj = NodeProxy.new.play.fadeTime_(2).source_(nil); //in case you forgot your node

~dj.play

//a different approach that does "windowing" on the buffer
(
~dj[0]=
    {
	| amp=1, rate=1, lofreq=1|
    var sig, ptr;
    var start, windowWidth, end;
	var buf = ~sounds[~soundFileIndex];              // pick a sound file in the array with associated sound file number.
   	var totalFrames = BufFrames.kr(buf);
	// MouseX controls the starting point (normalized 0-1)
    // MouseY controls the window width (normalized 0-1, smaller at the top)
    start = MouseX.kr(0, totalFrames - 100).round;
	windowWidth = MouseY.kr(min(88200, totalFrames/2), 100).round;   //the calculation min() allows us to use this code for small files.
	end = min(start + windowWidth, totalFrames - 1);                 //  Ensure end doesn't exceed buffer boundaries
	rate = [2, 0.5, 1];  //rate can be an expandable array for multiple buffers
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, resetPos: start); //reset
    sig = BufRd.ar(~numChannels, buf, ptr, interpolation: 4);
    sig = sig * amp;
};
)
~dj.gui

~dj.source = nil


~dj = NodeProxy.new.play.fadeTime_(2).source_(nil); //in case you forgot your node

~dj.fadeTime=10
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
	windowWidth = MouseY.kr(min(88200, totalFrames/2), 100).round;  //ensure window isn't bigger than the buffer
    end = min(start + windowWidth, totalFrames - 1);                //  Ensure end doesn't exceed buffer boundaries
    squiggle = LFNoise1.kr(lofreq) * squig * totalFrames;           // Fluctuate by up to +-12.5% of the total frames
    start = (start + squiggle).clip(0, totalFrames - windowWidth); // Apply squiggle offset while keeping window width constant
	end = start + windowWidth;                                    //the endpoint is start frame and the window variable set by the mouse
	rate = rate * [1, 2, 0.5];                                    //this line makes it amazing!
    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, resetPos: start);
    sig = BufRd.ar(~numChannels, buf, ptr, interpolation: 4);
    sig = sig * amp;
	sig= FreeVerb.ar(sig, mix: 0.5, room: 0.5, damp: 0.5, mul: 1.0, add: 0.0);

};
)


~dj.play

// Optionally, to change the rate:
~dj.set(\rate, 1.0);
~dj.set(\rate, -3.midiratio);
~dj.set(\rate, -7.midiratio);

~dj.source=nil

//sig= FreeVerb.ar(sig, mix: 0.5, room: 0.5, damp: 0.5, mul: 1.0, add: 0.0);
//	sig = RLPF.ar(sig, LFDNoise3.kr(lofreq*10).range(100,2000), 0.1);

~dj.gui

