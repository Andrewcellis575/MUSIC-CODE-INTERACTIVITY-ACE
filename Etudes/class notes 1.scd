(
{
	(   z=Sin0sc.ar(100);)

}

).play

(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02, 1);
	sig = Sin0sc.ar(freq) * amp;
}.play
)

(
SynthDef.new(\sineTest, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz)exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02, 1);
	sig = Sin0sc.ar(freq) * amp;
	Out.ar([0,1], sig);
}).add
)

x = Synth.new(\sineTest);

x = Synth.new(\sineTest, [\noiseHz, 100]);

x.set(\noiseHz, 10)

x.free;

////

{RLPF.ar(Dust.ar([12, 15]), LFNoise1.ar([0.3, 0.2]).range(100,3000), 0.02)}.play;

RLPF.ar(

(
Synth.new(\dusty, {
	arg rate1=10, rate2=15, range=3000;
	var amp1, am2, in1, in2, sig1, sig2, freq1, freq2;
	in1 = Dust.ar(rate1);
	in2 = Dust.ar(rate2);
			freq1 = LFNoise1.ar(0.2).range(100, range);
			freq2 = LFNoise1.ar(0.3).range(100, range);
			sig1 = RLPF.ar(in1,freq1, 0.02);
			sig2 = RLPF.ar(in2,freq2, 0.02);
			Out.ar(0, sig1);
			Out.ar(1, sig2);
		}).add;
	)

)

z = Synth.new(\dusty, [\range, 2000, \rate1,10, \rate2,4]);
z = free

z.set(\range, 3000);
z.set(\rate2,40 \rate1,10);

iteration
[5, 6, 4, 3, 6]

[5, 6, 4, 3, 6].do{"hello".postLn};

(
[6, 3, 0.1, 3.3, 3.1].do{
	arg item;
	item.squared.postLn;

}
)

1000.do{|i|
	i.cubed.PostLn;

}

x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free


(
SynthDef.new(\iter, {
	arg freq=40;
	var temp, sum;
	sum = 0
	10.do{
		temp =VarSar.ar(
			40* {Rand(0.99, 1.02)}!2,
			{rand(0.0, 0.05)}!2);
		    {ExpRand(0,004, 0.05)}!2
		);
		sum = sum + temp;


	};
	sum=sum * 0.05
	Out.ar(0, sum);
}).add:
)

b = Synth.new(\iter, [\freq, 60]);
b.set(\freq, 50);
b.free


///////

(

SynthDef.new(\blippy, {
	arg freq = 200;
	var temp, sum;
	sum = 0;
	        10.do{
	    arg count;
		temp = SinOsc.ar(freq * (count + 1));
		* LFNoise1.kr({Rand(0.05,0.2)}!2).range(0.98,1.12)
		sum = sum + temp; //increment
	};
	temp = temp * LFNoise1.kr({Rand(0.05,8)}!2.exchange(0.01, 1);
	};
Sum = sum * 0.05;
Out.ar(0, sum);
}).add;

)

x = Synth(\blippy);
x.set(\freq, 50);
x.set(\dev, 10);
x.free

q={Blip.ar(300, 10, 1.0)}.play











