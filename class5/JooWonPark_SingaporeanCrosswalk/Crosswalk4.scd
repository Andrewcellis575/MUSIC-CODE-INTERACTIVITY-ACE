/*
Singaporean Crosswalk
for laptop ensemble
by Joo Won Park
©2016
Version 2.1

How to run the file:
1. Open this file in SuperCollider
2. Go to Menu->Language->Evaluate File. A GUI window will appear in few seconds
3. Click 'Start Music (Manual)' on the third button of GUI. This action should be  synchronized with the other performers
4.Press Command+Period to Stop (or go to Menu->Language->Stop). Repeat Steps 2&3 for replay.

Performance Instruction is availble at www.joowonpark.net/crosswalk
*/

//Modify these two lines if needed.
//The values of ~key, ~timescale, and ~tmap should be same for all files used by all performers.

~key=61+12;
~timescale=0.5;


// Do not modify below this line (unless...)

~tmap=[
	0,
	30,30,11,13,15,17,30,40,
	10,20,5,13,10,30,30,30,
	30,15,4,35,30,10,15,20,
	40,5,20,30,60
]*~timescale;

~sectiontiming={
	var size,array,prev;
	size= ~tmap.size;
	array= Array.fill(size,{0});
	prev=0;
	size.do{
		arg count;
		if (count==0,
			{
				array.put(0,~tmap[count]);
				prev = prev+~tmap[count];
			},
			{
				array.put(count,~tmap[count]+prev);
				prev = prev+~tmap[count];
			}
		);
	};
	~section=array;
};

//caclulate the duration of each sytemclock time
~sectiontiming.value(0);
~section.size;

s.waitForBoot{

SynthDef("Works",{
	arg vol,pitch,pitch2,modfreq,modmulti,ampfmulti;
	var in, amplitude, sound,sound2,sound3,delay,mix,
	bsound,bsound2,bsound3,amplitude2,amplitude3;

	sound = LFTri.ar((pitch+~key).midicps);
	sound2 = Lag.ar(LFPulse.ar(modfreq,width:Rand(0.1,0.25)),0.01);
	sound3 = sound*sound2;

	in = SoundIn.ar(0);
	in = HPF.ar(in-sound3,200);

	amplitude = Amplitude.ar(in,0.01,0.01);

	bsound = LFTri.ar((pitch2+~key).midicps);
	bsound2 = Lag.ar(LFPulse.ar(modfreq*modmulti),0.01);
	bsound3 = bsound*bsound2*amplitude*ampfmulti;

	mix = (sound3)+(bsound3);
	Out.ar(0,[sound3,bsound3]*vol);
}).load(s);

SynthDef("Shorts",{
	arg freq,freq2,vol;
	var sound,sound2;

	sound = HPF.ar(Impulse.ar(freq),Rand(1,12)*100);
	sound2 = HPF.ar(Impulse.ar(freq2),Rand(1,12)*100);

	Out.ar(0,[sound,sound2]*vol*2);
}).load(s);

//GUI

~closewindow={~window.close};
CmdPeriod.add(~closewindow);

~window = Window.new("Cue - Performer 4");
~window.front;
~width=1000;
~height=800;
~window.bounds=Rect(130,40,~width,~height);
	~window.background=Color.white;
~button = Button(~window,Rect(~width*0.1,~height*0.03,~width*0.8,~height*0.25));
	~button.states=[["Singaporean Crosswalk",Color.white,Color.red]];
~button.font= Font("Monaco", 50);

~button2 = Button(~window,Rect(~width*0.1,~height*0.32,~width*0.8,~height*0.25));
~button2.font= Font("Monaco", 45);
	~label={arg a;~button2.states=[[a,Color.black,Color.yellow]]};
	~label.value("by Joo Won Park");


//start stop
~button3 =  Button(~window,Rect(~width*0.1,~height*0.6,~width*0.8,~height*0.25));
~button3.font= Font("Monaco", 40);
~button3.states = [
		["Start Music",Color.black,Color.green],
		["Press Command+. To Stop Music",Color.black,Color.green]
];
~button3.action ={
	arg butt;
	//butt=~gbutt;
	if (butt.value ==1,{
			SystemClock.clear;
			~score.value(0);
			{~window.background=Color.black}.defer;
		});
};

~cue={
Routine({
	[3,2,1,"change"].do{
		arg counter;
		1.do{
			{~button.states=[[counter,Color.rand,Color.rand]]}.defer;
					{~window.background=Color.rand}.defer;
				(0.5*~timescale).wait;
		};
		1.do{
			{~button.states=[[counter,Color.rand,Color.rand]]}.defer;
				(0.5*~timescale).wait;
		};

	}
}).play
};




~score={
	SystemClock.sched(~section[1]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[2]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[3]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[4]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[5]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[6]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[7]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[8]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[9]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[10]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[11]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[12]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[13]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[14]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[15]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[16]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[17]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[18]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[19]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[20]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[21]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[22]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[23]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[24]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[25]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[26]-(3*~timescale),{~cue.value(0)});
	SystemClock.sched(~section[27]-(3*~timescale),{~cue.value(0)});



SystemClock.sched(~section[0],{
		"section 0".postln;
		~traffic4=Synth("Works",[\vol,1,\pitch,0,\pitch2,7,\modfreq,2,\modmulti,3.rand+1,\ampfmulti,2]);
		{~button.states=[["Go!".postln]]}.defer;
			{~label.value("enter")}.defer;

});

SystemClock.sched(~section[1],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [3,4,5,6].choose;
		"section 1".postln;
	~traffic4.set(\vol,1,\pitch,8+oct,\pitch2,5+oct,\modfreq,5,\modmulti,modf.rand+2);
		{~label.value("walk or stop")}.defer;

});


SystemClock.sched(~section[2],{
			var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [1,2,3,4].choose;
	"section 2".postln;
	~traffic4.set(\vol,1,\pitch,12+oct,\pitch2,10+oct,\modfreq,modf,\modmulti,4.rand+2);

});

SystemClock.sched(~section[3],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [1,2,3,4].choose;
	"section 3".postln;
	~traffic4.set(\vol,1,\pitch,5+oct,\pitch2,12+oct,\modfreq,modf,\modmulti,4.rand+4);

});

SystemClock.sched(~section[4],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [3,4,5,6].choose;
	"section 4".postln;
	~traffic4.set(\vol,1,\pitch,4+oct,\pitch2,10+oct,\modfreq,modf,\modmulti,3.rand+2);


});

SystemClock.sched(~section[5],{
			var oct,modf;
		oct=[0,0,12].choose;
		modf = [3,6,7,8].choose;
	"section 5".postln;
	~traffic4.set(\vol,1,\pitch,10+oct,\pitch2,4+oct,\modfreq,modf,\modmulti,4.rand+1);

});

SystemClock.sched(~section[6],{
		var oct, modf;
			oct=[0,0,0,0,12].choose;
		modf = [1,2,3,4].choose;
	"section 6".postln;
	~traffic4.set(\vol,1,\pitch,5-12+oct,\pitch2,20+oct,\modfreq,modf,\modmulti,3.rand+3);

});

SystemClock.sched(~section[7],{
		var oct,modf;
		oct=[0,0,12,12].choose;
		modf = [3,5,7].choose;
	"section 7".postln;
	~traffic4.set(\vol,1,\pitch,15+oct,\pitch2,10+oct,\modfreq,modf,\modmulti,4.rand+4);
			{~label.value("walk or stop with hand")}.defer;

});

	SystemClock.sched(~section[8],{
		var oct,modf;
		oct=[12,-12,12].choose;
		modf = [4,5,6,7].choose;
	"section 8".postln;
	~traffic4.set(\vol,1,\pitch,0,\pitch2,7,\modfreq,modf,\modmulti,3.rand+1);

});

SystemClock.sched(~section[9],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [3,4,5,6,7,8].choose;
		"section 9".postln;
	~traffic4.set(\vol,1,\pitch,2.8+oct,\pitch2,5.4+oct,\modfreq,modf,\modmulti,2.rand+2);


});


SystemClock.sched(~section[10],{
			var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [4,5,6,9,10].choose;
	"section 10".postln;
	~traffic4.set(\vol,1,\pitch,2+oct,\pitch2,oct+11,\modfreq,modf,\modmulti,4.rand+2);

});

SystemClock.sched(~section[11],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [1,2,3,4,5,6].choose;
	"section 11".postln;
		~traffic4.set(\vol,1,\pitch,10+oct,\pitch2,12+oct,\modfreq,modf,\modmulti,4.rand+3);


});

SystemClock.sched(~section[12],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [1,2,3,4,5,6].choose;
	"section 12".postln;

	~traffic4.set(\vol,1,\pitch,14+oct,\pitch2,10+oct,\modfreq,modf,\modmulti,6.rand+4);

});

SystemClock.sched(~section[13],{
			var oct,modf;
		oct=[0,0,12].choose;
		modf = [1,2,3,6].choose;
	"section 13".postln;
	~traffic4.set(\vol,1,\pitch,18+oct,\pitch2,10+oct,\modfreq,modf,\modmulti,3.rand+2);

});

SystemClock.sched(~section[14],{
		var oct, modf;
			oct=[0,12,0,0,12].choose;
		modf = [0.5,1,2,3,4].choose;
	"section 14".postln;
	~traffic4.set(\vol,1,\pitch,15+oct,\pitch2,8+oct,\modfreq,modf,\modmulti,6.rand+18);
				{~label.value("walk or stop with hand")}.defer;


});

SystemClock.sched(~section[15],{
		var oct,modf;
		oct=[0,0,12,12].choose;
		modf = [2,3,0.333,0.25].choose;
	"section 15".postln;
				"------------------".postln;
				"------------------".postln;
				"------------------".postln;
			"----Next is Walk only".postln;
			"----Next is Walk only".postln;
			"----Next is Walk only".postln;
			"----Next is Walk only".postln;
			"------------------".postln;
			"".postln;
				"".postln;
	~traffic4.set(\vol,1,\pitch,10+oct,\pitch2,3+oct,\modfreq,modf,\modmulti,4.rand+7);

});

		SystemClock.sched(~section[16],{
		var oct,modf;
		oct=[0,0,12].choose;
		modf = [2,1,3,2].choose;
	"section 16".postln;
				"------------------".postln;
				"------------------".postln;
				"------------------".postln;
			"----Next is Stop only".postln;
			"----Next is Stop only".postln;
			"----Next is Stop only".postln;
			"----Next is Stop only".postln;
			"------------------".postln;
					"".postln;
				"".postln;
			"Click Coming".postln;
	~traffic4.set(\vol,1,\pitch,13,\pitch2,19,\modfreq,modf,\modmulti,4.rand+2);
				{~label.value("walk")}.defer;

});

SystemClock.sched(~section[17],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [3,4,6,7,8,9].choose;
		"section 17".postln;
		~traffic4.set(\vol,0);
		~clicks=Synth("Shorts",[\freq,modf,\freq2,modf+[1,2,3,-1,-2,-3].choose,\vol,1.3]);
				{~label.value("stop")}.defer;

});


SystemClock.sched(~section[18],{
			var oct,modf;
		oct=[0,12,0,12].choose;
		modf = [5,2,3,4].choose;
	"section 18".postln;
		~clicks.free;
	~traffic4.set(\vol,1,\pitch,11+oct,\pitch2,12+oct,\modfreq,modf,\modmulti,5.rand+2);
			{~label.value("walk or stop with hand")}.defer;

});

SystemClock.sched(~section[19],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [8,9,10,11,12].choose;
	"section 19".postln;
	~traffic4.set(\vol,1,\pitch,10+oct,\pitch2,12+oct,\modfreq,modf,\modmulti,4.rand+3);

});

SystemClock.sched(~section[20],{
		var oct,modf;
		oct=[0,0,0,12].choose;
		modf = [0.5,1,2,3,4].choose;
	"section 20".postln;
	~traffic4.set(\vol,1,\pitch,4+oct,\pitch2,-2+oct,\modfreq,modf,\modmulti,6.rand+1);

});

SystemClock.sched(~section[21],{
			var oct,modf;
		oct=[0,0,12].choose;
		modf = [0.5,0.25,2].choose;
	"section 21".postln;
	~traffic4.set(\vol,1,\pitch,6+oct,\pitch2,7+oct,\modfreq,modf,\modmulti,3.rand+5);

});

SystemClock.sched(~section[22],{
		var oct, modf;
			oct=[0,12,0,0,12].choose;
		modf = [10,20,30,40].choose;
	"section 22".postln;
	~traffic4.set(\vol,1,\pitch,5+oct,\pitch2,2+oct,\modfreq,modf,\modmulti,6.rand+8);

});

SystemClock.sched(~section[23],{
		var oct,modf;
		oct=[24,12,12].choose;
		modf = [59-12].choose;
	"section 23".postln;
	~traffic4.set(\vol,1,\pitch,11+oct,\pitch2,12+oct,\modfreq,modf,\modmulti,4.rand+7);

});

	SystemClock.sched(~section[24],{
		var oct,modf;
		oct=[0,0,0].choose;
		modf = [2,3,4,6].choose;
	"section 24".postln;
	~traffic4.set(\vol,3,\pitch,-26+oct,\pitch2,-19+oct,\modfreq,modf,\modmulti,4.rand+5);

});


		SystemClock.sched(~section[25],{
		var oct,modf;
		oct=[12,0,0,0].choose;
		modf = [1,2,3,4,5,6].choose;
	"section 25".postln;
					"------------------".postln;
				"------------------".postln;
				"------------------".postln;
			"----Next is Stop only".postln;
			"----Next is Stop only".postln;
			"----Next is Stop only".postln;
			"----Next is Stop only".postln;
			"------------------".postln;
				"".postln;
				"".postln;
			"Click Coming".postln;
	~traffic4.set(\vol,1,\pitch,0+oct,\pitch2,4+oct,\modfreq,modf,\modmulti,1.rand+0.25);



});


		SystemClock.sched(~section[26],{
		var oct,modf;
		oct=[12,0,12,0].choose;
		modf = [1,2,5,6,7].choose;
	"section 26".postln;

		~traffic4.set(\vol,0);
		~clicks=Synth("Shorts",[\freq,modf,\freq2,modf+[1,2,3,-1,-2,-3].choose,\vol,1.3]);
				{~label.value("stop")}.defer;

});

		SystemClock.sched(~section[27],{
		var oct,modf;
		oct=[12,0,12,0].choose;
		modf = [0.5,1,2].choose;
	"section 27".postln;
		~clicks.free;
	~traffic4.set(\vol,1,\pitch,12+oct+24,\pitch2,19+oct+24,\modfreq,modf*0.5,\modmulti,6.rand+4);
				{~label.value("exit then fadeout")}.defer;
});



}; //end of score

/*OSCFunc({
	arg  msg, time, addr, recvPort;
	if (msg[1]==1,
		{
				SystemClock.clear;~score.value(0);
					{~button3.value=1}.defer;
				"Remote On".postln;
				~window.background=Color.black;
			},
		{

				~traffic.free;~clicks.free;~cue.stop;~cue.reset;
				{~window.close;}.defer;
				{~button3.value=0}.defer;
				s.quit;s.killAll;
				"Remote Off".postln;
		});
	//"hey".postln;
},\onoff);*/

} //end of wait for boot