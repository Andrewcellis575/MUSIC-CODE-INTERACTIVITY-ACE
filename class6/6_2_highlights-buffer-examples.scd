//in this example we will start working with our favorite NodeProxy music


//we have a lovely example we want to modify to play samples.
//so the sound generator SinOsc needs to be replaced by a PlayBuf UGen

n = NodeProxy.audio(s, 2).play;

n[0..4] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
	var a, f;
	lo = lo * exprand(1, 200);
	hi = hi * exprand(1, 200);
	f = LFClipNoise.kr(widefreq*rrand(0.1, 4.0)).range(lo, hi);
	a = SinOsc.ar(f ) * 0.1;
	a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
	a.dup;
};

n.gui
n.removeLast//the undo button

n.source=nil  //kill
n.gui //look

//first we need a buffer
b = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxCHORD.wav");
b.play

//set up a NodeProxy
w = NodeProxy.audio(s, 2).play;

// Modified version using PlayBuf
(w[0..12] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
    var a, f;
    lo = lo * exprand(1, 200);
    hi = hi * exprand(1, 200);

    // Instead of direct frequency modulation, we'll use rate multiplication
    f = LFClipNoise.kr(widefreq * rrand(0.1, 4.0)).range(lo/440, hi/440);

    // PlayBuf replaces SinOsc
    a = PlayBuf.ar(
        numChannels: b.numChannels,
        bufnum: b,
        rate: f * BufRateScale.kr(b), //bingo!
        loop: 1
    ) * 0.1;

    // Keep the amplitude envelope
    a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
    a.dup;
};
)

w[0..12]=nil
b = ~playBuffer

w.gui
b.zero
b.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/skeleton_bones.wav")

b.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxCHORD.wav")

b.read(	"/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxKICK_2.wav")
b.read(

///cool right?


//lets modify our peepers example from last week
~peepers = NodeProxy.audio(s, 2).play;

~peepers[1..4]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(1,10)*pitch, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};


~peepers.source= nil; //fade out all the crickets!
~peepers.source={ };


~peepers[1..4] = { }

~b = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/whineTRILL.wav");
~c = Buffer.read(s,"/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxHH_4.wav");
~b.play
~c.play
~d = Buffer.read(s,"/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/skeleton_bones.wav");

~peepers.gui
~peepers[0..10]={nil}

~peepers[0..8]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix, samp;
	samp=~b;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = PlayBuf.ar(numChannels: samp.numChannels,
		bufnum: samp,
		rate: rrand(1,10)/600*pitch*BufRateScale.kr(samp),
		loop: 1,
	)*frog1*frog2;
	out = Pan2.ar(sig, 1.0.rand2);
	out = out*20;
};

~peepers.gui

//you can also change the buffer and re-instantiate the NodeProxy
~b = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class4/daxos/crazybass.wav");

//even more elegant, because you don't need to re-instantiate the Node!
~d.zero; //clears the content of the buffer without removing the buffer
~d.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxHH_4.wav")
//beware channel mismatch can happen when you replace files this way.
~d.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxKICK_2.wav");

