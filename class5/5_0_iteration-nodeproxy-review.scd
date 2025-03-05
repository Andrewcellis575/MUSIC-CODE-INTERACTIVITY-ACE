//gotta make the crickets
(
{
Pan2.ar(
	SinOsc.ar(rrand(80,108).midicps, 2pi.rand,
		Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0)
		* Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs
	), 1.0.rand2);

}.play;
)
//so this is our little engine that we're going to tweak and build into a cool module for live improvisation. no gui needed, for now!
//but this is the rather pathetic method using the .play method, which is not structurally durable for improv, for building up and removing textures without pulling the plug.

n = NodeProxy.audio(s, 2);  // audio rate NP running on the default server with two internal channels
n.fadeTime = 2; //let's define the fadetime
n.source = {SinOsc.ar(440, 0, 0.4)}; //test it, make sure it works.
n.play // whoops, forgot to fire it
n.free //let's free it. the source is still loaded inside the nodeproxy.

(
n.source =
{
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(80,108).midicps, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};
)
//one channel of crickets, works.

n.put(0, {
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(80,108).midicps, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};
)
//any number of crickets using put method on different numbered channels

n[2]= {
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(80,108).midicps, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
}; //even simpler

n[0..8]=
{
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(80,108).midicps, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
}; //the power of iteration!!!!!!

n.source = nil; //fade out all the crickets!

n[0..8]=
{
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(80,108).midicps, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
}; //the power of iteration!!!!!!

n[2..8]=
{
}; //the power of iteration!!!!!! kill all but the last two crickets for the end of our little piece. cute!


n[1..4]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(1,10)*pitch, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};
// adding some basic controls.i'm just messing around here, but these are attributed to all channels inside the nodeproxy of N.
//so it's kind of like master controls.

n.gui