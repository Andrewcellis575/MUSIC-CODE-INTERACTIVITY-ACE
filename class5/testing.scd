~peepers = NodeProxy.audio(s, 2).play;

~peepers[1..4]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(1,10)*pitch, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};

~peepers[1..4] = { }

~b = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class4/daxos/whineTRILL.wav");

~b.play

~peepers[1..4]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = PlayBuf.ar(numChannels: ~b.numChannels,
		bufnum: ~b,
		rate: rrand(1,10)/600*pitch*BufRateScale.kr(~b),
		loop: 1,
	)*frog1*frog2;
	out = Pan2.ar(sig, 1.0.rand2);
	out = out*10;
};

~peepers.gui