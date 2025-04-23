//these patches will BLOW UP YOUR SPEAKERS! be careful!
s.boot;

//if you want to use different audio devices
s.waitForBoot({
  a = NodeProxy.audio(s, 2);
	a.play;
});

ServerOptions.inDevices;  // Lists input devices
s.options.inDevice.postln;  // Shows current input device
s.options.inDevice = "MixPre-10 II"; //if you wanna use this
s.options.inDevice ="Built-in Microph"; //if you wanna use that.


//basic setup
a = NodeProxy.new.play;

//test
a[0] = {PinkNoise.ar(0.5)};

//ssh
a[0] = nil;

//Aah~!!! feedback!
a[0] = {
	SoundIn.ar(0)
	};
//this sounds really different on different speakers


(a[0] = {
	var mouse = MouseX.kr(0.1, 10);
	var pulse = LFTri.ar(mouse);
	var input = SoundIn.ar(0) * pulse ;
	var output = LeakDC.ar(input);
	output;//removes the dc offset from the filter
};
)

a[0] = nil;


(a[0] =
{
	var mouse = MouseX.kr(0.1, 10);
	var pulse = LFTri.ar(mouse);
	var input = SoundIn.ar(0) * pulse;
	var output = LeakDC.ar(input);
	output;
};
)
//we're interrupting the filter now with a pulsetrain

//i didn't show you this technique yet for modulating saw to triangle and back.
(a[0] =
{
	var mouse = MouseX.kr(100, 2000);
	var pw = MouseY.kr(0.0, 1.0);
	var sinus = VarSaw.ar(mouse, 0, pw, 0.1);
	sinus;
};
)

a[0] = nil;


a[0].scope

(a[0] =
{
	var mouse = MouseX.kr(0.1, 10); //could try at audio rate!
	var pw = MouseY.kr(0.0, 1.0);
	var pulse = VarSaw.ar(mouse, 0, pw, 0.9);
	var input = SoundIn.ar(0) * pulse;
	var output = LeakDC.ar(input);
	output;
};
)

//using a filter
(a[0] =
{
	var input = SoundIn.ar(0);
	var mouse = MouseX.kr(20,1000, 1);
	var qual = MouseY.kr(1, 0.1);
	var output = RLPF.ar(input, mouse, qual);
	output;
};
)
a[0] = nil;

(a[0] =
{
	var thresh = MouseX.kr(0.01, 1);
	var pw = MouseY.kr(0.0, 1.0);
	var attack = MouseY.kr(0.1, 0.1);
	var release = MouseY.kr(0.1, 0.5);
	var input = SoundIn.ar(0);
	var output = Compander.ar(input, input, 0.5, 1, pw, attack, release);
	output;
};
)

//delay
(a[0] =
{
	var input = SoundIn.ar(0);
	var delay = MouseX.kr(0.1, 2);
	var output = CombN.ar(input, 2, delay, 1);
	output;
};
)
a[0] = nil;

(a[0] =
{
var input, output, mousy, delaytime;
    input = SoundIn.ar(0);
	mousy = MouseX.kr(0,1.05);
	delaytime = MouseY.kr(0,1.05);
    output =  LeakDC.ar((DelayN.ar(input, 0.5, delaytime, * mousy)));
    output = Limiter.ar(output, 0.8);
	//Out.ar([0,1], output);
};
)




(a[0]=
{
var input, output, speed;
speed = LFNoise0.kr(0.5, 2, 2.1);
input = SoundIn.ar(0);
output = input + LeakDC.ar((DelayN.ar(input, 3.5, speed, 1.1))); // the delay time is controlled by the'speed' variable. The gain is now fixed at 1.1.
output = RLPF.ar(output, LFNoise0.kr(speed, 400, 1000), 0.15); // move filter various rates determined by the 'speed' variable with frequencies between 400 1200
output = Limiter.ar(output); // our limiter
}
);


(a[0] =
{
	var pw = MouseY.kr(0.0, -1.0);
	var attack = MouseY.kr(0.01, 0.1);
	var release = MouseY.kr(0.01, 0.5);
	var speed = LFNoise0.kr(release, 2, 2.1);
	var input = SoundIn.ar(0);
	var output = Compander.ar(input, input, 0.5, 1, pw, attack, release);
	output = RLPF.ar(output, LFNoise0.kr(speed, 400, 600), 0.15);
	output;
};
)
//combining all techniques


a[0] = {
	var input = SoundIn.ar(0);
	var mouse = MouseX.kr(0, 4pi);
	var freq = MouseY.kr(80, 1000);
	var filt = RLPF.ar(input, freq, 0.5);
	var shift = MouseY.kr(100, -100);
	var out = FreqShift.ar(filt, shift, mouse);
	out = Clip.ar(out, 0.0, 0.6);
	};

a[0] = {
	var input = SoundIn.ar(0);
	var mouse = MouseX.kr(0, 0.01);
	var freq = MouseY.kr(80, 1000);
	var filt = RLPF.ar(input, freq, 0.5);
	var out = AllpassN.ar(filt,0.02,SinOsc.kr(freq,0,mouse,0.01));
	out = Clip.ar(out, 0.0, 0.6);
	};



//crazy new technique, let's do a pitch follower on the feedback and send it to some oscillators.
(a[0] = {
    var input, amp, freq, hasFreq, output;
    input = Mix.new(SoundIn.ar([0,1]));
    amp = Amplitude.kr(input, 0.05, 0.05);
    # freq, hasFreq = Pitch.kr(input, ampThreshold: 0.02, median: 7);
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    output = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));
    6.do({
        output = AllpassN.ar(output, 0.040, [0.040.rand,0.040.rand], 2)
    });
	output;
}
;
)

a[0] = nil;

a[0].scope