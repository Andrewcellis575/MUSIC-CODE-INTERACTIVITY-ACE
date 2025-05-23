(

s.waitForBoot({

	SynthDef(\farEnough, {
		arg pitch, freq=70, addFreq=17, attack=1, release = 12;
		var sig, sig1, saws, env, shapeEnv, local, local2;
		sig =
		Mix.new(
			Array.fill(8,
				{SinOsc.ar(freq + addFreq.rand, 0.95.rand, 0.03)}));

		env = EnvGen.kr(
			Env.perc(attack, release ),
			doneAction:2);
		sig1 = sig + (sig *
			Mix.new(
				Array.fill(8,
					{SinOsc.ar(0.02, 0.7.rand, LFNoise1.kr(0.02, 0.08))})));

		sig = sig * env;
		sig1 = sig1 * env;

		sig = PitchShift.ar(sig, 0.1, SinOsc.kr(pitch.rrand(0.1, 0.2), 3.2.rand, 0.9, 3));
		sig1 = PitchShift.ar(sig1, 0.1, SinOsc.kr(pitch.rrand(0.1, 9.2), 0, 0.9, 3));

		saws = Mix.new(
			Array.fill(8,
				{LFSaw.ar(\sawFreq.ir(4000) + addFreq.rand, 0.9.rand, 0.02)}));
		shapeEnv = EnvGen.kr(Env([0.1, 0.02, 0.8, 0.0], [1, 5, 3 , 2]));

		saws = saws * shapeEnv;
		saws = saws * env;

		local = LocalIn.ar(2) + [sig+sig1, sig1+sig];
		local = DelayN.ar(local, 0.8, [0.3, 0.33.rand]);
		local2 = LocalIn.ar(2) + [saws, saws];
		local2 = DelayN.ar(local2, 0.8, [0.02, 0.02.rand]);
		local = local + local2;

		local = Compander.ar(
			local, local,
			0.2, slopeBelow: 1.3,
			slopeAbove: 0.1,
			clampTime:0.1,
			relaxTime:0.01);
		local = local.tanh;
		local = HPF.ar(local, 70);
		//local = BRF.ar(local, 260);
		LocalOut.ar(local * 0.8);
		Out.ar(0, local);

	}).add;




	SynthDef(\impul, {
		arg freq = 1000;
		var sig, sig1, env;
		sig = Pan2.ar(
			Mix.ar(
				Array.fill(8,
					{Impulse.ar(freq + 130.rand, 0.7.rand,
						LFNoise1.kr(20, 0.2.rand))})), 0);
		4.do({ sig = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1) });
		sig1 = sig * LFNoise1.ar(23, Dust2.kr(20));
		4.do({ sig1 = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1) });
		env = EnvGen.kr(Env.perc(5, 20), doneAction:2);
		sig = (sig  + sig1)*env;


		Out.ar(0, sig);
	}).add;




	SynthDef(\f, {
		arg pitch, addFreq=200;
		var sig, sig1, env, local;
		sig =
		Mix.new(Array.fill(8,
			{SinOsc.ar(\freq.ir(300) + addFreq.rand, 0.45.rand, 0.02)}));

		env = EnvGen.kr(
			Env.perc(
				\attack.ir(0.1),
				\release.ir(10)),
			doneAction:2);

		sig1 = sig + (sig * SinOsc.ar(30, 0.7.rand));

		sig1 = sig1 * env;
		sig = sig * env;
		sig = PitchShift.ar(sig, 0.1, SinOsc.kr(pitch.rrand(0.1, 3.2), 0, 0.9, 3));

		local = LocalIn.ar(2) + [sig+sig1, sig1+sig];
		local = DelayN.ar(local, 0.8, [0.3, 0.33.rand]);
		LocalOut.ar(local * 0.8);
		Out.ar(0, local);
	}).add;


	SynthDef(\bur, {
		arg freq=232, gate=10, dauer = 20, amp=1;
		var sig, env, lastEnv;

		sig = SinOsc.ar(freq);
		env = EnvGen.kr(Env.perc, Impulse.kr(gate), doneAction:2);

		sig = sig * env;
		sig = Compander.ar(sig, sig, 0.2, 4.3, clampTime:0.1, relaxTime:0.001);
		lastEnv = EnvGen.kr(Env([0, 1, 1, 0], [0.01, dauer, 3, 0.02]), doneAction:2);
		sig = sig * lastEnv;
		sig = sig * amp;
		Out.ar(0, sig!2);
	}).add;


	s.sync;





	s.record("home", 0, 2); //RECORD

	fork{
		for(1, 100000){arg i;
			0.01.wait;
			i = i/100;

			i.postln;

			if(i ==1){Synth(\farEnough, [\addFreq, 4,\attack, 4, \release, 10])};
			if(i ==7){
				Synth(\farEnough, [\addFreq, 21, \release, 13]);
				Synth(\farEnough, [\addFreq, 20,\release, 10]);
			};

			if(i == 11){Synth(\farEnough, [\addFreq, 38,\release, 10])};
			if(i == 17.77){Synth(\farEnough, [\addFreq, 43,\release, 16])};
			if(i == 24){Synth(\farEnough, [\addFreq, 403,\attack, 6, \release, 16])};
			if(i == 26.2){Synth(\farEnough, [\addFreq, 803,\release, 9])};
			if(i == 29.6){Synth(\farEnough, [\addFreq, 2803,\release, 15])};

			if(i == 29.9){Synth(\impul)};
			if(i == 36.9){
				Synth(\impul, [\freq, 700]);
				Synth(\farEnough, [\addFreq, 12,\release, 12]);
				Synth(\farEnough, [\addFreq, 17,\release, 14]);
			};

			if(i == 44.3){Synth(\impul, [\freq, 964])};

			if(i == 47.2){Synth(\f)};
			if(i == 52){Synth(\farEnough, [\addFreq, 2400,\release, 20])};
			if(i == 61.3){
				Synth(\impul, [\freq, 2904]);
				Synth(\farEnough, [\addFreq, 240,\release, 20]);

			};

			if(i == 102.3){Synth(\f,
				[\freq, 400 + 500.rand,
					\attack, 6,
					\release, 20
			]);
			};

			if(i ==143){Synth(\farEnough, [
				\addFreq, 2.1,
				\attack, 14,
				\release, 30]
			)};



		};


	};

	//another routine

	fork{
		"hello".postln;
		62.wait;         ///////////after 62 SECs
		2.do({
			Synth(\f, [
				\freq, 30 + 5.rand,
				\addFreq, 3000.rand,
				\attack, 14,
				\release, 30
			]);
			10.wait;
		});
		10.wait;
		"click".postc();


		4.do({Synth(\bur, [
			\freq, 230 + 30.rand,
			\gate, [11, 2, 5, 9].choose,
		]);
		});
		11.wait;

		Synth(\f);
		4.wait;

		Synth(\f,
			[\freq, 400 + 50.rand,
				\attack, 6,
				\release, 20
			]
		);

		0.3.wait;



		3.do({Synth(\bur, [
			\freq, 230 + 30.rand,
			\gate, [11, 2, 9].choose,
			\dauer, 33,
			\amp, [0.1, 0.8, 0.03].choose,
		]);
		});

		14.wait;

		2.do({Synth(\bur, [
			\freq, 230 + 300.rand,
			\gate, [3, 5].choose,
			\dauer, 13,
			\amp, [0.1, 0.8, 0.03].choose,
		]);
		});



	};


	113.wait; //113 seconds later

	Synth(\f,
			[\freq, 400 + 50.rand,
				\attack, 16,
				\release, 23
			]
		);

	fork{
		p=[
			Pbind(\instrument, \bur,
				\freq, 200 + 30.rand,
				\dur, 0.09.rand,
				\amp, Pfunc({[0.04, 0.6].choose}),
				\dauer, 12
			).play,

			5.3.wait;

			Pbind(\instrument, \bur,
				\dur, 0.09,
				\amp, Pfunc({[0.1, 0.6].choose}),
				\dauer, 16
			).play,

			Pbind(\instrument, \bur,
				\dur, 0.1,
				\amp, Pfunc({[0.04, 0.6].choose}),
				\dauer, 16
			).play,

		];

		19.wait;
		p[0].stop;
		0.2.wait;
		p[1].stop;
		p[2].stop;



	};


	s.sync;
});
)