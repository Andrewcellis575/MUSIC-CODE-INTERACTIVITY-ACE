(
s.waitForBoot({

    SynthDef(\farEnough, {
        arg pitch, freq=70, addFreq=17, attack=1, release=12, amp=1;
        var sig, sig1, saws, env, shapeEnv, local, local2;

        sig = Mix.new(
            Array.fill(8, {
                SinOsc.ar(freq + addFreq.rand, 0.95.rand, 0.01) // Reduced amplitude
            })
        );

        env = EnvGen.kr(Env.perc(attack, release), doneAction:2);
        sig1 = sig + (sig * Mix.new(
            Array.fill(8, {
                SinOsc.ar(0.02, 0.7.rand, LFNoise1.kr(0.02, 0.05)) // Reduced amplitude
            })
        ));

        sig = sig * env;
        sig1 = sig1 * env;

        sig = PitchShift.ar(sig, 0.1, SinOsc.kr(pitch.rrand(0.1, 0.2), 3.2.rand, 0.9, 3));
        sig1 = PitchShift.ar(sig1, 0.1, SinOsc.kr(pitch.rrand(0.1, 9.2), 0, 0.9, 3));

        saws = Mix.new(
            Array.fill(8, {
                LFSaw.ar(\sawFreq.ir(4000) + addFreq.rand, 0.9.rand, 0.01) // Reduced amplitude
            })
        );
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
            0.3, slopeBelow: 1.2, // Slightly higher threshold
            slopeAbove: 0.05, // Reduce gain more for loud signals
            clampTime: 0.1,
            relaxTime: 0.05
        );
        local = local.tanh;
        local = LPF.ar(local, 3000); // Added low-pass filter to tame highs
        LocalOut.ar(local * 0.8);
        Out.ar(0, local * amp); // Scaling output amplitude
    }).add;

    // Adjusting volume in Synth calls
    s.sync;

    fork{
        for(1, 100000){arg i;
            0.01.wait;
            i = i / 100;

            i.postln;

            if(i == 1) { Synth(\farEnough, [\addFreq, 4, \attack, 4, \release, 10, \amp, 0.7]) };
            if(i == 7) {
                Synth(\farEnough, [\addFreq, 21, \release, 13, \amp, 0.6]);
                Synth(\farEnough, [\addFreq, 20, \release, 10, \amp, 0.6]);
            };

            if(i == 11) { Synth(\farEnough, [\addFreq, 38, \release, 10, \amp, 0.5]) };
            if(i == 17.77) { Synth(\farEnough, [\addFreq, 43, \release, 16, \amp, 0.4]) };
            if(i == 24) { Synth(\farEnough, [\addFreq, 403, \attack, 6, \release, 16, \amp, 0.3]) };
            if(i == 26.2) { Synth(\farEnough, [\addFreq, 803, \release, 9, \amp, 0.3]) };
            if(i == 29.6) { Synth(\farEnough, [\addFreq, 2803, \release, 15, \amp, 0.2]) }; // Lowered amp for very high pitch

            if(i == 29.9) { Synth(\impul) };
            if(i == 36.9) {
                Synth(\impul, [\freq, 700]);
                Synth(\farEnough, [\addFreq, 12, \release, 12, \amp, 0.5]);
                Synth(\farEnough, [\addFreq, 17, \release, 14, \amp, 0.5]);
            };

            if(i == 44.3) { Synth(\impul, [\freq, 964]) };

            if(i == 47.2) { Synth(\f) };
            if(i == 52) { Synth(\farEnough, [\addFreq, 2400, \release, 20, \amp, 0.2]) }; // Lowered amp
            if(i == 61.3) {
                Synth(\impul, [\freq, 2904]);
                Synth(\farEnough, [\addFreq, 240, \release, 20, \amp, 0.3]);
            };

            if(i == 102.3) { Synth(\f, [\freq, 400 + 500.rand, \attack, 6, \release, 20]) };

            if(i == 143) { Synth(\farEnough, [\addFreq, 2.1, \attack, 14, \release, 30, \amp, 0.7]) };
        };
    };

    113.wait; // 113 seconds later

    Synth(\f, [\freq, 400 + 50.rand, \attack, 16, \release, 23]);

    fork{
        p = [
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