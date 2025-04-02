(
SynthDef.new(\bufrd_loop_control, {
    arg amp=1, out=0, buf, rate=1, startPos=0, windowSize=1000;
    var sig, ptr, start, end;

    start = startPos;
    end = start + windowSize;
    end = min(end, BufFrames.kr(buf) - 1);

    ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, start);
    sig = BufRd.ar(1, buf, ptr);

    // Convert mono to stereo
    sig = [sig, sig] * amp;

    Out.ar(out, sig);
}).add;
)

// Create a GUI for control
(
var w = Window("Loop Control", Rect(200, 200, 400, 200));
var startSlider, sizeSlider;

startSlider = Slider(w, Rect(20, 20, 360, 30))
    .action_({|sl|
        var pos = sl.value * (~b2.numFrames - 100);
        x.set(\startPos, pos);
    });

sizeSlider = Slider(w, Rect(20, 70, 360, 30))
    .action_({|sl|
        var size = sl.value * (~b2.numFrames / 2) + 100;
        x.set(\windowSize, size);
    });

sizeSlider.value = 0.2; // Default window size

w.front;
x = Synth.new(\bufrd_loop_control, [\buf, ~b2.bufnum, \startPos, 0, \windowSize, ~b2.numFrames * 0.2]);
)