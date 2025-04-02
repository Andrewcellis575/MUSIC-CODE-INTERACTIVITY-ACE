(
~turntable = NodeProxy.audio(s, 2);
~turntable.play;
~turntable.source = nil;
~turntable.source = {
    |amp=1, buf, lofreq=0.75, start=0, end|
    var sig, ptr;
    end = end ? BufFrames.kr(buf) - 1;

    // Using multichannel expansion with array of different frequencies
    lofreq = [0.75, 1.5, 0.25, 0.5]; // Multiple LFO frequencies
    //lofreq = (1..10).asArray; // Multiple LFO frequencies

    // This creates multiple pointers with different behaviors
    ptr = LFDNoise3.ar(lofreq).range(start, end);

    // BufRd will expand to match the multichannel ptr
    sig = BufRd.ar(2, buf, ptr);

    sig = sig * amp;
    // Mix down the multiple channels to stereo
    sig = Mix.ar(sig) / lofreq.size;
    Pan2.ar(sig, 0);
};
)

~turntable.set(\buf, ~b1, \start, 0, \end, ~b1.numFrames-1)


//can i take one of my cool ugens and use Phasor.ar * another random UGen and average them together for cool modulation?

 w = NodeProxy.audio(s, 2).play;
b = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxCHORD.wav");

(w[0..12] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1, lofreq = 1 |
    var a, f, ptr;
    var buf = b;  // Using the existing buffer 'b'
    var start = 0;
    var end = BufFrames.kr(buf) - 1;

    lo = lo * exprand(1, 200);
    hi = hi * exprand(1, 200);

    // Generate frequency modulation as before
    f = LFClipNoise.kr(widefreq * rrand(0.1, 4.0)).range(lo/440, hi/440);

    // Replace Phasor with LFDNoise1 for randomized reading
    ptr = LFDNoise1.ar(lofreq * rrand(0.1, 2.0)).range(start, end);

    // Use BufRd with the new pointer
    a = BufRd.ar(
        numChannels: buf.numChannels,
        bufnum: buf,
        phase: ptr,
        loop: 1,
        interpolation: 4  // Cubic interpolation for smoother sound
    ) * 0.1;

    // Keep the amplitude envelope
    a = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * a;
    a.dup;
};
)

w.gui

(x=
{
    var a, freq, trig;
    a = Drand([1, 3, 2, 7, 8], inf);
    trig = Impulse.kr(MouseX.kr(1, 400, 1));
    freq = Demand.kr(trig, 0, a) * 30 + 340;
    SinOsc.ar(freq) * 0.1

};
)
p = x.play
